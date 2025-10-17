//
//  BookingView.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/17/25.
//


import SwiftUI

//struct BookingView: View {
//    @StateObject private var bookingService = BookingService.shared
//    @StateObject private var coachViewModel = CoachViewModel.shared
//    @State private var selectedTab = 0
//    @State private var showingCoachSelection = false
//    @State private var selectedCoach: Coach?
//    @State private var showingWebView = false
//    @State private var selectedBooking: Booking?
//    @State private var showingActionSheet = false
//    @State private var showingCancelAlert = false
//    @State private var showingRescheduleSheet = false
//    @State private var cancellationReason = ""
//    @State private var rescheduleDate = Date()
//    @State private var rescheduleReason = ""
//    
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 0) {
//                // Header
//                headerView
//                
//                // Segmented Control
//                Picker("Bookings", selection: $selectedTab) {
//                    Text("Upcoming").tag(0)
//                    Text("Past").tag(1)
//                }
//                .pickerStyle(SegmentedPickerStyle())
//                .padding(.horizontal)
//                .padding(.vertical, 12)
//                
//                // Content
//                if bookingService.isLoading {
//                    LoadingView()
//                } else if bookingService.errorMessage != nil {
//                    ErrorView(message: bookingService.errorMessage ?? "Unknown error") {
//                        Task {
//                            try await bookingService.fetchBookings()
//                        }
//                    }
//                } else {
//                    bookingsList
//                }
//            }
//            .navigationBarHidden(true)
//            .task {
//                do {
//                    try await bookingService.fetchBookings()
//                } catch {
//                    print("Error fetching bookings: \(error)")
//                }
//            }
//        }
//        .sheet(isPresented: $showingCoachSelection) {
//            CoachSelectionView(
//                coaches: coachViewModel.coaches,
//                onSelect: { coach in
//                    selectedCoach = coach
//                    showingCoachSelection = false
//                    showingWebView = true
//                }
//            )
//        }
//        .sheet(isPresented: $showingWebView) {
//            if let coach = selectedCoach {
//                BookingWebView(coach: coach)
//                    .onDisappear {
//                        Task {
//                            try await bookingService.refreshBookings()
//                        }
//                    }
//            }
//        }
//        .confirmationDialog(
//            "Manage Booking",
//            isPresented: $showingActionSheet,
//            titleVisibility: .visible
//        ) {
//            if let booking = selectedBooking {
//                if bookingService.canModifyBooking(booking) {
//                    Button("Cancel Booking", role: .destructive) {
//                        showingCancelAlert = true
//                    }
//                    
//                    Button("Reschedule") {
//                        rescheduleDate = booking.start
//                        showingRescheduleSheet = true
//                    }
//                }
//                
//                Button("View Details") {
//                    // Show booking details
//                }
//                
//                Button("Cancel", role: .cancel) { }
//            }
//        }
//        .alert("Cancel Booking", isPresented: $showingCancelAlert) {
//            TextField("Reason (optional)", text: $cancellationReason)
//            
//            Button("Cancel Booking", role: .destructive) {
//                if let booking = selectedBooking {
//                    Task {
//                        try await bookingService.cancelBooking(
//                            bookingUid: booking.uid,
//                            reason: cancellationReason.isEmpty ? nil : cancellationReason
//                        )
//                        cancellationReason = ""
//                    }
//                }
//            }
//            
//            Button("Keep Booking", role: .cancel) {
//                cancellationReason = ""
//            }
//        } message: {
//            Text("Are you sure you want to cancel this booking? This action cannot be undone.")
//        }
//        .sheet(isPresented: $showingRescheduleSheet) {
//            RescheduleView(
//                booking: selectedBooking,
//                newDate: $rescheduleDate,
//                reason: $rescheduleReason,
//                onReschedule: {
//                    if let booking = selectedBooking {
//                        Task {
//                            try await bookingService.rescheduleBooking(
//                                bookingUid: booking.uid,
//                                newStartTime: rescheduleDate,
//                                reason: rescheduleReason.isEmpty ? nil : rescheduleReason
//                            )
//                            rescheduleReason = ""
//                            showingRescheduleSheet = false
//                        }
//                    }
//                }
//            )
//        }
//    }
//    
//    // MARK: - Header View
//    
//    private var headerView: some View {
//        HStack {
//            VStack(alignment: .leading, spacing: 4) {
//                Text("Book")
//                    .font(.system(size: 32, weight: .bold))
//                
//                Text("Manage your training sessions")
//                    .font(.system(size: 14))
//                    .foregroundColor(.gray)
//            }
//            
//            Spacer()
//            
//            Button(action: {
//                showingCoachSelection = true
//            }) {
//                HStack {
//                    Image(systemName: "plus.circle.fill")
//                    Text("Book")
//                }
//                .font(.system(size: 16, weight: .semibold))
//                .foregroundColor(.white)
//                .padding(.horizontal, 16)
//                .padding(.vertical, 10)
//                .background(AppColors.primary)
//                .cornerRadius(20)
//            }
//        }
//        .padding()
//    }
//    
//    // MARK: - Bookings List
//    
//    private var bookingsList: some View {
//        ScrollView {
//            LazyVStack(spacing: 12) {
//                let bookings = selectedTab == 0 ? bookingService.upcomingBookings() : bookingService.pastBookings()
//                
//                if bookings.isEmpty {
//                    EmptyBookingsView(isUpcoming: selectedTab == 0) {
//                        showingCoachSelection = true
//                    }
//                    .padding(.top, 50)
//                } else {
//                    ForEach(bookings) { booking in
//                        BookingCard(
//                            booking: booking,
//                            canModify: bookingService.canModifyBooking(booking)
//                        ) {
//                            selectedBooking = booking
//                            showingActionSheet = true
//                        }
//                    }
//                }
//            }
//            .padding()
//        }
//    }
//}
//
//// MARK: - Update CoachViewModel to use singleton
//extension CoachViewModel {
//    static let shared = CoachViewModel()
//}
//
// MARK: - Booking Card

struct BookingCard: View {
    let booking: Booking
    let canModify: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(booking.title)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                        
                        HStack(spacing: 16) {
                            Label(booking.start.dayMonthFormat, systemImage: "calendar")
                            Label(booking.start.timeFormat, systemImage: "clock")
                        }
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        StatusBadge(status: booking.status)
                        
                        if !canModify && booking.isUpcoming {
                            Text("24hr lock")
                                .font(.system(size: 10))
                                .foregroundColor(.orange)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                }
                
                if let location = booking.location {
                    HStack {
                        Image(systemName: "location.fill")
                            .font(.system(size: 12))
                        Text(location)
                            .font(.system(size: 14))
                    }
                    .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Status Badge

struct StatusBadge: View {
    let status: BookingStatus
    
    var statusColor: Color {
        switch status {
        case .confirmed, .upcoming:
            return .green
        case .cancelled:
            return .red
        case .past:
            return .gray
        case .pending:
            return .orange
        case .rejected:
            return .red
        }
    }
    
    var body: some View {
        Text(status.rawValue.capitalized)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(statusColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.1))
            .cornerRadius(6)
    }
}

// MARK: - Empty Bookings View

struct EmptyBookingsView: View {
    let isUpcoming: Bool
    let onBookTap: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: isUpcoming ? "calendar.badge.plus" : "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text(isUpcoming ? "No upcoming sessions" : "No past sessions")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.gray)
            
            if isUpcoming {
                Text("Book your first training session")
                    .font(.system(size: 14))
                    .foregroundColor(.gray.opacity(0.8))
                
                Button(action: onBookTap) {
                    Text("Book Now")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(AppConstants.Colors.primaryRed)
                        .cornerRadius(25)
                }
                .padding(.top, 8)
            }
        }
    }
}

