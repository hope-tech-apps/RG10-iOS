//
//  BookingIntegrationExample.swift
//  RG10
//
//  Created by Moneeb Sayed on 1/17/25.
//

import SwiftUI
import StripePaymentSheet

// MARK: - Booking Integration Example

struct BookingIntegrationExample: View {
    @StateObject private var bookingService = EnhancedBookingService.shared
    @StateObject private var paymentFlowVM = BookingFlowViewModel()
    
    @State private var showingBookingTypes = false
    @State private var showingPaymentFlow = false
    @State private var selectedBooking: Booking?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                headerView
                
                // Quick Actions
                quickActionsView
                
                // Booking Types
                bookingTypesView
                
                // Recent Bookings
                recentBookingsView
                
                Spacer()
            }
            .padding()
            .navigationTitle("Booking Management")
            .task {
                await loadData()
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
                            handlePaymentResult(result)
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Training Sessions")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Book and manage your training")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: refreshData) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                        .foregroundColor(AppConstants.Colors.primaryRed)
                }
                .disabled(bookingService.isLoading)
            }
            
            // Stats
            if !bookingService.bookings.isEmpty {
                HStack(spacing: 20) {
                    StatCard(
                        title: "Upcoming",
                        count: bookingService.upcomingBookings().count,
                        color: .blue
                    )
                    
                    StatCard(
                        title: "Current",
                        count: bookingService.currentBookings().count,
                        color: .green
                    )
                    
                    StatCard(
                        title: "Past",
                        count: bookingService.pastBookings().count,
                        color: .gray
                    )
                }
            }
        }
    }
    
    // MARK: - Quick Actions
    
    private var quickActionsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                QuickActionButton(
                    title: "View All Bookings",
                    icon: "calendar",
                    color: .blue
                ) {
                    // Navigate to full booking view
                }
                
                QuickActionButton(
                    title: "Booking Types",
                    icon: "list.bullet",
                    color: .green
                ) {
                    showingBookingTypes = true
                }
                
                QuickActionButton(
                    title: "Book New Session",
                    icon: "plus.circle",
                    color: AppConstants.Colors.primaryRed
                ) {
                    // Navigate to booking flow
                }
            }
        }
    }
    
    // MARK: - Booking Types
    
    private var bookingTypesView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Available Sessions")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("View All") {
                    showingBookingTypes = true
                }
                .font(.caption)
                .foregroundColor(AppConstants.Colors.primaryRed)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(bookingService.bookingTypes.prefix(3)) { type in
                        BookingTypeCard(bookingType: type)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    // MARK: - Recent Bookings
    
    private var recentBookingsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Bookings")
                .font(.headline)
                .fontWeight(.semibold)
            
            if bookingService.isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Loading bookings...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else if bookingService.bookings.isEmpty {
                    EmptyStateView(
                        icon: "calendar.badge.plus",
                        title: "No Bookings Yet",
                        message: "Book your first training session to get started"
                    )
            } else {
                VStack(spacing: 8) {
                    ForEach(bookingService.upcomingBookings().prefix(3)) { booking in
                        CompactBookingCard(
                            booking: booking,
                            onPayNow: {
                                selectedBooking = booking
                                showingPaymentFlow = true
                            }
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Methods
    
    private func loadData() async {
        do {
            async let bookingsTask = bookingService.fetchBookings()
            async let typesTask = bookingService.fetchBookingTypes()
            
            _ = try await bookingsTask
            _ = try await typesTask
        } catch {
            print("Failed to load data: \(error)")
        }
    }
    
    private func refreshData() {
        Task {
            do {
                try await bookingService.refreshBookings()
            } catch {
                print("Failed to refresh data: \(error)")
            }
        }
    }
    
    private func handlePaymentResult(_ result: PaymentSheetResult) {
        switch result {
        case .completed:
            Task {
                await bookingService.handlePaymentSuccess(bookingUid: selectedBooking?.uid ?? "")
            }
            
        case .canceled:
            break
            
        case .failed(let error):
            print("Payment failed: \(error)")
        }
    }
}

// MARK: - Supporting Views

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.1))
            )
        }
        .buttonStyle(.plain)
    }
}

struct BookingTypeCard: View {
    let bookingType: BookingType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(bookingType.name)
                .font(.headline)
                .fontWeight(.semibold)
                .lineLimit(2)
            
            if let description = bookingType.description {
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            HStack {
                Text("\(bookingType.duration) min")
                    .font(.caption)
                    .fontWeight(.medium)
                
                Spacer()
                
                if let price = bookingType.price {
                    Text(String(format: "$%.0f", price))
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(AppConstants.Colors.primaryRed)
                }
            }
        }
        .padding()
        .frame(width: 160)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(radius: 2)
        )
    }
}

struct CompactBookingCard: View {
    let booking: Booking
    let onPayNow: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(booking.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                Text(booking.start.dayMonthFormat)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                StatusBadge(status: booking.status)
                
                if booking.status == .pending {
                    Button("Pay") {
                        onPayNow()
                    }
                    .font(.caption)
                    .foregroundColor(AppConstants.Colors.primaryRed)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

// MARK: - Usage Examples

struct BookingServiceUsageExamples {
    
    // Example 1: Basic Usage
    static func basicUsage() async {
        let bookingService = EnhancedBookingService.shared
        
        do {
            // Fetch bookings
            let bookings = try await bookingService.fetchBookings()
            print("Fetched \(bookings.data.upcoming.count) upcoming bookings")
            
            // Fetch booking types
            let types = try await bookingService.fetchBookingTypes()
            print("Available booking types: \(types.count)")
            
        } catch {
            print("Error: \(error)")
        }
    }
    
    // Example 2: Payment Integration
    static func paymentIntegration() async {
        let bookingService = EnhancedBookingService.shared
        
        do {
            // Create payment intent
            let paymentIntent = try await bookingService.createBookingIntent(
                userId: "user_123",
                bookingUid: "booking_456"
            )
            
            print("Payment intent created: \(paymentIntent.paymentIntentClientSecret)")
            
            // Handle successful payment
            await bookingService.handlePaymentSuccess(bookingUid: "booking_456")
            
        } catch {
            print("Payment error: \(error)")
        }
    }
    
    // Example 3: Booking Management
    static func bookingManagement() async {
        let bookingService = EnhancedBookingService.shared
        
        do {
            // Cancel booking
            try await bookingService.cancelBooking(
                bookingUid: "booking_123",
                cancellationReason: "Schedule conflict"
            )
            
            // Reschedule booking
            let newDate = Date().addingTimeInterval(86400) // Tomorrow
            let updatedBooking = try await bookingService.rescheduleBooking(
                bookingUid: "booking_456",
                newStartTime: newDate,
                reason: "Need different time"
            )
            
            print("Booking rescheduled to: \(updatedBooking.start)")
            
        } catch {
            print("Management error: \(error)")
        }
    }
    
    // Example 4: Caching and Performance
    static func cachingExample() async {
        let bookingService = EnhancedBookingService.shared
        
        // First call - fetches from server
        let startTime = Date()
        _ = try? await bookingService.fetchBookings()
        let firstCallTime = Date().timeIntervalSince(startTime)
        
        // Second call - uses cache
        let secondStartTime = Date()
        _ = try? await bookingService.fetchBookings()
        let secondCallTime = Date().timeIntervalSince(secondStartTime)
        
        print("First call: \(firstCallTime)s, Second call: \(secondCallTime)s")
        
        // Force refresh
        _ = try? await bookingService.fetchBookings(forceRefresh: true)
    }
}

// MARK: - Preview

#Preview {
    BookingIntegrationExample()
}
