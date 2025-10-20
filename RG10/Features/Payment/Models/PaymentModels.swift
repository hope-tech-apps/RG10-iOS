//
//  PaymentModels.swift
//  RG10
//
//  Created by Moneeb Sayed on 1/17/25.
//

import Foundation

// MARK: - Payment Models (Matching Kotlin Implementation)

/// Response from creating a booking payment intent
struct BookingIntentResponse: Codable, Sendable {
    let free: Bool
    let bookingUid: String
    let paymentIntentClientSecret: String?
    let customerId: String?
    let ephemeralKeySecret: String?
    let amount: Long?
    let currency: String?
    
    enum CodingKeys: String, CodingKey {
        case free
        case bookingUid
        case paymentIntentClientSecret = "payment_intent_client_secret"
        case customerId = "customer_id"
        case ephemeralKeySecret = "ephemeral_key_secret"
        case amount
        case currency
    }
}

// MARK: - Payment Sheet Data

/// Data required to present Stripe PaymentSheet
struct PaymentSheetData: Sendable, Equatable {
    let publishableKey: String
    let paymentIntentClientSecret: String
    let customerId: String?
    let customerEphemeralKeySecret: String?
    let merchantDisplayName: String
    let allowsDelayedPaymentMethods: Bool
    
    init(
        publishableKey: String,
        paymentIntentClientSecret: String,
        customerId: String? = nil,
        customerEphemeralKeySecret: String? = nil,
        merchantDisplayName: String,
        allowsDelayedPaymentMethods: Bool = false
    ) {
        self.publishableKey = publishableKey
        self.paymentIntentClientSecret = paymentIntentClientSecret
        self.customerId = customerId
        self.customerEphemeralKeySecret = customerEphemeralKeySecret
        self.merchantDisplayName = merchantDisplayName
        self.allowsDelayedPaymentMethods = allowsDelayedPaymentMethods
    }
}

// MARK: - Payment States

/// States for payment flow management
enum PaymentState: Sendable {
    case idle
    case processing(String)
    case paymentSheetReady(PaymentSheetData)
    case completed(String?)
    case cancelled(String?)
    case error(String)
}

/// States for booking flow management
enum BookingState: Sendable, Equatable {
    case idle
    case processing(String)
    case paymentSheetReady(PaymentSheetData)
    case completed(String?)
    case cancelled(String?)
    case error(String)
}

// MARK: - Payment Errors

enum PaymentError: LocalizedError, Sendable {
    case invalidConfiguration
    case missingPaymentIntent
    case networkError(Error)
    case paymentFailed(String)
    case userCancelled
    case subscriptionCreationFailed(String)
    case bookingCreationFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidConfiguration:
            return "Invalid payment configuration"
        case .missingPaymentIntent:
            return "Missing payment intent"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .paymentFailed(let message):
            return "Payment failed: \(message)"
        case .userCancelled:
            return "Payment was cancelled by user"
        case .subscriptionCreationFailed(let message):
            return "Subscription creation failed: \(message)"
        case .bookingCreationFailed(let message):
            return "Booking creation failed: \(message)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .networkError:
            return "Please check your internet connection and try again"
        case .paymentFailed:
            return "Please try a different payment method"
        case .userCancelled:
            return nil
        case .subscriptionCreationFailed, .bookingCreationFailed:
            return "Please contact support if this issue persists"
        default:
            return "Please try again"
        }
    }
}

// MARK: - Type Aliases

typealias Long = Int64
