//
//  MerchandiseViewModel.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/10/25.
//

import SwiftUI
import Combine

class MerchandiseViewModel: ObservableObject {
    @Published var products: [Merchandise] = []
    @Published var filteredProducts: [Merchandise] = []
    @Published var categories: [Category] = []
    @Published var selectedCategory: Category?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    
    private let service = MerchandiseService.shared
    
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
    
    func selectCategory(_ category: Category?) {
        selectedCategory = category
        filterProducts()
    }
}
