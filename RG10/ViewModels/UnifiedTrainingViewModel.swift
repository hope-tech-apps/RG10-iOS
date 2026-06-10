//
//  UnifiedTrainingViewModel.swift
//  RG10
//
//  Created by Moneeb Sayed on 1/17/25.
//

import Foundation
import Combine
import StripePaymentSheet

// MARK: - Unified Training View Model (Following Android Approach)

@MainActor
final class UnifiedTrainingViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published private(set) var subscriptionPlans: [DBSubscription] = []
    @Published private(set) var userSubscription: DBUserSubscription?
    @Published private(set) var availableCamps: [CampData] = []
    @Published private(set) var isLoadingPlans = false
    @Published private(set) var plansErrorMessage: String?
           @Published var showSubscriptionManagement = false
    
    // MARK: - Payment Sheet Properties
    
    @Published private(set) var shouldPresentPaymentSheet = false
    @Published private(set) var currentPaymentSheet: PaymentSheet?
    
    // MARK: - Private Properties
    
    private let subscriptionService = SubscriptionService.shared
    private let subscriptionFlowCoordinator = SubscriptionFlowCoordinator()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    
    var hasActiveSubscription: Bool {
        return userSubscription?.subscribed == true
    }
    
    // MARK: - Initialization
    
    init() {
        MemoryMonitor.shared.objectInitialized("UnifiedTrainingViewModel")
        setupBindings()
    }
    
    deinit {
        MemoryMonitor.shared.objectDeinitialized("UnifiedTrainingViewModel")
    }
    
    // MARK: - Public Methods
    
    func loadInitialData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await self.loadSubscriptionPlans()
            }
            
            group.addTask {
                await self.loadUserSubscription()
            }
            
            group.addTask {
                await self.loadCamps()
            }
        }
    }
    
    func loadSubscriptionPlans() async {
        isLoadingPlans = true
        plansErrorMessage = nil
        
        do {
            let plans = try await subscriptionService.fetchSubscriptions()
            subscriptionPlans = plans
            isLoadingPlans = false
        } catch {
            isLoadingPlans = false
            plansErrorMessage = "Unable to load training plans. Please try again."
            print("Failed to load subscription plans: \(error)")
        }
    }
    
    func loadUserSubscription() async {
        do {
            userSubscription = try await subscriptionService.fetchUserSubscription()
        } catch {
            print("Failed to load user subscription: \(error)")
        }
    }
    
    func loadCamps() async {
        // Load camps data - this would typically come from your backend
        // For now, we'll use empty array as in the original code
        availableCamps = []
    }
    
    func refreshSubscriptionStatus() async {
        print("🔄 Refreshing subscription status in UnifiedTrainingViewModel")
        await loadUserSubscription()
    }
    
    func selectPlan(_ plan: DBSubscription) {
        subscriptionFlowCoordinator.handleEvent(.selectPlan(plan))
    }
    
    func handlePaymentCompleted() {
        subscriptionFlowCoordinator.handleEvent(.paymentCompleted)
        
        // Refresh subscription status
        Task {
            await loadUserSubscription()
        }
    }
    
    func handlePaymentCancelled() {
        subscriptionFlowCoordinator.handleEvent(.paymentCancelled)
    }
    
    func handlePaymentFailed(_ error: String) {
        subscriptionFlowCoordinator.handleEvent(.paymentFailed(error))
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        // Bind to subscription flow coordinator
        subscriptionFlowCoordinator.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.updatePaymentSheetState(state)
            }
            .store(in: &cancellables)
    }
    
    private func updatePaymentSheetState(_ state: SubscriptionFlowState) {
        switch state {
        case .paymentSheetReady(_, let paymentData):
            do {
                let paymentSheet = try PaymentSheetService.shared.createSubscriptionPaymentSheetSync(with: paymentData)
                currentPaymentSheet = paymentSheet
                shouldPresentPaymentSheet = true
            } catch {
                print("Failed to create payment sheet: \(error)")
                plansErrorMessage = "Failed to prepare payment. Please try again."
            }
            
        case .completed:
            shouldPresentPaymentSheet = false
            currentPaymentSheet = nil
            
        case .error(let message):
            shouldPresentPaymentSheet = false
            currentPaymentSheet = nil
            plansErrorMessage = message
            
        default:
            break
        }
    }
}

// CampData is defined in TrainingViewModel.swift
