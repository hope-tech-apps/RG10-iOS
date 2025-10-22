//
//  BookingView.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/17/25.
//

import SwiftUI
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
                        
                        if !canModify && booking.isUpcoming == true {
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
                
                if let location = booking.location, !location.isEmpty {
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
        case .confirmed, .upcoming, .accepted:
            return .green
        case .cancelled:
            return .red
        case .past:
            return .gray
        case .pending:
            return .orange
        case .rejected:
            return .red
        case .current:
            return .purple
        case .unconfirmed:
            return .yellow
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

