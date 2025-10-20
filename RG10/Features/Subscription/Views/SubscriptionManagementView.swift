//
//  SubscriptionManagementView.swift
//  RG10
//
//  Created by Moneeb Sayed on 1/17/25.
//

import SwiftUI

// MARK: - Subscription Management View

struct SubscriptionManagementView: View {
    @StateObject private var subscriptionService = SubscriptionService.shared
    @State private var showingCancelAlert = false
    @State private var isCancelling = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if subscriptionService.isLoading {
                        loadingView
                    } else if let userSubscription = subscriptionService.userSubscription {
                        activeSubscriptionView(userSubscription)
                    } else {
                        noSubscriptionView
                    }
                }
                .padding()
            }
            .navigationTitle("My Subscription")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await loadSubscriptionData()
            }
            .alert("Cancel Subscription", isPresented: $showingCancelAlert) {
                Button("Cancel Subscription", role: .destructive) {
                    Task {
                        await cancelSubscription()
                    }
                }
                Button("Keep Subscription", role: .cancel) { }
            } message: {
                Text("Are you sure you want to cancel your subscription? You'll continue to have access until the end of your current billing period.")
            }
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: AppConstants.Colors.primaryRed))
                .scaleEffect(1.5)
            
            Text("Loading subscription details...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Active Subscription View
    
    private func activeSubscriptionView(_ subscription: DBUserSubscription) -> some View {
        VStack(spacing: 20) {
            // Subscription Status Card
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Active Subscription")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Subscription ID: \(subscription.subscription_id)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Circle()
                        .fill(subscription.subscribed ? .green : .red)
                        .frame(width: 12, height: 12)
                }
                
                Divider()
                
                // Subscription Details
                VStack(spacing: 12) {
                    DetailRow(
                        icon: "calendar",
                        title: "Started",
                        description: formatDate(subscription.subscribed_at)
                    )
                    
                    DetailRow(
                        icon: "arrow.clockwise",
                        title: "Last Renewed",
                        description: formatDate(subscription.renewed_at)
                    )
                    
                    DetailRow(
                        icon: "calendar.badge.clock",
                        title: "Next Billing",
                        description: formatDate(subscription.next_renewal_at)
                    )
                    
                    DetailRow(
                        icon: "person.2",
                        title: "Sessions Remaining",
                        description: "\(subscription.remaining_bookings) sessions this month"
                    )
                }
                
                if subscription.cancel_at_period_end {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("Subscription will cancel at the end of the current period")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    .padding(.top, 8)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            // Action Buttons
            VStack(spacing: 12) {
                if !subscription.cancel_at_period_end {
                    Button(action: {
                        showingCancelAlert = true
                    }) {
                        HStack {
                            Image(systemName: "xmark.circle")
                            Text("Cancel Subscription")
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.red)
                        .cornerRadius(8)
                    }
                    .disabled(isCancelling)
                }
                
                Button(action: {
                    Task {
                        await loadSubscriptionData()
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Refresh Status")
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppConstants.Colors.primaryRed)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppConstants.Colors.primaryRed, lineWidth: 1.5)
                    )
                }
            }
        }
    }
    
    // MARK: - No Subscription View
    
    private var noSubscriptionView: some View {
        VStack(spacing: 20) {
            Image(systemName: "creditcard")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No Active Subscription")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("You don't have an active subscription. Subscribe to one of our training packages to get started!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                // Navigate to subscription plans
                NavigationManager.shared.navigate(to: .subscriptionPlans, in: .training)
            }) {
                Text("View Subscription Plans")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppConstants.Colors.primaryRed)
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    // MARK: - Helper Methods
    
    private func loadSubscriptionData() async {
        do {
            try await subscriptionService.fetchUserSubscription(forceRefresh: true)
        } catch {
            print("Failed to load subscription data: \(error)")
        }
    }
    
    private func cancelSubscription() async {
        isCancelling = true
        
        do {
            let response = try await subscriptionService.cancelSubscription()
            
            if response.success {
                // Refresh subscription data
                try await subscriptionService.fetchUserSubscription(forceRefresh: true)
            }
        } catch {
            print("Failed to cancel subscription: \(error)")
        }
        
        isCancelling = false
    }
    
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

// MARK: - Preview

#Preview {
    SubscriptionManagementView()
}
