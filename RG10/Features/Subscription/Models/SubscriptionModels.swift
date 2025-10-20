//
//  SubscriptionModels.swift
//  RG10
//
//  Created by Moneeb Sayed on 1/17/25.
//

import Foundation

// MARK: - Subscription Plan Models (Matching Android)

/// Database subscription plan model
struct DBSubscription: Codable, Identifiable, Equatable {
    let id: Int
    let name: String                    // "Premium Plan"
    let price: Double                  // 29.99
    let included_sessions: Int         // 4 sessions per month
    let stripe_product_link: String    // Stripe product URL
    let stripe_price_id: String       // "price_1S8XAi2MsIjS8n0F..."
    let subtitle: String              // "Perfect for serious players"
    let focus: String                 // "Advanced training"
    let ideal_for: String             // "Competitive players"
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case price
        case included_sessions
        case stripe_product_link
        case stripe_price_id
        case subtitle
        case focus
        case ideal_for
    }
}

/// User subscription status model
struct DBUserSubscription: Codable {
    let user_id: String
    let subscribed: Bool              // Active subscription status
    let subscribed_at: String         // When subscription started
    let renewed_at: String            // Last renewal date
    let cancel_at_period_end: Bool    // Scheduled for cancellation
    let next_renewal_at: String       // Next billing date
    let subscription_id: Int           // Internal subscription ID
    let remaining_bookings: Int       // Sessions remaining this period
    let stripe_customer_id: String    // Stripe customer ID
    let stripe_subscription_id: String // Stripe subscription ID
    
    enum CodingKeys: String, CodingKey {
        case user_id
        case subscribed
        case subscribed_at
        case renewed_at
        case cancel_at_period_end
        case next_renewal_at
        case subscription_id
        case remaining_bookings
        case stripe_customer_id
        case stripe_subscription_id
    }
}

// MARK: - Subscription API Response Models

/// Response from billing-create-subscription-session edge function
struct CreateSubscriptionIntentResponse: Codable {
    let kind: String                        // "payment_intent"
    let subscriptionId: String              // Stripe subscription ID
    let customerId: String                 // Stripe customer ID
    let ephemeralKeySecret: String        // Stripe ephemeral key
    let paymentIntentClientSecret: String  // Stripe client secret
    let amount: Int                        // Amount in cents
    let currency: String                   // Currency code (e.g., "usd")
    
    enum CodingKeys: String, CodingKey {
        case kind
        case subscriptionId = "subscription_id"
        case customerId = "customer_id"
        case ephemeralKeySecret = "ephemeral_key_secret"
        case paymentIntentClientSecret = "payment_intent_client_secret"
        case amount
        case currency
    }
}


/// Response from cancel-subscription edge function
struct CancelSubscriptionResponse: Codable {
    let success: Bool
    let message: String
    let cancelledAt: String?
    
    enum CodingKeys: String, CodingKey {
        case success
        case message
        case cancelledAt = "cancelled_at"
    }
}

/// Response from abort-subscription-intent edge function
struct AbortSubscriptionResponse: Codable {
    let success: Bool
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case success
        case message
    }
}

// MARK: - Subscription Flow Models

/// Subscription flow state
enum SubscriptionFlowState: Equatable {
    case idle
    case loadingPlans
    case plansLoaded([DBSubscription])
    case creatingSubscription(DBSubscription)
    case paymentSheetReady(DBSubscription, PaymentSheetData)
    case processingPayment(DBSubscription)
    case completed(DBSubscription)
    case error(String)
}

/// Subscription flow event
enum SubscriptionFlowEvent: Sendable {
    case loadPlans
    case selectPlan(DBSubscription)
    case paymentCompleted
    case paymentCancelled
    case paymentFailed(String)
    case retry
    case reset
}

/// Subscription flow result
enum SubscriptionFlowResult: Sendable, Equatable {
    case success(subscription: DBSubscription)
    case failure(error: String)
    case cancelled
}

// MARK: - Subscription Errors

enum SubscriptionError: Error, LocalizedError {
    case fetchFailed(String)
    case paymentFailed(String)
    case subscriptionCreationFailed(String)
    case invalidConfiguration
    case networkError(Error)
    case userNotAuthenticated
    
    var errorDescription: String? {
        switch self {
        case .fetchFailed(let message):
            return "Failed to fetch subscriptions: \(message)"
        case .paymentFailed(let message):
            return "Payment failed: \(message)"
        case .subscriptionCreationFailed(let message):
            return "Subscription creation failed: \(message)"
        case .invalidConfiguration:
            return "Invalid subscription configuration"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .userNotAuthenticated:
            return "User not authenticated"
        }
    }
}
