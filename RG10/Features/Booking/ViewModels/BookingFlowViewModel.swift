//
//  BookingFlowViewModel.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/17/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class BookingFlowViewModel: ObservableObject {
    @Published private(set) var sessionType: BookingSessionType = .single
    @Published private(set) var selectedCoach: Coach?
    @Published private(set) var selectedGroupConfig: BookingConfig?
    @Published private(set) var coaches: [Coach] = []
    @Published private(set) var groupConfigs: [BookingConfig] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published var showingWebView = false
    @Published var showingPaymentSheet = false
    @Published var showingSuccessDialog = false
    @Published var showingErrorDialog = false
    
    let coordinator = BookingFlowCoordinator.shared
    private let coachViewModel = CoachViewModel.shared
    private let configService = BookingConfigService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        loadCoaches()
        loadBookingConfigs()
    }
    
    // MARK: - Public Methods
    
    func selectSessionType(_ type: BookingSessionType) {
        sessionType = type
        selectedGroupConfig = nil // Reset group config when changing session type
    }
    
    func selectGroupConfig(_ config: BookingConfig) {
        selectedGroupConfig = config
    }
    
    func selectCoach(_ coach: Coach) {
        selectedCoach = coach
    }
    
    func startBooking() {
        guard let coach = selectedCoach else {
            errorMessage = "Please select a coach"
            return
        }
        
        // For group sessions, ensure a group config is selected
        if sessionType == .group && selectedGroupConfig == nil {
            errorMessage = "Please select a group size"
            return
        }
        
        coordinator.handleEvent(.startBooking(sessionType: sessionType, coach: coach))
    }
    
    func dismissWebView() {
        coordinator.handleEvent(.webViewDismissed)
    }
    
    func handleSuccessUrlDetected(_ queryParams: [String: String]) {
        coordinator.handleEvent(.successUrlDetected(queryParams))
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
        selectedCoach = nil
        errorMessage = nil
    }
    
    func dismissSuccessDialog() {
        showingSuccessDialog = false
        reset()
    }
    
    func dismissErrorDialog() {
        showingErrorDialog = false
        errorMessage = nil
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        // Bind coordinator state to view model
        coordinator.$state
            .sink { [weak self] state in
                self?.updateState(state)
            }
            .store(in: &cancellables)
        
        // Bind coordinator result to view model
        coordinator.$result
            .sink { [weak self] result in
                self?.handleResult(result)
            }
            .store(in: &cancellables)
    }
    
    private func updateState(_ state: BookingFlowState) {
        switch state {
        case .idle:
            isLoading = false
            showingWebView = false
            showingPaymentSheet = false
            
        case .loadingConfigs:
            isLoading = true
            errorMessage = nil
            
        case .webViewPresented:
            isLoading = false
            showingWebView = true
            errorMessage = nil
            
        case .webViewDismissing:
            isLoading = false
            showingWebView = false
            errorMessage = nil
            
        case .processingPayment:
            isLoading = true
            showingWebView = false // WebView should be dismissed by now
            
        case .paymentSheetReady:
            isLoading = false
            showingPaymentSheet = true
            
        case .completed:
            isLoading = false
            showingPaymentSheet = false
            showingSuccessDialog = true
            
        case .cancelled:
            isLoading = false
            showingWebView = false
            showingPaymentSheet = false
            
        case .error(_, let message):
            isLoading = false
            showingWebView = false
            showingPaymentSheet = false
            errorMessage = message
            showingErrorDialog = true
        }
    }
    
    private func handleResult(_ result: BookingFlowResult?) {
        guard let result = result else { return }
        
        if result.success {
            // Success is handled by the completed state
        } else {
            errorMessage = result.error
            showingErrorDialog = true
        }
    }
    
    private func loadCoaches() {
        coachViewModel.loadCoaches()
        coaches = coachViewModel.coaches
    }
    
    private func loadBookingConfigs() {
        Task {
            do {
                try await configService.loadConfigs()
                groupConfigs = configService.getGroupConfigs()
            } catch {
                errorMessage = "Failed to load booking options: \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - Computed Properties

extension BookingFlowViewModel {
    var canStartBooking: Bool {
        guard let coach = selectedCoach, !isLoading else { return false }
        
        // For group sessions, also check if a group config is selected
        if sessionType == .group {
            return selectedGroupConfig != nil
        }
        
        return true
    }
    
    var sessionTypeOptions: [BookingSessionType] {
        [.single, .group]
    }
    
    var sessionTypeDisplayName: String {
        switch sessionType {
        case .single:
            return "Single Session"
        case .group:
            return "Group Session"
        }
    }
    
    var selectedCoachName: String {
        selectedCoach?.name ?? "Select Coach"
    }
    
    var loadingMessage: String {
        switch coordinator.state {
        case .loadingConfigs:
            return "Loading booking options..."
        case .processingPayment:
            return "Setting up payment..."
        default:
            return "Loading..."
        }
    }
}
