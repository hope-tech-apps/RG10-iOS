//
//  BookingWebView.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/9/25.
//

import SwiftUI

import SwiftUI

// MARK: - Simple Booking View (Opens in Safari)

struct BookingView: View {
    @StateObject private var bookingService = BookingService.shared
    @StateObject private var coachViewModel = CoachViewModel.shared
    @State private var selectedTab = 0
    @State private var showingCoachSelection = false
    @State private var selectedBooking: Booking?
    @State private var showingActionSheet = false
    @State private var showingCancelAlert = false
    @State private var showingRescheduleSheet = false
    @State private var cancellationReason = ""
    @State private var rescheduleDate = Date()
    @State private var rescheduleReason = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Segmented Control
                Picker("Bookings", selection: $selectedTab) {
                    Text("Upcoming").tag(0)
                    Text("Past").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.vertical, 12)
                
                // Content
                if bookingService.isLoading {
                    LoadingView()
                } else if bookingService.errorMessage != nil {
                    ErrorView(message: bookingService.errorMessage ?? "Unknown error") {
                        Task {
                            try await bookingService.fetchBookings()
                        }
                    }
                } else {
                    bookingsList
                }
            }
            .navigationBarHidden(true)
            .task {
                do {
                    try await bookingService.fetchBookings()
                } catch {
                    print("Error fetching bookings: \(error)")
                }
            }
        }
        .sheet(isPresented: $showingCoachSelection) {
            CoachSelectionView(
                coaches: coachViewModel.coaches,
                onSelect: { coach in
                    showingCoachSelection = false
                    // Open Cal.com directly in Safari
                    if let url = URL(string: coach.scheduleLink ?? "") {
                        UIApplication.shared.open(url)
                    }
                }
            )
        }
        .confirmationDialog(
            "Manage Booking",
            isPresented: $showingActionSheet,
            titleVisibility: .visible
        ) {
            if let booking = selectedBooking {
                if bookingService.canModifyBooking(booking) {
                    Button("Cancel Booking", role: .destructive) {
                        showingCancelAlert = true
                    }
                    
                    Button("Reschedule") {
                        rescheduleDate = booking.start
                        showingRescheduleSheet = true
                    }
                }
                
                Button("Cancel", role: .cancel) { }
            }
        }
        .alert("Cancel Booking", isPresented: $showingCancelAlert) {
            TextField("Reason (optional)", text: $cancellationReason)
            
            Button("Cancel Booking", role: .destructive) {
                if let booking = selectedBooking {
                    Task {
                        try await bookingService.cancelBooking(
                            bookingUid: booking.uid,
                            reason: cancellationReason.isEmpty ? nil : cancellationReason
                        )
                        cancellationReason = ""
                    }
                }
            }
            
            Button("Keep Booking", role: .cancel) {
                cancellationReason = ""
            }
        } message: {
            Text("Are you sure you want to cancel this booking? This action cannot be undone.")
        }
        .sheet(isPresented: $showingRescheduleSheet) {
            RescheduleView(
                booking: selectedBooking,
                newDate: $rescheduleDate,
                reason: $rescheduleReason,
                onReschedule: {
                    if let booking = selectedBooking {
                        Task {
                            try await bookingService.rescheduleBooking(
                                bookingUid: booking.uid,
                                newStartTime: rescheduleDate,
                                reason: rescheduleReason.isEmpty ? nil : rescheduleReason
                            )
                            rescheduleReason = ""
                            showingRescheduleSheet = false
                        }
                    }
                }
            )
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Book")
                    .font(.system(size: 32, weight: .bold))
                
                Text("Manage your training sessions")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {
                showingCoachSelection = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Book")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(AppColors.primary)
                .cornerRadius(20)
            }
        }
        .padding()
    }
    
    // MARK: - Bookings List
    
    private var bookingsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                let bookings = selectedTab == 0 ? bookingService.upcomingBookings() : bookingService.pastBookings()
                
                if bookings.isEmpty {
                    EmptyBookingsView(isUpcoming: selectedTab == 0) {
                        showingCoachSelection = true
                    }
                    .padding(.top, 50)
                } else {
                    ForEach(bookings) { booking in
                        BookingCard(
                            booking: booking,
                            canModify: bookingService.canModifyBooking(booking)
                        ) {
                            selectedBooking = booking
                            showingActionSheet = true
                        }
                    }
                }
            }
            .padding()
        }
        .refreshable {
            do {
                try await bookingService.refreshBookings()
            } catch {
                print("Error refreshing bookings: \(error)")
            }
        }
    }
}

// MARK: - Coach Selection View (Simplified)

struct CoachSelectionView: View {
    let coaches: [Coach]
    let onSelect: (Coach) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Select a Coach")
                        .font(.system(size: 24, weight: .bold))
                    Spacer()
                }
                .padding()
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(coaches, id: \.name) { coach in
                            CoachSelectionCard(coach: coach) {
                                onSelect(coach)
                            }
                        }
                    }
                    .padding()
                }
                
                // Info text
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                    Text("You'll be redirected to Cal.com to complete your booking")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.blue.opacity(0.05))
                .cornerRadius(8)
                .padding()
            }
            .navigationBarHidden(true)
            .overlay(alignment: .topTrailing) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                        .padding()
                }
            }
        }
    }
}

// MARK: - Coach Selection Card

struct CoachSelectionCard: View {
    let coach: Coach
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Coach Image
                AsyncImage(url: URL(string: coach.imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(coach.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Text(coach.role)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    HStack {
                        Image(systemName: "safari")
                        Text("Opens in Safari")
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.primary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.forward")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
