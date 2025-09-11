//
//  TrainingViewModel.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/4/25.
//

import SwiftUI
import Combine

// MARK: - Main Training View Model
class TrainingViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isPremium: Bool
    @Published var showUpgradeSheet = false
    @Published var showTrainingPackages = false
    @Published var availableCamps: [CampData] = []
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let userDefaults = UserDefaults.standard
    private let navigationManager = NavigationManager.shared
    private let registrationURL = "https://www.oasyssports.com/RG10Football/global-login.cfm"

    // MARK: - Initialization
    init() {
        self.isPremium = userDefaults.bool(forKey: "isPremium")
        loadCamps()
        setupBindings()
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        // Sync isPremium changes to UserDefaults
        $isPremium
            .dropFirst() // Skip initial value
            .sink { [weak self] value in
                self?.userDefaults.set(value, forKey: "isPremium")
            }
            .store(in: &cancellables)
    }
    
    private func loadCamps() {
        // In a real app, this would fetch from an API or database
        // For now, using static data
//        availableCamps = [
//            CampData(
//                image: AppConstants.Images.campOne,
//                title: "2025 Spring Break\nSoccer Camp",
//                dates: "April 14th - 18th, 2025",
//                hasCheckmark: false
//            ),
//            CampData(
//                image: AppConstants.Images.soccerBackground,
//                title: "2025 Spring Break\nSoccer Camp",
//                dates: "April 14th - 18th, 2025",
//                hasCheckmark: false
//            )
//        ]
        
        // Uncomment to test empty state
        // availableCamps = []
    }
    
    // MARK: - Public Methods
    func openRegistration() {
        if let url = URL(string: registrationURL) {
            UIApplication.shared.open(url)
        }
    }
        
    func openTrainingPackages() {
        navigationManager.navigate(to: .trainingPackages, in: .training)
    }

    func openUpgradeSheet() {
        showUpgradeSheet = true
    }
    
    func dismissUpgradeSheet() {
        showUpgradeSheet = false
    }
    
    func dismissTrainingPackages() {
        showTrainingPackages = false
    }
    
    func togglePremium() {
        isPremium.toggle()
    }
    
    func requestCampNotification() {
        // Implement notification signup logic
        print("User requested notification for upcoming camps")
    }
}

// MARK: - Training Packages View Model
class TrainingPackagesViewModel: ObservableObject {
    @Published var expandedPackage: String? = nil
    @Published var packages: [TrainingPackage] = []
    
    private let registrationURL = "https://www.oasyssports.com/RG10Football/global-login.cfm"
    
    init() {
        loadPackages()
    }
    
    private func loadPackages() {
        packages = [
            TrainingPackage(
                id: "starter",
                title: "Starter Package",
                subtitle: "Foundation Skills Training",
                price: "$330/month",
                sessions: "4 sessions per month (1 per week)",
                focus: "Core skill development – dribbling, passing, ball control, and shooting fundamentals.",
                duration: "1-hour sessions",
                idealFor: "Beginners or younger players looking to build a strong foundation.",
                color: AppConstants.Colors.primaryRed
            ),
            TrainingPackage(
                id: "advanced",
                title: "Advanced Skills Package",
                subtitle: "Game Readiness Training",
                price: "$655/month",
                sessions: "8 sessions per month (2 per week)",
                focus: "Advanced skills training – tactical positioning, game scenarios, speed, and agility work.",
                duration: "1-hour sessions",
                idealFor: "Intermediate players wanting to refine skills and prep for competitive play.",
                color: Color.blue
            ),
            TrainingPackage(
                id: "elite",
                title: "Elite Performance Package",
                subtitle: "All-Inclusive Training & Mentorship",
                price: "$950/month",
                sessions: "12 sessions per month (3 per week)",
                focus: "Complete performance development – technique, physical conditioning, mental resilience, and leadership on the field.",
                duration: "1-hour sessions",
                idealFor: "Advanced players committed to reaching peak performance.",
                color: Color.purple
            )
        ]
    }
    
    func togglePackage(_ packageId: String) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            if expandedPackage == packageId {
                expandedPackage = nil
            } else {
                expandedPackage = packageId
            }
        }
    }
    
    func bookPackage(_ package: TrainingPackage) {
        if let url = URL(string: registrationURL) {
            UIApplication.shared.open(url)
        }
    }
    
    func signUpNow() {
        if let url = URL(string: registrationURL) {
            UIApplication.shared.open(url)
        }
    }
}

struct CampData: Identifiable, Hashable {
    let id = UUID()
    let image: String
    let title: String
    let dates: String
    let hasCheckmark: Bool
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
