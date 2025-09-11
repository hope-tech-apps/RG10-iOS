//
//  NavigationDestinationView.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/8/25.
//


import SwiftUI

struct NavigationDestinationView: View {
    let destination: NavigationDestination
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        Group {
            switch destination {
            case .login:
                LoginView(viewModel: AuthViewModel())
            case .signUp:
                SignUpView(viewModel: AuthViewModel())
            case .forgotPassword:
                ForgotPasswordView()
            case .about:
                AboutView()
            case .staff(let selectedIndex):
                StaffView(selectedIndex: selectedIndex)
            case .merchandise:
                MerchandiseView()
            case .merchandiseDetail(let product):
                MerchandiseDetailView(product: product)
            case .termsOfService:
                TermsOfServiceView()
            case .privacyPolicy:
                PrivacyPolicyView()
                
                // Training destinations
            case .trainingPackages:
                TrainingPackagesView()
            case .campDetail(let camp):
                CampDetailView(camp: camp)
            case .workoutDetail(let workoutId):
                WorkoutDetailView(workoutId: workoutId)
                
                // Explore destinations
            case .coachProfile(let coach):
                CoachDetailView(coach: coach)
            case .videoPlayer(let video):
                VideoPlayerDetailView(video: video)
            case .playerSpotlight(let spotlight):
                PlayerSpotlightDetailView(spotlight: spotlight)
                
                // Account destinations
            case .editProfile:
                EditProfileView()
            case .myAppointments:
                MyAppointmentsView()
            case .paymentHistory:
                PaymentHistoryView()
            case .settings:
                SettingsView()
            case .support:
                SupportView()
            case .videoLibrary:
                VideoLibraryView()
            case .playerSpotlights:
                EmptyView()
            case .myPlans:
                MyPlansView()
            }
        }
        .toolbar(.hidden, for: .tabBar) // Add this line to hide tab bar

    }
    
}
