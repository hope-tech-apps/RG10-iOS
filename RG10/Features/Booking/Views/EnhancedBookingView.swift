//
//  EnhancedBookingView.swift
//  RG10
//
//  Created by Moneeb Sayed on 1/17/25.
//

import SwiftUI
import StripePaymentSheet

// MARK: - Enhanced Booking View

struct EnhancedBookingView: View {
    @StateObject private var bookingService = EnhancedBookingService.shared
    @StateObject private var paymentFlowVM = BookingFlowViewModel()
    
    @State private var selectedTab = 0
    @State private var showingPaymentFlow = false
    @State private var selectedBooking: Booking?
    @State private var showingCancelAlert = false
    @State private var cancellationReason = ""
    
    private let tabs = ["Current", "Upcoming", "Past", "Cancelled", "Unconfirmed"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Tab Picker
                tabPicker
                
                // Content
                contentView
            }
            .navigationBarHidden(true)
            .task {
                await loadInitialData()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("BookingsUpdated"))) { _ in
                Task {
                    await loadInitialData()
                }
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
            .alert("Cancel Booking", isPresented: $showingCancelAlert) {
                TextField("Reason (required)", text: $cancellationReason)
                Button("Cancel Booking", role: .destructive) {
                    cancelBooking()
                }
                .disabled(cancellationReason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                Button("Keep Booking", role: .cancel) {
                    cancellationReason = ""
                }
            } message: {
                Text("Please provide a reason for cancelling this booking.")
            }
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("My Bookings")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Manage your training sessions")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: refreshBookings) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                        .foregroundColor(AppConstants.Colors.primaryRed)
                }
                .disabled(bookingService.isLoading)
            }
            
            // Stats
            if !bookingService.bookings.isEmpty {
                statsView
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    // MARK: - Stats View
    
    private var statsView: some View {
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
    
    // MARK: - Tab Picker
    
    private var tabPicker: some View {
        Picker("Bookings", selection: $selectedTab) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Text(tabs[index]).tag(index)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
    
    // MARK: - Content View
    
    private var contentView: some View {
        Group {
            if bookingService.isLoading {
                LoadingView()
            } else if let errorMessage = bookingService.errorMessage {
                ErrorView(message: errorMessage) {
                    Task {
                        await loadInitialData()
                    }
                }
            } else {
                bookingsList
            }
        }
    }
    
    // MARK: - Bookings List
    
    private var bookingsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(currentBookings) { booking in
                    EnhancedBookingCard(
                        booking: booking,
                        onPayNow: {
                            selectedBooking = booking
                            showingPaymentFlow = true
                        },
                        onCancel: {
                            selectedBooking = booking
                            showingCancelAlert = true
                        },
                        onReschedule: {
                            openRescheduleInBrowser(booking: booking)
                        }
                    )
                }
                
                if currentBookings.isEmpty {
                    EmptyStateView(
                        icon: emptyStateIcon,
                        title: emptyStateTitle,
                        message: emptyStateMessage
                    )
                }
            }
            .padding(.horizontal)
        }
        .sheet(isPresented: $showingPaymentFlow) {
            BookingFlowView()
        }
        .alert("Cancel Booking", isPresented: $showingCancelAlert) {
            TextField("Reason for cancellation", text: $cancellationReason)
            Button("Cancel Booking", role: .destructive) {
                cancelBooking()
            }
            Button("Keep Booking", role: .cancel) {
                cancellationReason = ""
            }
        } message: {
            Text("Please provide a reason for cancelling this booking.")
        }
    }
    
    // MARK: - Computed Properties
    
    private var currentBookings: [Booking] {
        switch selectedTab {
        case 0: return bookingService.currentBookings()
        case 1: return bookingService.upcomingBookings()
        case 2: return bookingService.pastBookings()
        case 3: return bookingService.cancelledBookings()
        case 4: return bookingService.unconfirmedBookings()
        default: return []
        }
    }
    
    private var emptyStateTitle: String {
        switch selectedTab {
        case 0: return "No Current Bookings"
        case 1: return "No Upcoming Bookings"
        case 2: return "No Past Bookings"
        case 3: return "No Cancelled Bookings"
        case 4: return "No Unconfirmed Bookings"
        default: return "No Bookings"
        }
    }
    
    private var emptyStateMessage: String {
        switch selectedTab {
        case 0: return "You don't have any current training sessions"
        case 1: return "You don't have any upcoming training sessions"
        case 2: return "You don't have any past training sessions"
        case 3: return "You don't have any cancelled training sessions"
        case 4: return "You don't have any unconfirmed training sessions"
        default: return "No bookings found"
        }
    }
    
    private var emptyStateIcon: String {
        switch selectedTab {
        case 0: return "clock.fill"
        case 1: return "calendar.badge.plus"
        case 2: return "clock.badge.checkmark"
        case 3: return "xmark.circle.fill"
        case 4: return "questionmark.circle.fill"
        default: return "calendar"
        }
    }
    
    // MARK: - Methods
    
    private func loadInitialData() async {
        do {
            async let bookingsTask = bookingService.fetchBookings()
            async let typesTask = bookingService.fetchBookingTypes()
            
            _ = try await bookingsTask
            _ = try await typesTask
        } catch {
            print("Failed to load initial data: \(error)")
        }
    }
    
    private func refreshBookings() {
        Task {
            do {
                try await bookingService.refreshBookings()
            } catch {
                print("Failed to refresh bookings: \(error)")
            }
        }
    }
    
    private func cancelBooking() {
        guard let booking = selectedBooking else { return }
        
        Task {
            do {
                try await bookingService.cancelBooking(
                    bookingUid: booking.uid,
                    cancellationReason: cancellationReason
                )
                cancellationReason = ""
            } catch {
                print("Failed to cancel booking: \(error)")
            }
        }
    }
    
    private func openRescheduleInBrowser(booking: Booking) {
        let baseUrl = "https://cal.com"
        let eventTypeSlug = booking.eventType?.slug ?? "rodrigo-single-session"
        let bookingUid = booking.uid
        
        // Cal.com reschedule URL format: https://cal.com/{username}/{event-type-slug}?rescheduleUid={bookingUid}
        let rescheduleUrl = "\(baseUrl)/hopetechapps/\(eventTypeSlug)?rescheduleUid=\(bookingUid)"
        
        if let url = URL(string: rescheduleUrl) {
            UIApplication.shared.open(url)
        }
    }
    
    private func handlePaymentResult(_ result: PaymentSheetResult) {
        switch result {
        case .completed:
            Task {
                await bookingService.handlePaymentSuccess(bookingUid: selectedBooking?.uid ?? "")
            }
            
        case .canceled:
            // Handle cancellation
            break
            
        case .failed(let error):
            print("Payment failed: \(error)")
        }
    }
}

