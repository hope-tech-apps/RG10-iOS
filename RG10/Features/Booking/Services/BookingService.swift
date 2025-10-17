//
//  BookingService.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/17/25.
//

import Foundation
import Supabase
import Combine
import Supabase

// MARK: - Booking Service
class BookingService: ObservableObject {
    static let shared = BookingService()
    
    private let client = SupabaseClientManager.shared.client
    
    @Published var bookings: [Booking] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private init() {}
    
    // MARK: - Fetch Bookings (Using GET)
    
    func fetchBookings(email: String? = nil, status: BookingStatus? = nil, page: Int = 1, take: Int = 25) async throws -> [Booking] {
        // Use provided email or get current user's email
        let userEmail = email ?? SupabaseClientManager.shared.currentUserEmail
        
        guard let validEmail = userEmail else {
            throw BookingError.invalidEmail
        }
        
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            // Use direct HTTP GET request for fetching bookings
            let baseURL = "https://uwssjvqlsekveqvdkdnj.supabase.co/functions/v1"
            let functionName = "get-bookings"
            
            var components = URLComponents(string: "\(baseURL)/\(functionName)")!
            components.queryItems = [
                URLQueryItem(name: "email", value: validEmail),
                URLQueryItem(name: "take", value: String(take)),
                URLQueryItem(name: "page", value: String(page))
            ]
            
            if let status = status {
                components.queryItems?.append(URLQueryItem(name: "status", value: status.rawValue))
            }
            
            guard let url = components.url else {
                throw BookingError.fetchFailed("Invalid URL")
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            // Set headers expected by the Edge Function. If you have a public anon key available, prefer using it here.
            // Try to use the current session's access token if available
            if let session = try? await client.auth.session {
                let accessToken = session.accessToken
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw BookingError.fetchFailed("Invalid response")
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw BookingError.fetchFailed("Server error (\(httpResponse.statusCode)): \(errorMessage)")
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let edgeResponse = try decoder.decode(EdgeFunctionResponse<[Booking]>.self, from: data)
            
            if edgeResponse.status == "success", let fetchedBookings = edgeResponse.data {
                await MainActor.run {
                    self.bookings = fetchedBookings
                    self.isLoading = false
                }
                return fetchedBookings
            } else {
                throw BookingError.fetchFailed(edgeResponse.error ?? "Unknown error")
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }
    
    // MARK: - Cancel Booking (Using POST via functions.invoke)
    
    func cancelBooking(bookingUid: String, reason: String? = nil) async throws {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            struct CancelBookingPayload: Encodable {
                let bookingUid: String
                let cancellationReason: String
            }
            
            let payload = CancelBookingPayload(
                bookingUid: bookingUid,
                cancellationReason: reason ?? "Cancelled by user"
            )
            let encodedBody = try JSONEncoder().encode(payload)
            
            // Cancel uses POST, so functions.invoke is appropriate
            let response: EdgeFunctionResponse<BookingActionResponse> = try await client.functions.invoke(
                "cancel-booking",
                options: FunctionInvokeOptions(
                    headers: ["Content-Type": "application/json"],
                    body: encodedBody
                )
            )
            
            if response.status == "success" {
                await MainActor.run {
                    self.bookings.removeAll { $0.uid == bookingUid }
                    self.isLoading = false
                }
            } else {
                throw BookingError.cancelFailed(response.error ?? "Failed to cancel booking")
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }
    
    // MARK: - Reschedule Booking (Using POST via functions.invoke)
    
    func rescheduleBooking(bookingUid: String, newStartTime: Date, reason: String? = nil) async throws {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            struct RescheduleBookingPayload: Encodable {
                let bookingUid: String
                let start: String
                let reschedulingReason: String
            }
            
            let isoFormatter = ISO8601DateFormatter()
            let payload = RescheduleBookingPayload(
                bookingUid: bookingUid,
                start: isoFormatter.string(from: newStartTime),
                reschedulingReason: reason ?? "Rescheduled by user"
            )
            let encodedBody = try JSONEncoder().encode(payload)
            
            // Reschedule uses POST, so functions.invoke is appropriate
            let response: EdgeFunctionResponse<Booking> = try await client.functions.invoke(
                "reschedule-booking",
                options: FunctionInvokeOptions(
                    headers: ["Content-Type": "application/json"],
                    body: encodedBody
                )
            )
            
            if response.status == "success", let updatedBooking = response.data {
                await MainActor.run {
                    if let index = self.bookings.firstIndex(where: { $0.uid == bookingUid }) {
                        self.bookings[index] = updatedBooking
                    }
                    self.isLoading = false
                }
            } else {
                throw BookingError.rescheduleFailed(response.error ?? "Failed to reschedule booking")
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }
    
    // MARK: - Helper Methods
    
    func canModifyBooking(_ booking: Booking) -> Bool {
        let hoursUntilBooking = booking.start.timeIntervalSinceNow / 3600
        return hoursUntilBooking >= 24 && booking.status != .cancelled && booking.status != .rejected
    }
    
    func upcomingBookings() -> [Booking] {
        return bookings.filter { $0.isUpcoming }
            .sorted { $0.start < $1.start }
    }
    
    func pastBookings() -> [Booking] {
        return bookings.filter { $0.isPast }
            .sorted { $0.start > $1.start }
    }
    
    func clearBookings() {
        bookings.removeAll()
        errorMessage = nil
    }
    
    func refreshBookings(email: String? = nil) async throws {
        try await fetchBookings(email: email)
    }
}

// MARK: - Supporting Types

struct BookingActionResponse: Codable {
    let bookingUid: String
    let cancelled: Bool?
    let data: [String: String]?
}

enum BookingError: LocalizedError {
    case fetchFailed(String)
    case cancelFailed(String)
    case rescheduleFailed(String)
    case invalidEmail
    case noBookingFound
    
    var errorDescription: String? {
        switch self {
        case .fetchFailed(let message):
            return message
        case .cancelFailed(let message):
            return message
        case .rescheduleFailed(let message):
            return message
        case .invalidEmail:
            return "No user email found. Please sign in."
        case .noBookingFound:
            return "Booking not found"
        }
    }
}

// MARK: - Date Extensions
extension Date {
    var bookingDisplayFormat: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    var dayMonthFormat: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: self)
    }
    
    var timeFormat: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    var isWithin24Hours: Bool {
        return self.timeIntervalSinceNow < (24 * 60 * 60)
    }
}

