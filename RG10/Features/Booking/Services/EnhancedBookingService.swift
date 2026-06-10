//
//  EnhancedBookingService.swift
//  RG10
//
//  Created by Moneeb Sayed on 1/17/25.
//

import Foundation
import Supabase
import Combine

// MARK: - Enhanced Booking Service (Matching Kotlin Implementation)

@MainActor
final class EnhancedBookingService: ObservableObject {
    static let shared = EnhancedBookingService()
    
    // MARK: - Published Properties
    
    @Published private(set) var bookings: [Booking] = []
    @Published private(set) var bookingTypes: [BookingType] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var lastFetchTime: Date?
    
    // MARK: - Private Properties
    
    private let client = SupabaseClientManager.shared.client
    private let paymentAPI = SupabasePaymentAPI.shared
    
    // Caching (matching Kotlin implementation)
    private var cachedBookingTypes: [BookingType]?
    private var cachedBookings: GetBookingsResponse?
    
    // Function names (matching Kotlin)
    private enum FunctionName {
        static let createBookingIntent = "payments-create-booking-intent"
        static let createSubscriptionSession = "billing-create-subscription-session"
        static let cancelSubscription = "cancel-subscription"
        static let cancelBooking = "cancel-booking"
        static let abortSubscriptionIntent = "abort-subscription-intent"
        static let getBookings = "get-bookings"
    }
    
    private init() {
        MemoryMonitor.shared.objectInitialized("EnhancedBookingService")
        // Initialize with cached data if available
        Task {
            await loadCachedBookingTypes()
        }
    }
    
    // MARK: - Booking Types Management (Matching Kotlin)
    
    /// Fetches booking types with caching
    func fetchBookingTypes(forceRefresh: Bool = false) async throws -> [BookingType] {
        if !forceRefresh, let cached = cachedBookingTypes {
            return cached
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await client
                .from("bookings")
                .select()
                .execute()
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let fetchedTypes = try decoder.decode([BookingType].self, from: response.data)
            
            cachedBookingTypes = fetchedTypes
            bookingTypes = fetchedTypes
            isLoading = false
            
            return fetchedTypes
            
        } catch {
            isLoading = false
            errorMessage = "Unable to load booking types. Please try again."
            throw BookingError.fetchFailed(error.localizedDescription)
        }
    }
    
    /// Gets cached booking types
    func getCachedBookingTypes() -> [BookingType]? {
        return cachedBookingTypes
    }
    
    /// Clears booking types cache
    func clearBookingTypesCache() {
        cachedBookingTypes = nil
        bookingTypes.removeAll()
    }
    
    // MARK: - Enhanced Booking Fetching (Matching Kotlin)
    
