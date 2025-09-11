//
//  MerchandiseDetailViewModel.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/10/25.
//

import SwiftUI
import Combine

@MainActor
class MerchandiseDetailViewModel: ObservableObject {
    @Published var product: Merchandise
    @Published var productSizes: [SizeDetail] = []
    @Published var selectedSize: SizeDetail?
    @Published var quantity = 1
    @Published var isLoadingSizes = true // Start as true
    @Published var errorMessage: String?
    
    private let service = MerchandiseService.shared
    
    init(product: Merchandise) {
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
