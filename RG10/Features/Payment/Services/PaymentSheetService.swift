//
//  PaymentSheetService.swift
//  RG10
//
//  Created by Moneeb Sayed on 1/17/25.
//

import Foundation
import Combine
import UIKit
import SwiftUI
import StripePaymentSheet
import Stripe

// MARK: - Payment Sheet Service

@MainActor
final class PaymentSheetService: ObservableObject {
    static let shared = PaymentSheetService()
    
    // MARK: - Configuration
    
    /// Stripe publishable key - should be moved to secure configuration
    static let STRIPE_PUBLISHABLE_KEY = PaymentConfiguration.stripePublishableKey
    
    // MARK: - Properties
    
    @Published private(set) var isConfigured = false
    @Published private(set) var currentPaymentSheet: PaymentSheet?
    
    private init() {
        configureStripe()
    }
    
    // MARK: - Configuration
    
    private func configureStripe() {
        // Only configure if we have a valid key
        if !Self.STRIPE_PUBLISHABLE_KEY.isEmpty && 
           !Self.STRIPE_PUBLISHABLE_KEY.contains("your_publishable_key_here") {
            StripeAPI.defaultPublishableKey = Self.STRIPE_PUBLISHABLE_KEY
            isConfigured = true
        } else {
            print("⚠️ Stripe not configured. Please add your publishable key to PaymentConfiguration.swift")
            isConfigured = false
        }
    }
    
    // MARK: - Payment Sheet Creation
    
    /// Creates a PaymentSheet for subscription payments
    func createSubscriptionPaymentSheet(
        with data: PaymentSheetData
    ) async throws -> PaymentSheet {
        guard isConfigured else {
            throw PaymentError.invalidConfiguration
        }
        
        // Configure customer if provided
        var customerConfiguration: PaymentSheet.CustomerConfiguration?
        if let customerId = data.customerId,
           let ephemeralKeySecret = data.customerEphemeralKeySecret {
            customerConfiguration = PaymentSheet.CustomerConfiguration(
                id: customerId,
                ephemeralKeySecret: ephemeralKeySecret
            )
        }
        
        // Create PaymentSheet configuration
        var configuration = PaymentSheet.Configuration()
        configuration.merchantDisplayName = PaymentConfiguration.merchantDisplayName
        configuration.customer = customerConfiguration
        configuration.allowsDelayedPaymentMethods = data.allowsDelayedPaymentMethods
        configuration.appearance = createAppearance()
        
        // Create PaymentSheet
        let paymentSheet = PaymentSheet(
            paymentIntentClientSecret: data.paymentIntentClientSecret,
            configuration: configuration
        )
        
        currentPaymentSheet = paymentSheet
        return paymentSheet
    }
    
    /// Creates a PaymentSheet for booking payments
    func createBookingPaymentSheet(
        with data: PaymentSheetData
    ) async throws -> PaymentSheet {
        return try await createSubscriptionPaymentSheet(with: data)
    }
    
    /// Creates a PaymentSheet synchronously (for SwiftUI .paymentSheet modifier)
    func createSubscriptionPaymentSheetSync(
        with data: PaymentSheetData
    ) throws -> PaymentSheet {
        guard isConfigured else {
            throw PaymentError.invalidConfiguration
        }
        
        // Configure customer if provided
        var customerConfiguration: PaymentSheet.CustomerConfiguration?
        if let customerId = data.customerId,
           let ephemeralKeySecret = data.customerEphemeralKeySecret {
            customerConfiguration = PaymentSheet.CustomerConfiguration(
                id: customerId,
                ephemeralKeySecret: ephemeralKeySecret
            )
        }
        
        // Create PaymentSheet configuration
        var configuration = PaymentSheet.Configuration()
        configuration.merchantDisplayName = PaymentConfiguration.merchantDisplayName
        configuration.customer = customerConfiguration
        configuration.allowsDelayedPaymentMethods = data.allowsDelayedPaymentMethods
        configuration.appearance = createAppearance()
        
        // Create PaymentSheet
        let paymentSheet = PaymentSheet(
            paymentIntentClientSecret: data.paymentIntentClientSecret,
            configuration: configuration
        )
        
        currentPaymentSheet = paymentSheet
        return paymentSheet
    }
    
    // MARK: - Payment Sheet Presentation
    
    /// Presents the PaymentSheet from a view controller
    func presentPaymentSheet(
        from viewController: UIViewController,
        completion: @escaping @MainActor (PaymentSheetResult) -> Void
    ) async {
        guard let paymentSheet = currentPaymentSheet else {
            await completion(.failed(error: PaymentError.missingPaymentIntent))
            return
        }
        
        await withCheckedContinuation { continuation in
            paymentSheet.present(from: viewController) { result in
                Task { @MainActor in
                    completion(result)
                    continuation.resume()
                }
            }
        }
    }
    
    // MARK: - Payment Sheet Result Handling
    
    /// Handles PaymentSheet result and returns appropriate state
    func handlePaymentResult(
        _ result: PaymentSheetResult,
        successMessage: String? = nil
    ) -> PaymentState {
        switch result {
        case .completed:
            return .completed(successMessage ?? "Payment completed successfully")
            
        case .canceled:
            return .cancelled("Payment was cancelled")
            
        case .failed(let error):
            return .error("Payment failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Cleanup
    
    func clearCurrentPaymentSheet() {
        currentPaymentSheet = nil
    }
    
    // MARK: - Appearance Configuration
    
    private func createAppearance() -> PaymentSheet.Appearance {
        var appearance = PaymentSheet.Appearance()
        
        // Configure colors to match RG10 branding
        appearance.colors.primary = UIColor(AppConstants.Colors.primaryRed)
        appearance.colors.background = UIColor.systemBackground
        appearance.colors.componentBackground = UIColor.secondarySystemBackground
        appearance.colors.componentBorder = UIColor.systemGray4
        appearance.colors.componentDivider = UIColor.systemGray4
        appearance.colors.text = UIColor.label
        appearance.colors.textSecondary = UIColor.secondaryLabel
        appearance.colors.componentText = UIColor.label
        
        return appearance
    }
}

// MARK: - PaymentSheet Result Extension
// Note: Removed Equatable conformance to avoid warning about extending imported types
// If you need equality comparison, implement it in your own wrapper type

extension PaymentSheetResult {
    var isSuccess: Bool {
        if case .completed = self {
            return true
        }
        return false
    }
    
    var isFailure: Bool {
        if case .failed = self {
            return true
        }
        return false
    }
    
    var isCancelled: Bool {
        if case .canceled = self {
            return true
        }
        return false
    }
}
