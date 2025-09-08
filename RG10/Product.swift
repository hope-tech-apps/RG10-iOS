//
//  Product.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/6/25.
//

import Foundation
import Supabase
import SwiftUI
import Combine

// MARK: - Database Models (matching your Supabase schema)

struct DBProduct: Codable {
    let id: Int
    let name: String
    let description: String
    let category_id: Int?
    let image_urls: [String]?
    let is_new: Bool
    let is_featured: Bool
    let stripe_product_id: String?
    let stripe_payment_link: String?
    let created_at: Date
    let updated_at: Date
    
    // Direct access to image array
    var imageArray: [String] {
        return image_urls ?? []
    }
}

struct DBCategory: Codable {
    let id: Int
    let category: String
}

struct DBProductSize: Codable {
    let id: Int
    let product_id: Int
    let size_id: Int
    let size_type_id: Int?
    let price: Double
    let stripe_price_id: String?
    
    // Relations (will be populated with joins)
    var size: DBSize?
    var size_type: DBSizeType?
}

struct DBSize: Codable {
    let id: Int
    let size: String
    let size_type_id: Int
}

struct DBSizeType: Codable {
    let id: Int
    let type: String  // "youth" or "adult"
}

// MARK: - Supabase Service
class SupabaseMerchandiseService: ObservableObject {
    static let shared = SupabaseMerchandiseService()
    
    private let client = SupabaseClient(
        supabaseURL: URL(string: "https://uwssjvqlsekveqvdkdnj.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV3c3NqdnFsc2VrdmVxdmRrZG5qIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcyMTU5OTksImV4cCI6MjA3Mjc5MTk5OX0.HG6t79U5z8w_f0Qfwgclkxs4aZOfgALbMEwXN9ZTA00",
        options: SupabaseClientOptions(db: .init(schema: "rg10"))
    )
    
    // MARK: - Fetch All Products
    func fetchProducts() async throws -> [DBProduct] {
        let response = try await client
            .from("products")
            .select()
            .execute()
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let products = try decoder.decode([DBProduct].self, from: response.data)
        return products
    }
    
    // MARK: - Fetch Products with Category
    func fetchProductsWithCategory() async throws -> [(product: DBProduct, category: DBCategory?)] {
        let response = try await client
            .from("products")
            .select("*, categories!category_id(*)")
            .execute()
        
        // Parse the joined data
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        // This is a simplified version - you might need to adjust based on actual response structure
        let products = try decoder.decode([DBProduct].self, from: response.data)
        
        // For now, returning products without category joins
        // You'd need to parse the joined data properly based on Supabase response
        return products.map { ($0, nil) }
    }
    
    // MARK: - Fetch Product Sizes for Specific Product
    func fetchProductSizes(for productId: Int) async throws -> [ProductSizeDetail] {
        // Query with joins to get size and type information
        let response = try await client
            .from("product_sizes")
            .select("*, sizes!size_id(*, size_types!size_type_id(*))")
            .eq("product_id", value: productId)
            .execute()
        
        // Parse the response
        let jsonObject = try JSONSerialization.jsonObject(with: response.data)
        guard let jsonArray = jsonObject as? [[String: Any]] else {
            throw SupabaseError.parseError
        }
        
        var productSizes: [ProductSizeDetail] = []
        
        for item in jsonArray {
            guard let id = item["id"] as? Int,
                  let price = item["price"] as? Double else { continue }
            
            // Extract size information
            var sizeName = "Unknown"
            var sizeTypeName: String? = nil
            
            if let sizeData = item["sizes"] as? [String: Any],
               let size = sizeData["size"] as? String {
                sizeName = size
                
                if let sizeTypeNameData = sizeData["size_type_id"] as? Int {
                    sizeTypeName = sizeTypeNameData == 1 ? "Youth" : "Adult"
                }
            }
                        
            let stripePriceId = item["stripe_price_id"] as? String
            
            let sizeDetail = ProductSizeDetail(
                id: id,
                productId: productId,
                sizeName: sizeName,
                sizeType: sizeTypeName ?? "",
                price: price,
                stripePriceId: stripePriceId,
                inStock: true // You might want to add stock tracking
            )
            
            productSizes.append(sizeDetail)
        }
        
        return productSizes
    }
    
    // MARK: - Fetch Categories
    func fetchCategories() async throws -> [DBCategory] {
        let response = try await client
            .from("categories")
            .select()
            .execute()
        
        let categories = try JSONDecoder().decode([DBCategory].self, from: response.data)
        return categories
    }
}

// MARK: - Simplified Models for UI
struct ProductSizeDetail {
    let id: Int
    let productId: Int
    let sizeName: String
    let sizeType: String
    let price: Double
    let stripePriceId: String?
    let inStock: Bool
    
