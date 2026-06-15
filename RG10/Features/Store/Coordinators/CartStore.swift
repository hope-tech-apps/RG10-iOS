//
//  CartStore.swift
//  RG10
//
//  Store-scoped shopping cart for the live Flite Sports Shopify storefront.
//
//  A single shared, observable cart (mirrors how the app uses
//  AuthManager.shared / NavigationManager.shared). Line items persist to
//  UserDefaults as Codable JSON, so the bag survives relaunch. Checkout is
//  token-free: the cart is handed to Shopify via a cart permalink.
//

import SwiftUI
import Combine

final class CartStore: ObservableObject {
    static let shared = CartStore()

    /// The current line items, persisted on every mutation.
    @Published private(set) var items: [CartItem] = []

    private let defaults: UserDefaults
    private let storageKey = "store.cart.items.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.items = Self.load(from: defaults, key: storageKey)
    }

    // MARK: - Derived Values

    /// Total number of units across all lines (drives the header badge).
    var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    /// Cart subtotal in integer cents.
    var subtotalCents: Int {
        items.reduce(0) { $0 + $1.lineTotalCents }
    }

    /// Formatted subtotal (e.g. "$180.00").
    var displaySubtotal: String {
        PriceFormatter.display(cents: subtotalCents)
    }

    var isEmpty: Bool {
        items.isEmpty
    }

    // MARK: - Mutations

    /// Adds a variant to the cart, merging into an existing line if present.
    func add(product: ShopifyProduct, variant: ShopifyVariant, quantity: Int = 1) {
        let qty = max(1, quantity)
        if let index = items.firstIndex(where: { $0.variantID == variant.variantID }) {
            items[index].quantity += qty
            items[index].unitPriceCents = variant.priceCents
        } else {
            let item = CartItem(
                variantID: variant.variantID,
                productTitle: product.title,
                variantTitle: variant.title,
                unitPriceCents: variant.priceCents,
                quantity: qty,
                imageURL: product.images.first?.src,
                productHandle: product.handle
            )
            items.append(item)
        }
        persist()
    }

    /// Sets an absolute quantity for a line; a quantity of zero removes it.
    func setQuantity(_ quantity: Int, for variantID: Int64) {
        guard let index = items.firstIndex(where: { $0.variantID == variantID }) else { return }
        if quantity <= 0 {
            items.remove(at: index)
        } else {
            items[index].quantity = quantity
        }
        persist()
    }

    /// Removes a line entirely.
    func remove(variantID: Int64) {
        items.removeAll { $0.variantID == variantID }
        persist()
    }

    /// Empties the cart.
    func clear() {
        items.removeAll()
        persist()
    }

    /// Defensive refresh against the latest catalog: re-sync each line's price,
    /// title, and image, and drop variants that no longer exist or are sold out.
    func refresh(with products: [ShopifyProduct]) {
        var variantToProduct: [Int64: (ShopifyProduct, ShopifyVariant)] = [:]
        for product in products {
            for variant in product.variants {
                variantToProduct[variant.variantID] = (product, variant)
            }
        }

        items = items.compactMap { item in
            guard let (product, variant) = variantToProduct[item.variantID],
                  variant.available else {
                return nil
            }
            var updated = item
            updated.unitPriceCents = variant.priceCents
            return updated
        }
        persist()
    }

    // MARK: - Checkout

    /// Builds the Shopify cart permalink for the current bag.
    ///
    /// Format: `STORE_BASE/cart/<variantId>:<qty>,<variantId>:<qty>...`
    /// Loading this URL in a cookied WebView populates Shopify's cart and lands
    /// on the hosted checkout. Returns nil when the cart is empty.
    func checkoutURL() -> URL? {
        guard !items.isEmpty else { return nil }
        let lines = items
            .map { "\($0.variantID):\($0.quantity)" }
            .joined(separator: ",")
        return URL(string: StoreConstants.storeBaseURL + "/cart/" + lines)
    }

    // MARK: - Persistence

    private func persist() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        defaults.set(data, forKey: storageKey)
    }

    private static func load(from defaults: UserDefaults, key: String) -> [CartItem] {
        guard let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode([CartItem].self, from: data) else {
            return []
        }
        return decoded
    }
}
