//
//  UnifiedTrainingView.swift
//  RG10
//
//  Created by Moneeb Sayed on 1/17/25.
//

import SwiftUI
import StripePaymentSheet

// MARK: - Unified Training View (Following Android Approach)

struct UnifiedTrainingView: View {
    @StateObject private var viewModel = UnifiedTrainingViewModel()
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header Section
                    headerSection
                    
                    // Subscription Status Section
                    if viewModel.hasActiveSubscription {
                        activeSubscriptionSection
                    } else {
                        subscriptionPlansSection
                    }
                    
                    // Camps & Clinics Section
                    campsAndClinicsSection
                    
                    // Training Footer
                    trainingFooterSection
                }
            }
            .background(Color(UIColor.systemGray6))
        }
        .task {
            await viewModel.loadInitialData()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SubscriptionStatusUpdated"))) { notification in
            print("🔄 Received subscription status update notification")
            Task {
                await viewModel.refreshSubscriptionStatus()
            }
        }
        .sheet(isPresented: $viewModel.showSubscriptionManagement) {
            SubscriptionManagementView()
        }
        .paymentSheet(
            isPresented: .constant(viewModel.shouldPresentPaymentSheet),
            paymentSheet: viewModel.currentPaymentSheet ?? PaymentSheet(paymentIntentClientSecret: "", configuration: PaymentSheet.Configuration()),
            onCompletion: { result in
                switch result {
                case .completed:
                    viewModel.handlePaymentCompleted()
                case .canceled:
                    viewModel.handlePaymentCancelled()
                case .failed(let error):
                    viewModel.handlePaymentFailed(error.localizedDescription)
                }
            }
        )
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 20) {
            Image("training_illustration")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 180)
                .padding(.top, 40)
            
            VStack(spacing: 12) {
                Text("RG10 Training")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                
                Text("Elevate your game with professional training")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 30)
        }
        .background(Color.white.ignoresSafeArea())
    }
    
    // MARK: - Active Subscription Section
    
    private var activeSubscriptionSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Your Active Plan")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
            }
            .padding(.horizontal)
            
            if let subscription = viewModel.userSubscription {
                ActiveSubscriptionCard(subscription: subscription) {
                    viewModel.showSubscriptionManagement = true
                }
            }
        }
    }
    
    // MARK: - Subscription Plans Section
    
    private var subscriptionPlansSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Choose Your Training Plan")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
            }
            .padding(.horizontal)
            
            if viewModel.isLoadingPlans {
                VStack(spacing: 16) {
                    ProgressView("Loading training plans...")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                }
            } else if let errorMessage = viewModel.plansErrorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                    
                    Text("Error Loading Plans")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(errorMessage)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("Retry") {
                        Task {
                            await viewModel.loadSubscriptionPlans()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            } else if viewModel.subscriptionPlans.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "dollarsign.circle")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("No Plans Available")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("We're working on adding new training plans. Check back soon!")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            } else {
                VStack(spacing: 16) {
                    ForEach(viewModel.subscriptionPlans) { plan in
                        SubscriptionPlanCard(
                            subscription: plan,
                            onSelect: {
                                viewModel.selectPlan(plan)
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Camps & Clinics Section
    
    private var campsAndClinicsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Camps & Clinics")
                .font(.system(size: 17, weight: .semibold))
                .padding(.horizontal)
            
            if viewModel.availableCamps.isEmpty {
                EmptyCampsView()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.availableCamps) { camp in
                            CampCard(
                                image: camp.image,
                                title: camp.title,
                                dates: camp.dates,
                                hasCheckmark: camp.hasCheckmark
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Page Indicators
                HStack(spacing: 6) {
                    ForEach(0..<4) { index in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(index == 0 ? AppConstants.Colors.primaryRed : Color.gray.opacity(0.3))
                            .frame(width: index == 0 ? 20 : 6, height: 4)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
            }
        }
    }
    
    // MARK: - Training Footer Section
    
    private var trainingFooterSection: some View {
        ZStack(alignment: .bottom) {
            Image(AppConstants.Images.trainingFooter)
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            VStack(spacing: 8) {
                Text("Ready to take your game to the next level?")
                    .font(Font.custom("SF Pro Display", size: 20))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .stroke(color: .black)
                
                Text("Book a private session with our top coaches today ⚽🔥")
                    .font(
                        Font.custom("SF Pro Display", size: 13)
                            .weight(.semibold)
                    )
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .stroke(color: .black)
                
                Button(action: {
                    // Navigate to booking flow
                    navigationManager.navigate(to: .myAppointments)
                }) {
                    Text("Book a Private Session")
                        .font(
                            Font.custom("SF Pro Display", size: 13)
                                .weight(.bold)
                        )
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding(.horizontal, 17)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(AppConstants.Colors.primaryRed)
                        )
                }
                .padding(.bottom, 20)
            }
            .background {
                Color.white.opacity(0.3).blur(radius: 100)
                    .ignoresSafeArea()
            }
        }
    }
}

// MARK: - Active Subscription Card

struct ActiveSubscriptionCard: View {
    let subscription: DBUserSubscription
    let onManage: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Active Plan")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("Premium Training")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Renewed: \(formatDate(subscription.renewed_at))")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                    
                    // Show pending cancellation status
                    if subscription.cancel_at_period_end {
                        Text("⚠️ Cancels on \(formatDate(subscription.next_renewal_at))")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.yellow)
                            .padding(.top, 2)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(subscription.remaining_bookings)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("sessions left")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(20)
            .background(
                LinearGradient(
                    colors: [AppConstants.Colors.primaryRed, AppConstants.Colors.primaryRed.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            
            Button(action: onManage) {
                Text("Manage Subscription")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.black)
            }
        }
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    // MARK: - Helper Methods
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .none
        
        return displayFormatter.string(from: date)
    }
}

// SubscriptionPlanCard is defined in SubscriptionPlansView.swift

// MARK: - Detail Row Component

struct DetailRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
                
                Text(description)
                    .font(.system(size: 15))
                    .foregroundColor(.black)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
}

// MARK: - Empty Camps View

struct EmptyCampsView: View {
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "soccerball")
                    .font(.system(size: 40))
                    .foregroundColor(AppConstants.Colors.primaryRed.opacity(0.6))
            }
            
            VStack(spacing: 8) {
                Text("Camps Coming Soon!")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                
                Text("We're preparing exciting soccer camps for you.\nCheck back soon for updates!")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal)
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Camp Card Component

struct CampCard: View {
    let image: String
    let title: String
    let dates: String
    let hasCheckmark: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topTrailing) {
                ZStack(alignment: .bottomLeading) {
                    Image(image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 220, height: 274)
                        .clipped()
                        .cornerRadius(13)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Spacer()
                        Text(title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .shadow(radius: 10)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                            .background {
                                Color.black.opacity(0.3).blur(radius: 5)
                            }
                        
                        Text(dates)
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .shadow(radius: 10)
                            .background {
                                Color.black.opacity(0.3).blur(radius: 5)
                                    .frame(maxWidth: .infinity)
                            }
                    }
                    .padding()
                }
                
                if hasCheckmark {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .padding(8)
                }
            }
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Preview

struct UnifiedTrainingView_Previews: PreviewProvider {
    static var previews: some View {
        UnifiedTrainingView()
            .environmentObject(NavigationManager.shared)
    }
}