    var displayName: String {
        return "\(sizeName.uppercased()) (\(sizeType.capitalized))"
    }
    
    var formattedPrice: String {
        String(format: "$%.2f", price)
    }
}

// MARK: - Custom Error
enum SupabaseError: Error {
    case parseError
    case noData
}

// MARK: - Updated Merchandise ViewModel
@MainActor
class SupabaseMerchandiseViewModel: ObservableObject {
    @Published var products: [DBProduct] = []
    @Published var filteredProducts: [DBProduct] = []
    @Published var categories: [DBCategory] = []
    @Published var selectedCategory: DBCategory?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    
    private let service = SupabaseMerchandiseService.shared
    
    init() {
        Task {
            await loadProducts()
            await loadCategories()
        }
    }
    
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedProducts = try await service.fetchProducts()
            products = fetchedProducts
            filterProducts()
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
            print("Error loading products: \(error)")
        }
        
        isLoading = false
    }
    
    func loadCategories() async {
        do {
            let fetchedCategories = try await service.fetchCategories()
            categories = fetchedCategories
        } catch {
            print("Error loading categories: \(error)")
        }
    }
    
    func filterProducts() {
        var filtered = products
        
        // Filter by category
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category_id == category.id }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { product in
                product.name.localizedCaseInsensitiveContains(searchText) ||
                product.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        filteredProducts = filtered
    }
    
    func selectCategory(_ category: DBCategory?) {
        selectedCategory = category
        filterProducts()
    }
}

// MARK: - Product Detail ViewModel
@MainActor
class SupabaseProductDetailViewModel: ObservableObject {
    @Published var product: DBProduct
    @Published var productSizes: [ProductSizeDetail] = []
    @Published var selectedSize: ProductSizeDetail?
    @Published var quantity = 1
    @Published var isLoadingSizes = false
    @Published var errorMessage: String?
    
    private let service = SupabaseMerchandiseService.shared
    
    init(product: DBProduct) {
        self.product = product
        Task {
            await loadProductSizes()
        }
    }
    
    func loadProductSizes() async {
        isLoadingSizes = true
        errorMessage = nil
        
        do {
            let sizes = try await service.fetchProductSizes(for: product.id)
            productSizes = sizes
            
            // Auto-select first available size
            if let firstSize = sizes.first {
                selectedSize = firstSize
            }
        } catch {
            errorMessage = "Failed to load sizes: \(error.localizedDescription)"
            print("Error loading product sizes: \(error)")
        }
        
        isLoadingSizes = false
    }
    
    func incrementQuantity() {
        if quantity < 10 {
            quantity += 1
        }
    }
    
    func decrementQuantity() {
        if quantity > 1 {
            quantity -= 1
        }
    }
    
    var canAddToCart: Bool {
        selectedSize != nil && quantity > 0
    }
    
    var currentPrice: Double {
        selectedSize?.price ?? 0
    }
    
    var formattedPrice: String {
        selectedSize?.formattedPrice ?? "$0.00"
    }
    
    var totalPrice: Double {
        currentPrice * Double(quantity)
    }
    
    var formattedTotalPrice: String {
        String(format: "$%.2f", totalPrice)
    }
    
    func openStripeCheckout() {
        guard let paymentLink = product.stripe_payment_link,
              let url = URL(string: paymentLink) else {
            errorMessage = "Payment link not available"
            return
        }
        
        // You can append quantity and size parameters to the URL if needed
        UIApplication.shared.open(url)
    }
}
