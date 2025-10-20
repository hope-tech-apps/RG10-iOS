//
//  BookingPaymentExample.swift
//  RG10
//
//  Created by Moneeb Sayed on 1/17/25.
//

import SwiftUI
import StripePaymentSheet

// MARK: - Example Integration

struct BookingPaymentExample: View {
    @StateObject private var bookingService = BookingService.shared
    @State private var showingPaymentFlow = false
    @State private var selectedBooking: Booking?
    
    var body: some View {
        NavigationView {
            VStack {
                if bookingService.isLoading {
                    ProgressView("Loading bookings...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = bookingService.errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        
                        Text("Error")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(errorMessage)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Retry") {
                            Task {
                                try await bookingService.fetchBookings()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else {
                    List(bookingService.bookings) { booking in
                        BookingRowView(
                            booking: booking,
                            onPayNow: {
                                selectedBooking = booking
                                showingPaymentFlow = true
                            }
                        )
                    }
                }
            }
            .navigationTitle("My Bookings")
            .task {
                try? await bookingService.fetchBookings()
            }
            .overlay {
                if showingPaymentFlow, let booking = selectedBooking {
                    PaymentFlowView(
                        flowType: .booking,
                        priceId: nil,
                        planName: nil,
                        bookingUid: booking.uid,
                        onCompletion: { result in
                            showingPaymentFlow = false
                            selectedBooking = nil
                            
                            switch result {
                            case .completed:
                                // Handle successful payment
                                Task {
                                    await bookingService.handlePaymentSuccess(bookingUid: booking.uid)
                                }
                                
                            case .canceled:
                                // Handle cancellation
                                break
                                
                            case .failed(let error):
                                // Handle payment failure
                                print("Payment failed: \(error)")
                            }
                        }
                    )
                }
            }
        }
    }
}

// MARK: - Booking Row View

struct BookingRowView: View {
    let booking: Booking
    let onPayNow: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(booking.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(booking.start.bookingDisplayFormat)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(booking.status.rawValue.capitalized)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(statusColor.opacity(0.2))
                        .foregroundColor(statusColor)
                        .cornerRadius(8)
                    
                    if booking.canCancel == true {
                        Button("Cancel") {
                            // Handle cancellation
                        }
                        .font(.caption)
                        .foregroundColor(.red)
                    }
                }
            }
            
            if booking.status == .pending {
                Button("Pay Now") {
                    onPayNow()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var statusColor: Color {
        switch booking.status {
        case .confirmed:
            return .green
        case .pending:
            return .orange
        case .cancelled:
            return .red
        case .rejected:
            return .red
        case .upcoming:
            return .blue
        case .past:
            return .gray
        case .current:
            return .purple
        case .unconfirmed:
            return .yellow
        case .accepted:
            return .green
        }
    }
}

// MARK: - Subscription Example

struct SubscriptionExample: View {
    @StateObject private var subscriptionService = SubscriptionService.shared
    @State private var showingPaymentFlow = false
    @State private var selectedPlan: DBSubscription?
    
    var body: some View {
        NavigationView {
            VStack {
                if subscriptionService.isLoading {
                    ProgressView("Loading subscription plans...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(subscriptionService.subscriptions) { subscription in
                                SubscriptionPlanCard(subscription: subscription) {
                                    selectedPlan = subscription
                                }
                            }
                            
                            if let selectedPlan = selectedPlan {
                                Button("Subscribe to \(selectedPlan.name)") {
                                    showingPaymentFlow = true
                                }
                                .buttonStyle(.borderedProminent)
                                .padding(.top)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Subscription Plans")
            .task {
                try? await subscriptionService.fetchSubscriptions()
            }
            .overlay {
                if showingPaymentFlow, let plan = selectedPlan {
                    PaymentFlowView(
                        flowType: .subscription,
                        priceId: plan.stripe_price_id,
                        planName: plan.name,
                        bookingUid: nil,
                        onCompletion: { result in
                            showingPaymentFlow = false
                            selectedPlan = nil
                            
                            switch result {
                            case .completed:
                                // Handle successful subscription
                                Task {
                                    await subscriptionService.handleSubscriptionSuccess(subscription: plan)
                                }
                                
                            case .canceled:
                                // Handle cancellation
                                break
                                
                            case .failed(let error):
                                // Handle payment failure
                                print("Subscription failed: \(error)")
                            }
                        }
                    )
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Booking Payment") {
    BookingPaymentExample()
}

#Preview("Subscription") {
    SubscriptionExample()
}
