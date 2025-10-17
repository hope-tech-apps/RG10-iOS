//
//  RescheduleView.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/17/25.
//


import SwiftUI

struct RescheduleView: View {
    let booking: Booking?
    @Binding var newDate: Date
    @Binding var reason: String
    let onReschedule: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    // Calculate minimum date (24 hours from now)
    private var minimumDate: Date {
        Date().addingTimeInterval(24 * 60 * 60)
    }
    
    // Available time slots
    private let availableHours = [9, 10, 11, 14, 15, 16, 17, 18, 19]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Reschedule Session")
                            .font(.system(size: 24, weight: .bold))
                        
                        if let booking = booking {
                            Text(booking.title)
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                    Spacer()
                }
                .padding()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Current Booking Info
                        if let booking = booking {
                            CurrentBookingInfo(booking: booking)
                        }
                        
                        // Date Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Select New Date", systemImage: "calendar")
                                .font(.system(size: 16, weight: .semibold))
                            
                            DatePicker(
                                "Date",
                                selection: $newDate,
                                in: minimumDate...,
                                displayedComponents: .date
                            )
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .padding()
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(12)
                        }
                        
                        // Time Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Select Time", systemImage: "clock")
                                .font(.system(size: 16, weight: .semibold))
                            
                            TimeSlotGrid(selectedDate: $newDate, availableHours: availableHours)
                        }
                        
                        // Reason Field
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Reason (Optional)", systemImage: "text.alignleft")
                                .font(.system(size: 16, weight: .semibold))
                            
                            TextField("Why are you rescheduling?", text: $reason, axis: .vertical)
                                .lineLimit(3...6)
                                .padding()
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(8)
                        }
                        
                        // Warning Message
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            
                            Text("You cannot reschedule within 24 hours of the new session time.")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .padding()
                }
                
                // Bottom Actions
                HStack(spacing: 16) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(25)
                    
                    Button(action: onReschedule) {
                        Text("Reschedule")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppColors.primary)
                            .cornerRadius(25)
                    }
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Current Booking Info

struct CurrentBookingInfo: View {
    let booking: Booking
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Current Session")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(booking.start.dayMonthFormat)
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text(booking.start.timeFormat)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("→")
                    .font(.system(size: 20))
                    .foregroundColor(.gray)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("New Date")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Text("Select below")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.primary)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
        }
    }
}

// MARK: - Time Slot Grid

struct TimeSlotGrid: View {
    @Binding var selectedDate: Date
    let availableHours: [Int]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    private var calendar: Calendar {
        Calendar.current
    }
    
    private func timeForHour(_ hour: Int) -> Date {
        var components = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        components.hour = hour
        components.minute = 0
        return calendar.date(from: components) ?? selectedDate
    }
    
    private func isSelected(_ hour: Int) -> Bool {
        let currentHour = calendar.component(.hour, from: selectedDate)
        return currentHour == hour
    }
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(availableHours, id: \.self) { hour in
                Button(action: {
                    selectedDate = timeForHour(hour)
                }) {
                    Text(formatHour(hour))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(isSelected(hour) ? .white : .black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(isSelected(hour) ? AppColors.primary : Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
    }
    
    private func formatHour(_ hour: Int) -> String {
        if hour < 12 {
            return "\(hour):00 AM"
        } else if hour == 12 {
            return "12:00 PM"
        } else {
            return "\(hour - 12):00 PM"
        }
    }
}

// MARK: - Loading View

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primary))
                .scaleEffect(1.2)
            
            Text("Loading bookings...")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Error View

struct ErrorView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.red.opacity(0.8))
            
            Text("Error Loading Bookings")
                .font(.system(size: 18, weight: .semibold))
            
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: onRetry) {
                Text("Retry")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(AppColors.primary)
                    .cornerRadius(20)
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - App Colors

struct AppColors {
    static let primary = Color(red: 237/255, green: 28/255, blue: 36/255)  // RG10 Red
    static let black = Color.black
    static let background = Color(UIColor.systemBackground)
}