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

// MARK: - Supabase Service
class MerchandiseService: ObservableObject {
    static let shared = MerchandiseService()
    
    private let client = SupabaseClient(
        supabaseURL: URL(string: "https://uwssjvqlsekveqvdkdnj.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV3c3NqdnFsc2VrdmVxdmRrZG5qIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcyMTU5OTksImV4cCI6MjA3Mjc5MTk5OX0.HG6t79U5z8w_f0Qfwgclkxs4aZOfgALbMEwXN9ZTA00",
        options: SupabaseClientOptions(db: .init(schema: "rg10"))
    )
    
    // MARK: - Fetch All Products (Fixed)
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
    
    // Rest of the methods remain the same...
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
    
    func fetchCategories() async throws -> [Category] {
        let response = try await client
            .from("categories")
            .select()
            .execute()
        
        let categories = try JSONDecoder().decode([Category].self, from: response.data)
        return categories
    }
}
