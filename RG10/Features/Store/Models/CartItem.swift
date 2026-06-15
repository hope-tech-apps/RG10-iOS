//
//  CartItem.swift
//  RG10
//
//  A single line in the native store cart. Persisted to UserDefaults as
//  Codable JSON so the bag survives app relaunches.
//

import Foundation

/// One line item in the store cart: a chosen variant and its quantity.
struct CartItem: Codable, Hashable, Identifiable {
    /// Numeric Shopify variant id; also the value used in cart permalinks.
    let variantID: Int64
    let productTitle: String
    let variantTitle: String
    /// Unit price in integer cents at the time of adding (refreshed on cart open).
    var unitPriceCents: Int
    var quantity: Int
    let imageURL: String?
    let productHandle: String

    /// Stable identity is the variant; the same variant is a single line.
    var id: Int64 { variantID }

    /// Subtotal for this line in cents.
    var lineTotalCents: Int {
        unitPriceCents * quantity
    }

    /// Formatted unit price (e.g. "$60.00").
    var displayUnitPrice: String {
        PriceFormatter.display(cents: unitPriceCents)
    }

    /// Formatted line subtotal (e.g. "$120.00").
    var displayLineTotal: String {
        PriceFormatter.display(cents: lineTotalCents)
    }
}
