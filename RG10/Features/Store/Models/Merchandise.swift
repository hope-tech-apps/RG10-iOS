//
//  Merchandise.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/6/25.
//
//  Models for the live Flite Sports Shopify storefront. These decode the
//  public Shopify products.json feed for the RG10 TST team-gear collection.
//

import Foundation

// MARK: - Shopify Products Feed

/// Top-level wrapper for the Shopify `/products.json` response.
struct ShopifyProductsResponse: Codable {
    let products: [ShopifyProduct]
}

/// A single product from the Shopify storefront feed.
///
/// Decoding is defensive: missing images or variants are tolerated so a
/// partially-populated product still renders in the grid.
struct ShopifyProduct: Codable, Hashable, Identifiable {
    let id: Int
    let title: String
    let handle: String
    let vendor: String
    let productType: String
    let bodyHTML: String
    let tags: [String]
    let options: [ShopifyOption]
    let variants: [ShopifyVariant]
    let images: [ShopifyImage]

    enum CodingKeys: String, CodingKey {
        case id, title, handle, vendor, tags, options, variants, images
        case productType = "product_type"
        case bodyHTML = "body_html"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        handle = try container.decode(String.self, forKey: .handle)
        vendor = try container.decodeIfPresent(String.self, forKey: .vendor) ?? ""
        productType = try container.decodeIfPresent(String.self, forKey: .productType) ?? ""
        bodyHTML = try container.decodeIfPresent(String.self, forKey: .bodyHTML) ?? ""
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        options = try container.decodeIfPresent([ShopifyOption].self, forKey: .options) ?? []
        variants = try container.decodeIfPresent([ShopifyVariant].self, forKey: .variants) ?? []
        images = try container.decodeIfPresent([ShopifyImage].self, forKey: .images) ?? []
    }

    /// First product image URL, if any.
    var firstImageURL: URL? {
        guard let src = images.first?.src else { return nil }
        return URL(string: src)
    }

    /// Web URL of this product inside the collection (for the in-app browser).
    var webURL: URL? {
        URL(string: StoreConstants.productURL(handle: handle))
    }

    /// Image URLs for the product gallery (deduplicated, in feed order).
    var imageURLs: [URL] {
        images.compactMap { URL(string: $0.src) }
    }

    /// Whether the product can be resolved to a single variant in-app.
    ///
    /// We support products with zero or one option dimension natively. Anything
    /// with two or more option dimensions (e.g. Size + Color) falls back to the
    /// web product page, where Shopify handles the multi-axis matrix for us.
    var isNativelyPurchasable: Bool {
        options.count <= 1
    }

    /// The single product option (e.g. "Size") when there is exactly one.
    var primaryOption: ShopifyOption? {
        options.count == 1 ? options.first : nil
    }

    /// Resolves a selected option value to its matching variant.
    ///
    /// For single-option products the value is matched against `option1`. For
    /// option-less products the lone variant is returned regardless of value.
    func variant(forOptionValue value: String?) -> ShopifyVariant? {
        if options.isEmpty {
            return variants.first
        }
        guard let value else { return nil }
        return variants.first { $0.option1 == value }
    }

    /// A product is sold out when none of its variants are available.
    var isSoldOut: Bool {
        guard !variants.isEmpty else { return true }
        return !variants.contains { $0.available }
    }

    /// Lowest variant price as a numeric value, if any variant has a valid price.
    private var minPrice: Double? {
        variants.compactMap { Double($0.price) }.min()
    }

    /// Whether every variant shares the same price.
    private var hasSinglePrice: Bool {
        let prices = Set(variants.compactMap { Double($0.price) })
        return prices.count <= 1
    }

    /// Display price for the card: an exact price when all variants match,
    /// otherwise a "From $X" range. Empty when no price is available.
    var displayPrice: String {
        guard let min = minPrice else { return "" }
        let formatted = String(format: "$%.2f", min)
        return hasSinglePrice ? formatted : "From \(formatted)"
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: ShopifyProduct, rhs: ShopifyProduct) -> Bool {
        lhs.id == rhs.id
    }
}

/// A configurable option dimension of a Shopify product (e.g. "Size").
struct ShopifyOption: Codable, Hashable {
    let name: String
    let values: [String]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        values = try container.decodeIfPresent([String].self, forKey: .values) ?? []
    }
}

