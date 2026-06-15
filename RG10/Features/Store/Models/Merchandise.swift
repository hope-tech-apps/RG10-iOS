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
    let tags: [String]
    let variants: [ShopifyVariant]
    let images: [ShopifyImage]

    enum CodingKeys: String, CodingKey {
        case id, title, handle, vendor, tags, variants, images
        case productType = "product_type"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        handle = try container.decode(String.self, forKey: .handle)
        vendor = try container.decodeIfPresent(String.self, forKey: .vendor) ?? ""
        productType = try container.decodeIfPresent(String.self, forKey: .productType) ?? ""
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
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

/// A purchasable variant (e.g. a specific size) of a Shopify product.
struct ShopifyVariant: Codable, Hashable {
    let id: Int
    let title: String
    let price: String
    let available: Bool

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        price = try container.decodeIfPresent(String.self, forKey: .price) ?? ""
        available = try container.decodeIfPresent(Bool.self, forKey: .available) ?? false
    }
}

/// An image associated with a Shopify product.
struct ShopifyImage: Codable, Hashable {
    let src: String
}
