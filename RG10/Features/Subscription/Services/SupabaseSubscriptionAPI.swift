//
//  SupabaseSubscriptionAPI.swift
//  RG10
//
//  Created by Moneeb Sayed on 1/17/25.
//

import Foundation
import Supabase

// MARK: - Supabase Subscription API (Matching Android Implementation)

@MainActor
final class SupabaseSubscriptionAPI {
    static let shared = SupabaseSubscriptionAPI()
    
    private let client = SupabaseClientManager.shared.client
    
    // Function names (matching Android)
    private enum FunctionName {
        static let createSubscriptionSession = "billing-create-subscription-session"
        static let cancelSubscription = "cancel-subscription"
        static let abortSubscriptionIntent = "abort-subscription-intent"
    }
    
    private init() {}
    
    // MARK: - Subscription Plans
    
    /// Fetches all available subscription plans from Supabase
    func fetchSubscriptions() async throws -> [DBSubscription] {
        print("🔗 Fetching subscription plans from Supabase...")
        
        let response = try await client
            .from("subscriptions")
            .select()
            .execute()
        
        let decoder = JSONDecoder()
        let subscriptions = try decoder.decode([DBSubscription].self, from: response.data)
        
        print("✅ Fetched \(subscriptions.count) subscription plans")
        return subscriptions
    }
    
    // MARK: - User Subscription Status
    
    /// Fetches user's current subscription status
    func fetchUserSubscription(userId: String) async throws -> DBUserSubscription? {
        print("🔗 Fetching user subscription status for userId: \(userId)")
        
        let response = try await client
            .from("user_subscriptions")
            .select()
            .eq("user_id", value: userId)
            .eq("subscribed", value: true)
            .execute()
        
        let decoder = JSONDecoder()
        let subscriptions = try decoder.decode([DBUserSubscription].self, from: response.data)
        
        print("✅ Found \(subscriptions.count) active subscriptions for user")
        return subscriptions.first
    }
    
    // MARK: - Subscription Creation
    
    /// Creates a subscription session for Stripe PaymentSheet
    func createSubscriptionSession(
        userId: String,
        priceId: String
    ) async throws -> CreateSubscriptionIntentResponse {
        print("🔗 Creating subscription session for userId: \(userId), priceId: \(priceId)")
        
        // Use Supabase edge function (correct approach)
        return try await runSupabaseFunction(
            functionName: FunctionName.createSubscriptionSession,
            fallbackMessage: "Unable to create subscription session. Please try again.",
            buildBody: { builder in
                builder["user_id"] = .string(userId)
                builder["price_id"] = .string(priceId)
            },
            requestType: "POST"
        ) { text in
            print("🔗 Create subscription session response: \(text)")
            print("🔗 Response type: \(type(of: text))")
            print("🔗 Response length: \(text.count)")
            
            // Check if response is empty
            if text.isEmpty || text == "()" {
                throw SubscriptionError.subscriptionCreationFailed("Supabase edge function returned empty response. The billing-create-subscription-session function may not exist or may not be properly configured.")
            }
            
            return try JSONDecoder().decode(CreateSubscriptionIntentResponse.self, from: text.data(using: .utf8)!)
        }
    }
    
    
    // MARK: - Subscription Cancellation
    
    /// Cancels an active subscription
    func cancelSubscription(
        userId: String,
        stripeSubscriptionId: String
    ) async throws -> CancelSubscriptionResponse {
        print("🔗 Cancelling subscription for userId: \(userId), stripeSubscriptionId: \(stripeSubscriptionId)")
        
        return try await runSupabaseFunction(
            functionName: FunctionName.cancelSubscription,
            fallbackMessage: "Unable to cancel subscription. Please try again.",
            buildBody: { builder in
                builder["user_id"] = .string(userId)
                builder["stripe_subscription_id"] = .string(stripeSubscriptionId)
            },
            requestType: "POST"
        ) { text in
            print("🔗 Cancel subscription response: \(text)")
            return try JSONDecoder().decode(CancelSubscriptionResponse.self, from: text.data(using: .utf8)!)
        }
    }
    
    // MARK: - Subscription Abort
    
    /// Aborts a pending subscription attempt
    func abortSubscriptionIntent(
        userId: String,
        subscriptionId: String
    ) async throws -> AbortSubscriptionResponse {
        print("🔗 Aborting subscription intent for userId: \(userId), subscriptionId: \(subscriptionId)")
        
        return try await runSupabaseFunction(
            functionName: FunctionName.abortSubscriptionIntent,
            fallbackMessage: "Unable to abort subscription. Please try again.",
            buildBody: { builder in
                builder["user_id"] = .string(userId)
                builder["subscription_id"] = .string(subscriptionId)
            },
            requestType: "POST"
        ) { text in
            print("🔗 Abort subscription response: \(text)")
            return try JSONDecoder().decode(AbortSubscriptionResponse.self, from: text.data(using: .utf8)!)
        }
    }
    
    // MARK: - Private Methods
    
    /// Generic function runner (matching Android implementation)
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
                    throw SubscriptionError.networkError(NSError(domain: "InvalidURL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
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
                    throw SubscriptionError.networkError(NSError(domain: "InvalidResponse", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                    throw SubscriptionError.networkError(NSError(domain: "ServerError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error (\(httpResponse.statusCode)): \(errorMessage)"]))
                }
                
                response = data
            } else {
                // POST request using direct HTTP call to Supabase edge function
                var bodyData: Data?
                
                if let buildBody = buildBody {
                    var jsonBuilder = JSONObjectBuilder()
                    buildBody(&jsonBuilder)
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
                }
                
                print("🔗 Calling Supabase function directly: \(functionName)")
                print("🔗 Request body: \(String(data: bodyData ?? Data(), encoding: .utf8) ?? "nil")")
                
                // Make direct HTTP request to Supabase edge function
                let url = URL(string: "https://uwssjvqlsekveqvdkdnj.supabase.co/functions/v1/\(functionName)")!
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
                    throw SubscriptionError.networkError(NSError(domain: "InvalidResponse", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
                }
                
                print("🔗 HTTP response status: \(httpResponse.statusCode)")
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                    print("❌ HTTP error (\(httpResponse.statusCode)): \(errorMessage)")
                    throw SubscriptionError.networkError(NSError(domain: "ServerError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error (\(httpResponse.statusCode)): \(errorMessage)"]))
                }
                
                let responseString = String(data: data, encoding: .utf8) ?? ""
                print("🔗 HTTP success response: \(responseString)")
                
                response = data
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
            if error is SubscriptionError {
                throw error
            }
            throw SubscriptionError.networkError(error)
        }
    }
}
