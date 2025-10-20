//
//  SubscriptionPlansView.swift
//  RG10
//
//  Created by Moneeb Sayed on 1/17/25.
//

import SwiftUI
import StripePaymentSheet

// MARK: - Subscription Plans View (Matching Android Implementation)

struct SubscriptionPlansView: View {
    @StateObject private var viewModel = SubscriptionFlowViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if viewModel.isLoading {
                    loadingView
                } else if let errorMessage = viewModel.errorMessage {
                    errorView(errorMessage)
                } else {
                    plansListView
                }
            }
            .navigationTitle("Training Packages")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .task {
                viewModel.loadPlans()
            }
            .onChange(of: viewModel.coordinator.result) { newResult in
                if let newResult = newResult {
                    handleFlowResult(newResult)
                }
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
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: AppConstants.Colors.primaryRed))
                .scaleEffect(1.5)
            
            Text("Loading subscription plans...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Error View
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Error Loading Plans")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Retry") {
                viewModel.retry()
            }
            .buttonStyle(.borderedProminent)
            .tint(AppConstants.Colors.primaryRed)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Plans List View
    
    private var plansListView: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Training Packages")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(AppConstants.Colors.primaryRed)
                    
                    Text("Pricing starts at $85/hr for a single session but take advantage of our monthly packages which come at a lower rate below.")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .italic()
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                
                // Plans Section
                VStack(spacing: 16) {
                    ForEach(viewModel.subscriptions) { subscription in
                        SubscriptionPlanCard(
                            subscription: subscription,
                            onSelect: {
                                viewModel.selectPlan(subscription)
                            }
                        )
                    }
                }
                .padding()
                
                // Bottom CTA Section
                VStack(spacing: 20) {
                    Text("Ready to elevate your game?")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Text("Have questions? Contact us at info@rg10football.com")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 40)
                .background(Color(UIColor.systemGray6))
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func handleFlowResult(_ result: SubscriptionFlowResult) {
        switch result {
        case .success(let subscription):
            print("Subscription successful for plan: \(subscription.name)")
            // Dismiss the view on successful subscription
            dismiss()
        case .failure(let error):
            print("Subscription failed: \(error)")
            // Show error alert or handle failure
        case .cancelled:
            print("Subscription cancelled by user.")
            // Handle cancellation
        }
        viewModel.reset() // Reset flow state
    }
}

// MARK: - Subscription Plan Card

struct SubscriptionPlanCard: View {
    let subscription: DBSubscription
    let onSelect: () -> Void
    
    private var cardColor: Color {
        // Map subscription names to colors (matching existing design)
        switch subscription.name.lowercased() {
        case let name where name.contains("starter"):
            return AppConstants.Colors.primaryRed
        case let name where name.contains("advanced"):
            return .blue
        case let name where name.contains("elite"):
            return .purple
        default:
            return AppConstants.Colors.primaryRed
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main Card Content
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(subscription.name)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(subscription.subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text("$\(String(format: "%.0f", subscription.price))/month")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
            .padding(20)
            .background(
                LinearGradient(
                    colors: [cardColor, cardColor.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            
            // Details Section
            VStack(alignment: .leading, spacing: 16) {
                DetailRow(
                    icon: "calendar",
                    title: "Sessions",
                    description: "\(subscription.included_sessions) sessions per month"
                )
                Divider()
                DetailRow(
                    icon: "target",
                    title: "Focus",
                    description: subscription.focus
                )
                Divider()
                DetailRow(
                    icon: "person.fill",
                    title: "Ideal For",
                    description: subscription.ideal_for
                )
                
                Button(action: onSelect) {
                    Text("Subscribe Now")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(cardColor)
                        .cornerRadius(8)
                }
                .padding(.top, 8)
            }
            .padding(20)
            .background(Color.white)
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Preview

#Preview {
    SubscriptionPlansView()
}