/// A purchasable variant (e.g. a specific size) of a Shopify product.
struct ShopifyVariant: Codable, Hashable, Identifiable {
    let id: Int
    let title: String
    let price: String
    let available: Bool
    let option1: String?
    let option2: String?
    let option3: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        price = try container.decodeIfPresent(String.self, forKey: .price) ?? ""
        available = try container.decodeIfPresent(Bool.self, forKey: .available) ?? false
        option1 = try container.decodeIfPresent(String.self, forKey: .option1)
        option2 = try container.decodeIfPresent(String.self, forKey: .option2)
        option3 = try container.decodeIfPresent(String.self, forKey: .option3)
    }

    /// Variant id as the 64-bit value used in Shopify cart permalinks.
    var variantID: Int64 {
        Int64(id)
    }

    /// Price parsed to integer cents (e.g. "60.00" → 6000). Zero when unparseable.
    var priceCents: Int {
        PriceFormatter.cents(from: price)
    }

    /// Formatted unit price (e.g. "$60.00"). Empty when the price is unparseable.
    var displayPrice: String {
        PriceFormatter.display(cents: priceCents)
    }
}

/// An image associated with a Shopify product.
struct ShopifyImage: Codable, Hashable {
    let src: String
}

// MARK: - Price Formatting

/// Robust conversion between Shopify price strings, integer cents, and display
/// strings. Centralized so the catalog and the cart agree on cart math.
enum PriceFormatter {
    /// Parses a Shopify price string ("60.00", "1,299.50", " $40 ") into cents.
    ///
    /// Strips currency symbols, grouping separators, and whitespace; rounds to
    /// the nearest cent. Returns 0 for empty or unparseable input.
    static func cents(from price: String) -> Int {
        let cleaned = price
            .replacingOccurrences(of: ",", with: "")
            .filter { $0.isNumber || $0 == "." }
        guard let value = Double(cleaned), value.isFinite, value >= 0 else { return 0 }
        return Int((value * 100).rounded())
    }

    /// Formats integer cents as a USD display string (e.g. 6000 → "$60.00").
    static func display(cents: Int) -> String {
        String(format: "$%.2f", Double(cents) / 100.0)
    }
}

// MARK: - HTML Description

enum HTMLText {
    /// Converts a Shopify `body_html` fragment into readable plain text.
    ///
    /// Block tags become line breaks, list items get a bullet, entities are
    /// decoded, and remaining tags are stripped. This avoids the main-thread
    /// cost and styling unpredictability of `NSAttributedString`'s HTML import
    /// while still producing clean, paragraphed copy.
    static func plainText(from html: String) -> String {
        guard !html.isEmpty else { return "" }

        var text = html
        // Normalize line-breaking block tags to newlines.
        let breakPatterns = ["<br>", "<br/>", "<br />", "</p>", "</div>", "</li>", "</h1>", "</h2>", "</h3>", "</h4>"]
        for pattern in breakPatterns {
            text = text.replacingOccurrences(
                of: pattern,
                with: "\n",
                options: [.caseInsensitive]
            )
        }
        // Bullet list items.
        text = text.replacingOccurrences(
            of: "<li[^>]*>",
            with: "• ",
            options: [.regularExpression, .caseInsensitive]
        )
        // Strip all remaining tags.
        text = text.replacingOccurrences(
            of: "<[^>]+>",
            with: "",
            options: [.regularExpression]
        )
        // Decode the common HTML entities.
        let entities: [String: String] = [
            "&amp;": "&", "&lt;": "<", "&gt;": ">", "&quot;": "\"",
            "&#39;": "'", "&apos;": "'", "&nbsp;": " ", "&rsquo;": "’",
            "&lsquo;": "‘", "&ldquo;": "“", "&rdquo;": "”", "&hellip;": "…",
            "&mdash;": "—", "&ndash;": "–"
        ]
        for (entity, replacement) in entities {
            text = text.replacingOccurrences(of: entity, with: replacement)
        }
        // Collapse excess whitespace and blank lines.
        let lines = text
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
        var result: [String] = []
        for line in lines {
            if line.isEmpty && (result.last?.isEmpty ?? true) { continue }
            result.append(line)
        }
        return result.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