//// MARK: - Coach Selection View
//
//struct CoachSelectionView: View {
//    let coaches: [Coach]
//    let onSelect: (Coach) -> Void
//    @Environment(\.dismiss) private var dismiss
//    
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 0) {
//                // Header
//                HStack {
//                    Text("Select a Coach")
//                        .font(.system(size: 24, weight: .bold))
//                    Spacer()
//                }
//                .padding()
//                
//                ScrollView {
//                    LazyVStack(spacing: 16) {
//                        ForEach(coaches, id: \.name) { coach in
//                            CoachSelectionCard(coach: coach) {
//                                onSelect(coach)
//                            }
//                        }
//                    }
//                    .padding()
//                }
//            }
//            .navigationBarHidden(true)
//            .overlay(alignment: .topTrailing) {
//                Button(action: { dismiss() }) {
//                    Image(systemName: "xmark.circle.fill")
//                        .font(.system(size: 24))
//                        .foregroundColor(.gray)
//                        .padding()
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Coach Selection Card
//
//struct CoachSelectionCard: View {
//    let coach: Coach
//    let onTap: () -> Void
//    
//    var body: some View {
//        Button(action: onTap) {
//            HStack(spacing: 16) {
//                // Coach Image
//                AsyncImage(url: URL(string: coach.imageURL)) { image in
//                    image
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                } placeholder: {
//                    Rectangle()
//                        .fill(Color.gray.opacity(0.3))
//                }
//                .frame(width: 80, height: 80)
//                .clipShape(Circle())
//                
//                VStack(alignment: .leading, spacing: 6) {
//                    Text(coach.name)
//                        .font(.system(size: 18, weight: .semibold))
//                        .foregroundColor(.black)
//                    
//                    Text(coach.role)
//                        .font(.system(size: 14))
//                        .foregroundColor(.gray)
//                    
//                    HStack {
//                        Image(systemName: "calendar.badge.plus")
//                        Text("Book Session")
//                    }
//                    .font(.system(size: 14, weight: .medium))
//                    .foregroundColor(AppColors.primary)
//                }
//                
//                Spacer()
//                
//                Image(systemName: "chevron.right")
//                    .foregroundColor(.gray)
//            }
//            .padding()
//            .background(Color.white)
//            .cornerRadius(12)
//            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
//        }
//        .buttonStyle(PlainButtonStyle())
//    }
//}
