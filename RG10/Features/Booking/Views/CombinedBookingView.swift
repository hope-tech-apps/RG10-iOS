//
//  CombinedBookingView.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/17/25.
//

import SwiftUI

struct CombinedBookingView: View {
    @ObservedObject private var bookingService = EnhancedBookingService.shared
    
    @State private var selectedTab = 0
    @State private var showingCancelAlert = false
    @State private var cancellationReason = ""
    @State private var selectedBooking: Booking?
    @State private var showingBookingFlow = false
    @State private var showingRescheduleWebView = false
    
    private let tabs = ["Active", "History"]
    
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
            .onAppear {
                MemoryMonitor.shared.viewAppeared("CombinedBookingView")
            }
            .onDisappear {
                MemoryMonitor.shared.viewDisappeared("CombinedBookingView")
            }
            .task {
                await loadInitialData()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("BookingsUpdated"))) { _ in
                Task {
                    await loadInitialData()
                }
            }
            .alert("Cancel Booking", isPresented: $showingCancelAlert) {
                TextField("Reason (required)", text: $cancellationReason)
                Button("Cancel Booking", role: .destructive) {
                    Task {
                        await cancelBooking()
                    }
                }
                .disabled(cancellationReason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                Button("Keep Booking", role: .cancel) {
                    selectedBooking = nil
                    cancellationReason = ""
                }
            } message: {
                Text("Please provide a reason for cancelling this booking.")
            }
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                Text("My Bookings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Book New Button
                Button(action: {
                    showingBookingFlow = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                        Text("Book New")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(AppConstants.Colors.primaryRed)
                    .cornerRadius(20)
                }
                
                Button(action: {
                    Task {
                        await loadInitialData()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                        .foregroundColor(AppConstants.Colors.primaryRed)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .padding(.bottom, 8)
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
            // Always show bookings list (no more embedded booking form)
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
        .fullScreenCover(isPresented: $showingBookingFlow) {
            BookingFlowView()
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
                            // For now, just show a simple alert
                            print("Pay now for booking: \(booking.uid)")
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
                    BookingsEmptyStateView(
                        icon: emptyStateIcon,
                        title: emptyStateTitle,
                        message: emptyStateMessage,
                        showBookNewButton: false, // Remove redundant button - header button is always available
                        onBookNew: {
                            showingBookingFlow = true
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Computed Properties
    
    private var currentBookings: [Booking] {
        switch selectedTab {
        case 0: 
            // Active tab: Show confirmed, accepted, upcoming, and pending bookings (exclude cancelled)
            return bookingService.bookings.filter { booking in
                (booking.status == .confirmed || 
                 booking.status == .accepted || 
                 booking.status == .pending ||
                 booking.isUpcoming == true) &&
                booking.status != .cancelled
            }.sorted { $0.start < $1.start }
        case 1: 
            // History tab: Show past and cancelled bookings (exclude pending)
            return bookingService.bookings.filter { booking in
                (booking.status == .cancelled || booking.isPast == true) &&
                booking.status != .pending
            }.sorted { $0.start > $1.start }
        default: return []
        }
    }
    
    private var emptyStateTitle: String {
        switch selectedTab {
        case 0: return "No Active Bookings"
        case 1: return "No History"
        default: return "No Bookings"
        }
    }
    
    private var emptyStateMessage: String {
        switch selectedTab {
        case 0: return "You don't have any current or upcoming training sessions."
        case 1: return "You don't have any past or cancelled sessions."
        default: return "No bookings found."
        }
    }
    
    private var emptyStateIcon: String {
        switch selectedTab {
        case 0: return "calendar.badge.clock"
        case 1: return "clock.badge.checkmark"
        default: return "calendar"
        }
    }
    
    // MARK: - Actions
    
    private func loadInitialData() async {
        do {
            try await bookingService.fetchBookings()
        } catch {
            print("Failed to load bookings: \(error)")
        }
    }
    
    private func cancelBooking() async {
        guard let booking = selectedBooking else { return }
        
        do {
            try await bookingService.cancelBooking(
                bookingUid: booking.uid,
                cancellationReason: cancellationReason
            )
            
            await MainActor.run {
                selectedBooking = nil
                cancellationReason = ""
            }
            
            await loadInitialData()
        } catch {
            print("Failed to cancel booking: \(error)")
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
    
}

// MARK: - Bookings Empty State View

struct BookingsEmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let showBookNewButton: Bool
    let onBookNew: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)
            
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            if showBookNewButton {
                Button(action: onBookNew) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                        Text("Book New Session")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(AppConstants.Colors.primaryRed)
                    .cornerRadius(25)
                }
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

#Preview {
    CombinedBookingView()
}