// MARK: - Enhanced Booking Card

struct EnhancedBookingCard: View {
    let booking: Booking
    let onPayNow: () -> Void
    let onCancel: () -> Void
    let onReschedule: () -> Void
    
    @StateObject private var bookingService = EnhancedBookingService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(booking.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(booking.description ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    StatusBadge(status: booking.status)
                    
                    if booking.canCancel == true && bookingService.canModifyBooking(booking) {
                        Button("Cancel") {
                            onCancel()
                        }
                        .font(.caption)
                        .foregroundColor(.red)
                    } else if booking.canCancel == true && !bookingService.canModifyBooking(booking) {
                        Text("Cannot cancel within 24 hours")
                            .font(.caption)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
            }
            
            // Details
            VStack(alignment: .leading, spacing: 8) {
                DetailRow(
                    icon: "calendar",
                    title: "Date & Time",
                    description: booking.start.bookingDisplayFormat
                )
                
                DetailRow(
                    icon: "clock",
                    title: "Duration",
                    description: "\(booking.durationMinutes ?? 0) minutes"
                )
                
                if let location = booking.location, !location.isEmpty {
                    DetailRow(
                        icon: "location",
                        title: "Location",
                        description: location
                    )
                }
                
                if let hosts = booking.hosts, !hosts.isEmpty {
                    DetailRow(
                        icon: "person",
                        title: "Host",
                        description: hosts.first?.name ?? "Unknown"
                    )
                }
            }
            
            // Actions
            if booking.status == .pending {
                Button("Pay Now") {
                    onPayNow()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            } else if booking.canReschedule == true && bookingService.canModifyBooking(booking) {
                HStack(spacing: 12) {
                    Button("Reschedule") {
                        onReschedule()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    
                    if booking.status == .pending {
                        Button("Pay Now") {
                            onPayNow()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    }
                }
            } else if booking.canReschedule == true && !bookingService.canModifyBooking(booking) {
                Text("Cannot reschedule within 24 hours")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(6)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(radius: 2)
        )
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct RescheduleSheet: View {
    let booking: Booking?
    @Binding var rescheduleDate: Date
    @Binding var rescheduleReason: String
    let onReschedule: () -> Void
    let onUseWebView: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Reschedule Booking")
                        .font(.headline)
                    
                    Text(booking?.title ?? "Training Session")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("New Date & Time")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    DatePicker(
                        "Select new time",
                        selection: $rescheduleDate,
                        in: Date()...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.compact)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Reason (Optional)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("Why are you rescheduling?", text: $rescheduleReason)
                        .textFieldStyle(.roundedBorder)
                }
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button("Reschedule") {
                        onReschedule()
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .frame(maxWidth: .infinity)
                    
                    Button("View Available Times") {
                        onUseWebView()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .navigationTitle("Reschedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    EnhancedBookingView()
}
