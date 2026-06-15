//
//  MerchandiseService.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/10/25.
//
//  Fetches the live Flite Sports Shopify collection from its public
//  products.json feed. No API key or account is required.
//

import Foundation

enum MerchandiseServiceError: LocalizedError {
    case invalidURL
    case badResponse

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The store address is invalid."
        case .badResponse:
            return "The store returned an unexpected response."
        }
    }
}

// MARK: - Merchandise Service
final class MerchandiseService {
    static let shared = MerchandiseService()

    private init() {}

    /// Fetch the RG10 collection products from the public Shopify feed.
    func fetchProducts() async throws -> [ShopifyProduct] {
        guard let url = URL(string: StoreConstants.productsJSONURL) else {
            throw MerchandiseServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            throw MerchandiseServiceError.badResponse
        }

        let decoded = try JSONDecoder().decode(ShopifyProductsResponse.self, from: data)
        return decoded.products
    }
}
