//
//  SubscriptionFlowCoordinator.swift
//  RG10
//
//  Created by Moneeb Sayed on 1/17/25.
//

import Foundation
import SwiftUI
import StripePaymentSheet
import Combine

// MARK: - Subscription Flow Coordinator (Matching Android Implementation)

@MainActor
final class SubscriptionFlowCoordinator: ObservableObject {
    // MARK: - Published Properties
    
    @Published private(set) var state: SubscriptionFlowState = .idle
    @Published private(set) var result: SubscriptionFlowResult?
    
    // MARK: - Private Properties
    
    private let subscriptionService = SubscriptionService.shared
    private let paymentSheetService = PaymentSheetService.shared
    
    // MARK: - Public Methods
    
    /// Handles subscription flow events
    func handleEvent(_ event: SubscriptionFlowEvent) {
        switch event {
        case .loadPlans:
            loadSubscriptionPlans()
        case .selectPlan(let subscription):
            startSubscriptionPurchase(subscription)
        case .paymentCompleted:
            handlePaymentCompleted()
        case .paymentCancelled:
            handlePaymentCancelled()
        case .paymentFailed(let error):
            handlePaymentFailed(error)
        case .retry:
            retryLastAction()
        case .reset:
            resetFlow()
        }
    }
    
    // MARK: - Computed Properties
    
    /// Current PaymentSheet for SwiftUI integration
    var currentPaymentSheet: PaymentSheet? {
        if case .paymentSheetReady(_, let paymentData) = state {
            do {
                return try paymentSheetService.createSubscriptionPaymentSheetSync(with: paymentData)
            } catch {
                print("Failed to create PaymentSheet: \(error)")
                return nil
            }
        }
        return nil
    }
    
    /// Whether the flow is currently processing
    var isProcessing: Bool {
        switch state {
        case .loadingPlans, .creatingSubscription, .processingPayment:
            return true
        default:
            return false
        }
    }
    
    /// Whether payment sheet should be presented
    var shouldPresentPaymentSheet: Bool {
        if case .paymentSheetReady = state {
            return true
        }
        return false
    }
    
    // MARK: - Private Methods
    
    /// Loads subscription plans from Supabase
    private func loadSubscriptionPlans() {
        state = .loadingPlans
        
        Task {
            do {
                let subscriptions = try await subscriptionService.fetchSubscriptions()
                await MainActor.run {
                    self.state = .plansLoaded(subscriptions)
                }
            } catch {
                await MainActor.run {
                    self.state = .error("Failed to load subscription plans: \(error.localizedDescription)")
                }
            }
        }
    }
    
        /// Starts subscription purchase flow
        private func startSubscriptionPurchase(_ subscription: DBSubscription) {
            // Prevent duplicate calls
            switch state {
            case .idle, .plansLoaded, .error:
                break // Allow these states
            default:
                print("⚠️ Subscription purchase already in progress, ignoring duplicate call")
                return
            }
        
        state = .creatingSubscription(subscription)
        
        Task {
            do {
                let paymentSheetData = try await subscriptionService.startSubscription(subscription: subscription)
                
                await MainActor.run {
                    self.state = .paymentSheetReady(subscription, paymentSheetData)
                }
            } catch {
                await MainActor.run {
                    self.state = .error("Failed to create subscription session: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Handles successful payment completion
    private func handlePaymentCompleted() {
        guard case .paymentSheetReady(let subscription, _) = state else {
            state = .error("Invalid state for payment completion")
            return
        }
        
        state = .processingPayment(subscription)
        
        Task {
            await subscriptionService.handleSubscriptionSuccess(subscription: subscription)
            
            await MainActor.run {
                self.state = .completed(subscription)
                self.result = .success(subscription: subscription)
            }
        }
    }
    
    /// Handles payment cancellation
    private func handlePaymentCancelled() {
        guard case .paymentSheetReady(let subscription, _) = state else {
            state = .error("Invalid state for payment cancellation")
            return
        }
        
        Task {
            await subscriptionService.handleSubscriptionFailure(subscription: subscription, error: "User cancelled payment")
            
            await MainActor.run {
                self.state = .idle
                self.result = .cancelled
            }
        }
    }
    
    /// Handles payment failure
    private func handlePaymentFailed(_ error: String) {
        guard case .paymentSheetReady(let subscription, _) = state else {
            state = .error("Invalid state for payment failure")
            return
        }
        
        Task {
            await subscriptionService.handleSubscriptionFailure(subscription: subscription, error: error)
            
            await MainActor.run {
                self.state = .error("Payment failed: \(error)")
                self.result = .failure(error: error)
            }
        }
    }
    
    /// Retries the last action
    private func retryLastAction() {
        switch state {
        case .error:
            // Retry loading plans
            loadSubscriptionPlans()
        default:
            break
        }
    }
    
    /// Resets the flow to initial state
    private func resetFlow() {
        state = .idle
        result = nil
    }
}

// MARK: - Subscription Flow View Model

@MainActor
final class SubscriptionFlowViewModel: ObservableObject {
    @Published private(set) var coordinator = SubscriptionFlowCoordinator()
    
    // MARK: - Computed Properties
    
    var subscriptions: [DBSubscription] {
        if case .plansLoaded(let subscriptions) = coordinator.state {
            return subscriptions
        }
        return []
    }
    
    var isLoading: Bool {
        coordinator.isProcessing
    }
    
    var errorMessage: String? {
        if case .error(let message) = coordinator.state {
            return message
        }
        return nil
    }
    
    var shouldPresentPaymentSheet: Bool {
        coordinator.shouldPresentPaymentSheet
    }
    
    var currentPaymentSheet: PaymentSheet? {
        coordinator.currentPaymentSheet
    }
    
    // MARK: - Public Methods
    
    func loadPlans() {
        coordinator.handleEvent(.loadPlans)
    }
    
    func selectPlan(_ subscription: DBSubscription) {
        coordinator.handleEvent(.selectPlan(subscription))
    }
    
    func handlePaymentCompleted() {
        coordinator.handleEvent(.paymentCompleted)
    }
    
    func handlePaymentCancelled() {
        coordinator.handleEvent(.paymentCancelled)
    }
    
    func handlePaymentFailed(_ error: String) {
        coordinator.handleEvent(.paymentFailed(error))
    }
    
    func retry() {
        coordinator.handleEvent(.retry)
    }
    
    func reset() {
        coordinator.handleEvent(.reset)
    }
}
