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

// MARK: - Database Models
struct DBProduct: Codable, Hashable {
    let id: Int
    let name: String
    let description: String
    let category_id: Int?
    let image_urls: [String]?
    let is_new: Bool
    let is_featured: Bool
    let stripe_product_id: String?
    let stripe_payment_link: String?
    let created_at: String  // Changed to String to handle raw format
    let updated_at: String  // Changed to String to handle raw format
    
    var imageArray: [String] {
        return image_urls ?? []
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: DBProduct, rhs: DBProduct) -> Bool {
        lhs.id == rhs.id
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
    let price: Double
    let stripe_price_id: String?
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
    
    // MARK: - Fetch All Products (Fixed)
    func fetchProducts() async throws -> [DBProduct] {
        let response = try await client
            .from("products")
            .select()
            .execute()
        
        // Don't specify date decoding strategy - let it decode as strings
        let decoder = JSONDecoder()
        let products = try decoder.decode([DBProduct].self, from: response.data)
        return products
    }
    
    // Rest of the methods remain the same...
    func fetchProductSizes(for productId: Int) async throws -> [ProductSizeDetail] {
        let productSizesResponse = try await client
            .from("product_sizes")
            .select("*")
            .eq("product_id", value: productId)
            .execute()
        
        let productSizes = try JSONDecoder().decode([DBProductSize].self, from: productSizesResponse.data)
        
        let sizesResponse = try await client
            .from("sizes")
            .select("*")
            .execute()
        
        let sizes = try JSONDecoder().decode([DBSize].self, from: sizesResponse.data)
        
        let sizesDict = Dictionary(uniqueKeysWithValues: sizes.map { ($0.id, $0) })
        
        var sizeDetails: [ProductSizeDetail] = []
        
        for productSize in productSizes {
            if let size = sizesDict[productSize.size_id] {
                let sizeType = size.size_type_id == 1 ? "Youth" : "Adult"
                
                let detail = ProductSizeDetail(
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
        if sizeType.isEmpty || sizeType == "Unknown" {
            return sizeName.uppercased()
        }
        return "\(sizeName.uppercased()) (\(sizeType))"
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

@MainActor
class SupabaseProductDetailViewModel: ObservableObject {
    @Published var product: DBProduct
    @Published var productSizes: [ProductSizeDetail] = []
    @Published var selectedSize: ProductSizeDetail?
    @Published var quantity = 1
    @Published var isLoadingSizes = true // Start as true
    @Published var errorMessage: String?
    
    private let service = SupabaseMerchandiseService.shared
    
    init(product: DBProduct) {
        self.product = product
    }
    
    func loadProductSizes() async {
        isLoadingSizes = true
        errorMessage = nil
        
        do {
            let sizes = try await service.fetchProductSizes(for: product.id)
            self.productSizes = sizes
            if let firstSize = sizes.first {
                self.selectedSize = firstSize
            }
        } catch {
            self.errorMessage = "Failed to load sizes: \(error.localizedDescription)"
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
        
        UIApplication.shared.open(url)
    }
}
