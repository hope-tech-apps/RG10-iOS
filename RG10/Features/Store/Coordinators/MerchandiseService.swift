//
//  MerchandiseService.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/10/25.
//

import Foundation
import Supabase
import SwiftUI
import Combine

// MARK: - Merchandise Service
class MerchandiseService: ObservableObject {
    static let shared = MerchandiseService()
    
    // Use the centralized client instead of creating a new one
    private let client = SupabaseClientManager.shared.client
    
    private init() {}
    
    // MARK: - Fetch All Products
    func fetchProducts() async throws -> [Merchandise] {
        let response = try await client
            .from("products")
            .select()
            .execute()
        
        // Don't specify date decoding strategy - let it decode as strings
        let decoder = JSONDecoder()
        let products = try decoder.decode([Merchandise].self, from: response.data)
        return products
    }
    
    // MARK: - Fetch Product Sizes
    func fetchProductSizes(for productId: Int) async throws -> [SizeDetail] {
        let productSizesResponse = try await client
            .from("product_sizes")
            .select("*")
            .eq("product_id", value: productId)
            .execute()
        
        let productSizes = try JSONDecoder().decode([MerchandiseItemSize].self, from: productSizesResponse.data)
        
        let sizesResponse = try await client
            .from("sizes")
            .select("*")
            .execute()
        
        let sizes = try JSONDecoder().decode([MerchandiseSize].self, from: sizesResponse.data)
        
        let sizesDict = Dictionary(uniqueKeysWithValues: sizes.map { ($0.id, $0) })
        
        var sizeDetails: [SizeDetail] = []
        
        for productSize in productSizes {
            if let size = sizesDict[productSize.size_id] {
                let sizeType = size.size_type_id == 1 ? "Youth" : "Adult"
                
                let detail = SizeDetail(
                    id: productSize.id,
                    productId: productId,
                    sizeName: size.size,
                    sizeType: sizeType,
                    price: productSize.price,
                    stripePriceId: productSize.stripe_price_id,
                    inStock: true
                )
                
                sizeDetails.append(detail)
            }
        }
        
        let sizeOrder = ["small", "medium", "large", "xl", "2xl"]
        sizeDetails.sort { first, second in
            if first.sizeType != second.sizeType {
                return first.sizeType == "Youth"
            }
            let firstIndex = sizeOrder.firstIndex(of: first.sizeName.lowercased()) ?? 99
            let secondIndex = sizeOrder.firstIndex(of: second.sizeName.lowercased()) ?? 99
            return firstIndex < secondIndex
        }
        
        return sizeDetails
    }
    
    // MARK: - Fetch Categories
    func fetchCategories() async throws -> [Category] {
        let response = try await client
            .from("categories")
            .select()
            .execute()
        
        let categories = try JSONDecoder().decode([Category].self, from: response.data)
        return categories
    }
}
