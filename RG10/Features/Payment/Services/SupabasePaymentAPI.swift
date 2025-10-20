//
//  SupabasePaymentAPI.swift
//  RG10
//
//  Created by Moneeb Sayed on 1/17/25.
//

import Foundation
import Supabase

// MARK: - Supabase Payment API

actor SupabasePaymentAPI {
    static let shared = SupabasePaymentAPI()
    
    private let client = SupabaseClientManager.shared.client
    
    // MARK: - Function Names (Matching Kotlin)
    
    private enum FunctionName {
        static let createBookingIntent = "payments-create-booking-intent"
        static let createSubscriptionSession = "billing-create-subscription-session"
        static let cancelSubscription = "cancel-subscription"
        static let cancelBooking = "cancel-booking"
        static let abortSubscriptionIntent = "abort-subscription-intent"
        static let getBookings = "get-bookings"
    }
    
    private init() {}
    
    // MARK: - Booking Intent Creation
    
    /// Creates a booking payment intent (matching Kotlin implementation)
    func createBookingIntent(
        userId: String,
        bookingUid: String
    ) async throws -> BookingIntentResponse {
        print("🔗 Creating booking intent for userId: \(userId), bookingUid: \(bookingUid)")
        print("🔗 Supabase URL: https://uwssjvqlsekveqvdkdnj.supabase.co")
        
        // Use direct HTTP call to Supabase edge function
        var bodyData: Data?
        
        var jsonBuilder = JSONObjectBuilder()
        jsonBuilder["bookingUid"] = .string(bookingUid)
        jsonBuilder["user_id"] = .string(userId)
        let jsonObject = jsonBuilder.build()
        
        // Convert Any values to proper JSON-serializable types
        let serializableObject: [String: Any] = jsonObject.mapValues { value in
            if let stringValue = value as? String {
                return stringValue
            } else if let intValue = value as? Int {
                return intValue
            } else if let doubleValue = value as? Double {
                return doubleValue
            } else if let boolValue = value as? Bool {
                return boolValue
            } else {
                return String(describing: value)
            }
        }
        
        bodyData = try JSONSerialization.data(withJSONObject: serializableObject)
        
        print("🔗 Calling Supabase function directly: \(FunctionName.createBookingIntent)")
        print("🔗 Request body: \(String(data: bodyData ?? Data(), encoding: .utf8) ?? "nil")")
        
        // Make direct HTTP request to Supabase edge function
        let url = URL(string: "https://uwssjvqlsekveqvdkdnj.supabase.co/functions/v1/\(FunctionName.createBookingIntent)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyData
        
        // Add auth header if available
        if let session = try? await client.auth.session {
            request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, urlResponse) = try await URLSession.shared.data(for: request)
        
        print("🔗 Direct HTTP response received, data length: \(data.count)")
        
        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            throw PaymentError.networkError(NSError(domain: "InvalidResponse", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
        }
        
        print("🔗 HTTP response status: \(httpResponse.statusCode)")
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ HTTP error (\(httpResponse.statusCode)): \(errorMessage)")
            throw PaymentError.networkError(NSError(domain: "ServerError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error (\(httpResponse.statusCode)): \(errorMessage)"]))
        }
        
        let responseString = String(data: data, encoding: .utf8) ?? ""
        print("🔗 HTTP success response: \(responseString)")
        
        if responseString.isEmpty || responseString == "()" {
            print("❌ Supabase function returned empty response")
            throw PaymentError.networkError(NSError(domain: "EmptyResponse", code: -1, userInfo: [NSLocalizedDescriptionKey: "Edge function returned empty response. Please check your 'payments-create-booking-intent' function implementation."]))
        }
        
        return try JSONDecoder().decode(BookingIntentResponse.self, from: data)
    }
    
    // MARK: - Subscription Management
    
    /// Creates a subscription session (matching Kotlin implementation)
    func createSubscriptionSession(
        userId: String,
        priceId: String
    ) async throws -> CreateSubscriptionIntentResponse {
        return try await runSupabaseFunction(
            functionName: FunctionName.createSubscriptionSession,
            fallbackMessage: "Unable to start subscription checkout. Please try again.",
            buildBody: { builder in
                builder["user_id"] = .string(userId)
                builder["price_id"] = .string(priceId)
            },
            requestType: "POST"
        ) { text in
            try JSONDecoder().decode(CreateSubscriptionIntentResponse.self, from: text.data(using: .utf8)!)
        }
    }
    
    /// Cancels a subscription (matching Kotlin implementation)
    func cancelSubscription(
        userId: String,
        subscriptionId: String
    ) async throws -> CancelSubscriptionResponse {
        return try await runSupabaseFunction(
            functionName: FunctionName.cancelSubscription,
            fallbackMessage: "Unable to cancel your membership right now. Please try again.",
            buildBody: { builder in
                builder["user_id"] = .string(userId)
                builder["stripe_subscription_id"] = .string(subscriptionId)
            },
            requestType: "POST"
        ) { text in
            try JSONDecoder().decode(CancelSubscriptionResponse.self, from: text.data(using: .utf8)!)
        }
    }
    
    /// Cancels a booking (matching Kotlin implementation)
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
    }
    
    /// Aborts a subscription intent (matching Kotlin implementation)
    func abortSubscriptionIntent(subscriptionId: String) async throws {
        try await runSupabaseFunction(
            functionName: FunctionName.abortSubscriptionIntent,
            fallbackMessage: "Unable to cancel the subscription attempt. Please try again.",
            buildBody: { builder in
                builder["subscription_id"] = .string(subscriptionId)
            },
            requestType: "POST"
        ) { _ in
            // Void return type
        }
    }
    
    // MARK: - Generic Function Runner
    
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
                // Build URL with query parameters
                var components = URLComponents()
                components.scheme = "https"
                components.host = "uwssjvqlsekveqvdkdnj.supabase.co"
                components.path = "/functions/v1/\(functionName)"
                
                if let parameters = parameters {
                    components.queryItems = parameters.map { URLQueryItem(name: $0.0, value: $0.1) }
                }
                
                guard let url = components.url else {
                    throw PaymentError.networkError(NSError(domain: "InvalidURL", code: -1))
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                // Add auth header if available
                if let session = try? await client.auth.session {
                    request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
                }
                
                response = try await URLSession.shared.data(for: request)
            } else {
                // POST request using Supabase functions
                var bodyData: Data?
                
                if let buildBody = buildBody {
                    var jsonBuilder = await JSONObjectBuilder()
                    buildBody(&jsonBuilder)
                    bodyData = try JSONSerialization.data(withJSONObject: await jsonBuilder.build())
                }
                
                let options = FunctionInvokeOptions(
                    headers: ["Content-Type": "application/json"],
                    body: bodyData
                )
                
                let functionResponse = try await client.functions.invoke(functionName, options: options)
                print("🔗 FunctionInvokeResponse: \(functionResponse)")
                print("🔗 FunctionInvokeResponse type: \(type(of: functionResponse))")
                
                // Check if we got a valid response
                if let responseData = functionResponse as? Data {
                    print("🔗 Response is Data: \(responseData)")
                    response = responseData
                } else if let responseString = functionResponse as? String {
                    print("🔗 Response is String: \(responseString)")
                    response = responseString
                } else {
                    print("🔗 Response is empty tuple or unknown type")
                    response = functionResponse
                }
            }
            
            // Parse the actual response from Supabase function
            let responseText: String
            print("🔗 Raw response type: \(type(of: response))")
            print("🔗 Raw response: \(response)")
            
            if let responseData = response as? Data {
                responseText = String(data: responseData, encoding: .utf8) ?? ""
                print("🔗 Parsed as Data: \(responseText)")
            } else if let responseString = response as? String {
                responseText = responseString
                print("🔗 Parsed as String: \(responseText)")
            } else {
                // Try to convert to string
                responseText = String(describing: response)
                print("🔗 Converted to string: \(responseText)")
            }
            
            // For POST requests, we don't need to check HTTP status as Supabase handles it
            // For GET requests, check HTTP status
            if requestType == "GET" {
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    let message = sanitizeSupabaseMessage("HTTP Error", fallback: fallbackMessage)
                    throw PaymentError.networkError(NSError(domain: "SupabaseError", code: -1, userInfo: [NSLocalizedDescriptionKey: message]))
                }
            }
            
            return try parser(responseText)
            
        } catch {
            if error is PaymentError {
                throw error
            }
            throw PaymentError.networkError(error)
        }
    }
    
    // MARK: - Message Sanitization (Matching Kotlin)
    
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
