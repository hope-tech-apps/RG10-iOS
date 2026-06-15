//
//  MerchandiseViewModel.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/10/25.
//
//  Drives the native store grid backed by the live Flite Sports
//  Shopify collection feed.
//

import SwiftUI
import Combine

class MerchandiseViewModel: ObservableObject {
    @Published var products: [ShopifyProduct] = []
    @Published var filteredProducts: [ShopifyProduct] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""

    private let service = MerchandiseService.shared

    init() {
        MemoryMonitor.shared.objectInitialized("MerchandiseViewModel")
        Task {
            await loadProducts()
        }
    }

    deinit {
        MemoryMonitor.shared.objectDeinitialized("MerchandiseViewModel")
    }

    func loadProducts() async {
        isLoading = true
        errorMessage = nil

        do {
            let fetchedProducts = try await service.fetchProducts()
            products = fetchedProducts
            filterProducts()
        } catch {
            errorMessage = "We couldn't load the store right now. Please try again."
            print("Error loading products: \(error)")
        }

        isLoading = false
    }

    func filterProducts() {
        if searchText.isEmpty {
            filteredProducts = products
            return
        }

        filteredProducts = products.filter { product in
            product.title.localizedCaseInsensitiveContains(searchText) ||
            product.productType.localizedCaseInsensitiveContains(searchText)
        }
    }
}
