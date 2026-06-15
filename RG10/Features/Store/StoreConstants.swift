//
//  StoreConstants.swift
//  RG10
//
//  Configuration for the live Flite Sports Shopify storefront.
//  Shopify storefronts expose a public products.json feed, so no API key,
//  token, or account is required to read the RG10 collection.
//

import Foundation

enum StoreConstants {
    /// Base URL of the client's live Shopify storefront.
    static let storeBaseURL = "https://www.flitesports.com"

    /// Handle of the RG10 2026 TST team-gear collection.
    static let collectionHandle = "rg10-2026-tst-team-gear"

    /// Web URL of the collection landing page (used for the in-app browser).
    static let collectionURL = storeBaseURL + "/collections/" + collectionHandle

    /// Public JSON feed of the collection's products (no auth required).
    static let productsJSONURL = collectionURL + "/products.json?limit=250"

    /// Web URL of an individual product within the collection.
    static func productURL(handle: String) -> String {
        collectionURL + "/products/" + handle
    }
}