    /// Fetches bookings with comprehensive response handling
    func fetchBookings(
        forceRefresh: Bool = false,
        email: String? = nil
    ) async throws -> GetBookingsResponse {
        // Use cached data if available and not forcing refresh
        if !forceRefresh, let cached = cachedBookings {
            return cached
        }
        
        let userEmail = email ?? SupabaseClientManager.shared.currentUserEmail
        
        guard let validEmail = userEmail else {
            throw BookingError.invalidEmail
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await runSupabaseFunction(
                functionName: FunctionName.getBookings,
                fallbackMessage: "Unable to fetch bookings. Please try again.",
                parameters: [("email", validEmail)]
            ) { text in
                #if DEBUG
                // Only log summary, not full response (saves memory)
                print("🔍 Get-bookings response length: \(text.count) characters")
                #endif
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let decodedResponse = try decoder.decode(GetBookingsResponse.self, from: text.data(using: .utf8)!)
                
                #if DEBUG
                print("🔍 Decoded response status: \(decodedResponse.status)")
                print("🔍 Booking counts - past: \(decodedResponse.data.past.count), cancelled: \(decodedResponse.data.cancelled.count)")
                #endif
                
                return decodedResponse
            }
            
            cachedBookings = response
            bookings = getAllBookings(from: response)
            lastFetchTime = Date()
            isLoading = false
            
            return response
            
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    /// Gets all bookings from response data
    private func getAllBookings(from response: GetBookingsResponse) -> [Booking] {
        var allBookings: [Booking] = []
        allBookings.append(contentsOf: response.data.current)
        allBookings.append(contentsOf: response.data.upcoming)
        allBookings.append(contentsOf: response.data.past)
        allBookings.append(contentsOf: response.data.cancelled)
        allBookings.append(contentsOf: response.data.unconfirmed)
        return allBookings
    }
    
    // MARK: - Booking Operations (Matching Kotlin)
    
    /// Creates a booking payment intent
    func createBookingIntent(userId: String, bookingUid: String) async throws -> BookingIntentResponse {
        return try await runSupabaseFunction(
            functionName: FunctionName.createBookingIntent,
            fallbackMessage: "Unable to prepare your checkout. Please try again.",
            buildBody: { builder in
                builder["bookingUid"] = .string(bookingUid)
                builder["user_id"] = .string(userId)
            },
            requestType: "POST"
        ) { text in
            try JSONDecoder().decode(BookingIntentResponse.self, from: text.data(using: .utf8)!)
        }
    }
    
    /// Cancels a booking with comprehensive options
    func cancelBooking(
        bookingUid: String,
        cancellationReason: String,
        cancelSubsequentBookings: Bool = false,
        paymentIntentId: String? = nil
    ) async throws {
        try await runSupabaseFunction(
            functionName: FunctionName.cancelBooking,
            fallbackMessage: "Unable to cancel the booking at this time. Please try again.",
            buildBody: { builder in
                builder["bookingUid"] = .string(bookingUid)
                
                builder["cancellationReason"] = .string(cancellationReason)
                
                if cancelSubsequentBookings {
                    builder["cancelSubsequentBookings"] = .bool(cancelSubsequentBookings)
                }
                
                if let paymentIntentId = paymentIntentId, !paymentIntentId.isEmpty {
                    builder["payment_intent_id"] = .string(paymentIntentId)
                }
            },
            requestType: "POST"
        ) { _ in
            // Void return type
        }
        
        // Remove from local cache
        bookings.removeAll { $0.uid == bookingUid }
    }
    
    /// Reschedules a booking
    func rescheduleBooking(
        bookingUid: String,
        newStartTime: Date,
        reason: String? = nil
    ) async throws -> Booking {
        return try await runSupabaseFunction(
            functionName: "reschedule-booking",
            fallbackMessage: "Unable to reschedule the booking. Please try again.",
            buildBody: { builder in
                builder["bookingUid"] = .string(bookingUid)
                builder["start"] = .string(ISO8601DateFormatter().string(from: newStartTime))
                builder["reschedulingReason"] = .string(reason ?? "Rescheduled by user")
            },
            requestType: "POST"
        ) { text in
            try JSONDecoder().decode(Booking.self, from: text.data(using: .utf8)!)
        }
    }
    
    // MARK: - Helper Methods (Matching Kotlin)
    
    /// Checks if booking can be modified
    func canModifyBooking(_ booking: Booking) -> Bool {
        let hoursUntilBooking = booking.start.timeIntervalSinceNow / 3600
        return hoursUntilBooking >= 24 && 
               booking.status != .cancelled && 
               booking.status != .rejected &&
               booking.canCancel == true
    }
    
    /// Gets upcoming bookings
    func upcomingBookings() -> [Booking] {
        return bookings.filter { $0.isUpcoming == true }
            .sorted { $0.start < $1.start }
    }
    
    /// Gets past bookings
    func pastBookings() -> [Booking] {
        return bookings.filter { $0.isPast == true }
            .sorted { $0.start > $1.start }
    }
    
    /// Gets current bookings
    func currentBookings() -> [Booking] {
        return bookings.filter { $0.isCurrent == true }
            .sorted { $0.start < $1.start }
    }
    
    /// Gets cancelled bookings
    func cancelledBookings() -> [Booking] {
        return bookings.filter { $0.status == .cancelled }
            .sorted { $0.start > $1.start }
    }
    
    /// Gets unconfirmed bookings
    func unconfirmedBookings() -> [Booking] {
        return bookings.filter { $0.status == .unconfirmed }
            .sorted { $0.start < $1.start }
    }
    
    /// Clears all cached data
    func clearCache() {
        cachedBookingTypes = nil
        cachedBookings = nil
        bookings.removeAll()
        bookingTypes.removeAll()
        errorMessage = nil
        lastFetchTime = nil
    }
    
    /// Refreshes bookings
    func refreshBookings(email: String? = nil) async throws {
        try await fetchBookings(forceRefresh: true, email: email)
    }
    
    // MARK: - Payment Integration
    
    /// Handles successful payment completion
    func handlePaymentSuccess(bookingUid: String) async {
        do {
            try await refreshBookings()
        } catch {
            print("Failed to refresh bookings after payment: \(error)")
        }
    }
    
    // MARK: - Private Methods
    
    /// Loads cached booking types on init
    private func loadCachedBookingTypes() async {
        // In a real implementation, you might load from UserDefaults or Core Data
        // For now, we'll just initialize empty
    }
    
    /// Generic function runner (matching Kotlin implementation)
    private func runSupabaseFunction<T>(
        functionName: String,
        fallbackMessage: String,
        buildBody: ((inout JSONObjectBuilder) -> Void)? = nil,
        requestType: String = "GET",
        parameters: [(String, String)]? = nil,
        parser: (String) throws -> T
    ) async throws -> T {
        do {
            let response: Any
            
            if requestType == "GET" {
                // For GET requests, we'll use the Supabase client's REST API directly
                var urlComponents = URLComponents()
                urlComponents.scheme = "https"
                urlComponents.host = "uwssjvqlsekveqvdkdnj.supabase.co"
                urlComponents.path = "/functions/v1/\(functionName)"
                
                if let params = parameters {
                    urlComponents.queryItems = params.map { URLQueryItem(name: $0.0, value: $0.1) }
                }
                
                guard let url = urlComponents.url else {
                    throw BookingError.fetchFailed("Invalid URL")
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                // Add auth header if available
                if let session = try? await client.auth.session {
                    request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
                }
                
                let (data, urlResponse) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    throw BookingError.fetchFailed("Invalid response")
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                    throw BookingError.fetchFailed("Server error (\(httpResponse.statusCode)): \(errorMessage)")
                }
                
                response = data
            } else {
                // POST request using Supabase functions
                var bodyData: Data?
                
                if let buildBody = buildBody {
                    var jsonBuilder = JSONObjectBuilder()
                    buildBody(&jsonBuilder)
                    bodyData = try JSONSerialization.data(withJSONObject: jsonBuilder.build())
                }
                
                let options = FunctionInvokeOptions(
                    headers: ["Content-Type": "application/json"],
                    body: bodyData
                )
                
                response = try await client.functions.invoke(functionName, options: options)
            }
            
            // Parse the actual response from Supabase function
            let responseText: String
            if let responseData = response as? Data {
                responseText = String(data: responseData, encoding: .utf8) ?? ""
            } else if let responseString = response as? String {
                responseText = responseString
            } else {
                // Try to convert to string
                responseText = String(describing: response)
            }
            
            return try parser(responseText)
            
        } catch {
            if error is BookingError {
                throw error
            }
            throw BookingError.fetchFailed(error.localizedDescription)
        }
    }
    
    /// Sanitizes Supabase error messages (matching Kotlin implementation)
    private func sanitizeSupabaseMessage(_ raw: String?, fallback: String) -> String {
        guard let raw = raw, !raw.isEmpty else { return fallback }
        
        do {
            if let jsonData = raw.data(using: .utf8),
               let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
               let message = json["message"] as? String {
                let candidate = message.trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Check for forbidden tokens (matching Kotlin implementation)
                let forbiddenTokens = ["http://", "https://", "apikey", "authorization", "bearer ", "supabase.co"]
                if forbiddenTokens.contains(where: { candidate.lowercased().contains($0) }) {
                    return fallback
                }
                
                return String(candidate.prefix(200))
            }
        } catch {
            // If JSON parsing fails, check raw string
            let candidate = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            let forbiddenTokens = ["http://", "https://", "apikey", "authorization", "bearer ", "supabase.co"]
            if forbiddenTokens.contains(where: { candidate.lowercased().contains($0) }) {
                return fallback
            }
            return String(candidate.prefix(200))
        }
        
        return fallback
    }
}

// MARK: - JSON Object Builder

struct JSONObjectBuilder {
    private var dictionary: [String: AnyJSON] = [:]
    
    subscript(key: String) -> AnyJSON? {
        get { dictionary[key] }
        set { dictionary[key] = newValue }
    }
    
    mutating func build() -> [String: Any] {
        return dictionary.mapValues { $0.value }
    }
}
