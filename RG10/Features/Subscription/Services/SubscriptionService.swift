//
//  SubscriptionService.swift
//  RG10
//
//  Created by Moneeb Sayed on 1/17/25.
//

import Foundation
import Combine
import Supabase
import Auth

// MARK: - Subscription Service (Matching Android Implementation)

@MainActor
final class SubscriptionService: ObservableObject {
    static let shared = SubscriptionService()
    
    // MARK: - Published Properties
    
    @Published private(set) var subscriptions: [DBSubscription] = []
    @Published private(set) var userSubscription: DBUserSubscription?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var lastFetchTime: Date?
    
    // MARK: - Private Properties
    
    private let subscriptionAPI = SupabaseSubscriptionAPI.shared
    private let paymentAPI = SupabasePaymentAPI.shared
    private let paymentSheetService = PaymentSheetService.shared
    
    // Caching (matching Android implementation)
    private var cachedSubscriptions: [DBSubscription]?
    private var cachedUserSubscription: DBUserSubscription?
    
    private init() {
        // Initialize with cached data if available
        Task {
            await loadCachedData()
        }
    }
    
    // MARK: - Subscription Plans Management
    
    /// Fetches subscription plans with caching
    func fetchSubscriptions(forceRefresh: Bool = false) async throws -> [DBSubscription] {
        if !forceRefresh, let cached = cachedSubscriptions {
            subscriptions = cached
            return cached
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedSubscriptions = try await subscriptionAPI.fetchSubscriptions()
            
            cachedSubscriptions = fetchedSubscriptions
            subscriptions = fetchedSubscriptions
            isLoading = false
            lastFetchTime = Date()
            
            return fetchedSubscriptions
            
        } catch {
            isLoading = false
            errorMessage = "Unable to load subscription plans. Please try again."
            throw SubscriptionError.fetchFailed(error.localizedDescription)
        }
    }
    
    /// Gets cached subscription plans
    func getCachedSubscriptions() -> [DBSubscription]? {
        return cachedSubscriptions
    }
    
    /// Clears subscription plans cache
    func clearSubscriptionsCache() {
        cachedSubscriptions = nil
        subscriptions.removeAll()
    }
    
    // MARK: - User Subscription Management
    
    /// Fetches user's subscription status
    func fetchUserSubscription(forceRefresh: Bool = false) async throws -> DBUserSubscription? {
        guard let userId = getCurrentUserId() else {
            throw SubscriptionError.userNotAuthenticated
        }
        
        if !forceRefresh, let cached = cachedUserSubscription {
            userSubscription = cached
            return cached
        }
        
        do {
            let fetchedUserSubscription = try await subscriptionAPI.fetchUserSubscription(userId: userId)
            
            cachedUserSubscription = fetchedUserSubscription
            userSubscription = fetchedUserSubscription
            
            return fetchedUserSubscription
            
        } catch {
            throw SubscriptionError.fetchFailed(error.localizedDescription)
        }
    }
    
    /// Checks if user has an active subscription
    func hasActiveSubscription() -> Bool {
        return userSubscription?.subscribed == true
    }
    
    /// Gets remaining sessions for current subscription
    func getRemainingSessions() -> Int {
        return userSubscription?.remaining_bookings ?? 0
    }
    
    /// Gets next renewal date
    func getNextRenewalDate() -> Date? {
        guard let renewalString = userSubscription?.next_renewal_at else { return nil }
        
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: renewalString)
    }
    
    // MARK: - Subscription Purchase Flow
    
    /// Starts subscription purchase flow
    func startSubscription(
        subscription: DBSubscription
    ) async throws -> PaymentSheetData {
        guard let userId = getCurrentUserId() else {
            throw SubscriptionError.userNotAuthenticated
        }
        
        print("🔗 Starting subscription purchase for plan: \(subscription.name)")
        print("🔗 Price ID: \(subscription.stripe_price_id)")
        
        // Create subscription session
        let sessionResponse = try await subscriptionAPI.createSubscriptionSession(
            userId: userId,
            priceId: subscription.stripe_price_id
        )
        
        // Create PaymentSheet data
        let paymentSheetData = PaymentSheetData(
            publishableKey: PaymentConfiguration.stripePublishableKey,
            paymentIntentClientSecret: sessionResponse.paymentIntentClientSecret,
            customerId: sessionResponse.customerId,
            customerEphemeralKeySecret: sessionResponse.ephemeralKeySecret,
            merchantDisplayName: "RG10 Football",
            allowsDelayedPaymentMethods: true
        )
        
        print("✅ Created subscription payment sheet data")
        return paymentSheetData
    }
    
    /// Handles successful subscription payment
    func handleSubscriptionSuccess(subscription: DBSubscription) async {
        print("✅ Subscription payment successful for: \(subscription.name)")
        
        // Refresh user subscription status
        do {
            try await fetchUserSubscription(forceRefresh: true)
            print("✅ User subscription status refreshed")
        } catch {
            print("❌ Failed to refresh user subscription: \(error)")
        }
    }
    
    /// Handles failed subscription payment
    func handleSubscriptionFailure(subscription: DBSubscription, error: String) async {
        print("❌ Subscription payment failed for: \(subscription.name), error: \(error)")
        
        // Abort the subscription intent
        guard let userId = getCurrentUserId() else { return }
        
        do {
            // Note: We would need the subscription ID from the session response
            // For now, we'll just log the failure
            print("⚠️ Subscription intent should be aborted")
        } catch {
            print("❌ Failed to abort subscription intent: \(error)")
        }
    }
    
    // MARK: - Subscription Cancellation
    
    /// Cancels an active subscription
    func cancelSubscription() async throws -> CancelSubscriptionResponse {
        guard let userId = getCurrentUserId(),
              let stripeSubscriptionId = userSubscription?.stripe_subscription_id else {
            throw SubscriptionError.userNotAuthenticated
        }
        
        print("🔗 Cancelling subscription for user: \(userId)")
        
        let response = try await subscriptionAPI.cancelSubscription(
            userId: userId,
            stripeSubscriptionId: stripeSubscriptionId
        )
        
        if response.success {
            // Refresh user subscription status
            try await fetchUserSubscription(forceRefresh: true)
            print("✅ Subscription cancelled successfully")
        }
        
        return response
    }
    
    // MARK: - Helper Methods
    
    /// Gets current user ID from AuthManager
    private func getCurrentUserId() -> String? {
        guard let session = AuthManager.shared.session else { return nil }
        return session.user.id.uuidString
    }
    
    /// Loads cached data on init
    private func loadCachedData() async {
        // In a real implementation, you might load from UserDefaults or Core Data
        // For now, we'll just initialize empty
    }
    
    /// Clears all cached data
    func clearCache() {
        cachedSubscriptions = nil
        cachedUserSubscription = nil
        subscriptions.removeAll()
        userSubscription = nil
        errorMessage = nil
        lastFetchTime = nil
    }
    
    /// Refreshes all subscription data
    func refreshAll(email: String? = nil) async throws {
        try await fetchSubscriptions(forceRefresh: true)
        try await fetchUserSubscription(forceRefresh: true)
    }
}
