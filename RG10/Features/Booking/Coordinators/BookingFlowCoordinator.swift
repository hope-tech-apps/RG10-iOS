//
//  BookingFlowCoordinator.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/17/25.
//

import Foundation
import Combine
import StripePaymentSheet
import SwiftUI
import Supabase

@MainActor
class BookingFlowCoordinator: ObservableObject {
    static let shared = BookingFlowCoordinator()
    
    @Published private(set) var state: BookingFlowState = .idle
    @Published private(set) var result: BookingFlowResult?
    
    private let configService = BookingConfigService.shared
    private let paymentAPI = SupabasePaymentAPI.shared
    private let paymentSheetService = PaymentSheetService.shared
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    // MARK: - Public Methods
    
    func handleEvent(_ event: BookingFlowEvent) {
        switch event {
        case .startBooking(let sessionType, let coach):
            startBooking(sessionType: sessionType, coach: coach)
            
        case .webViewDismissed:
            handleWebViewDismissed()
            
        case .successUrlDetected(let queryParams):
            handleSuccessUrlDetected(queryParams: queryParams)
            
        case .paymentCompleted:
            handlePaymentCompleted()
            
        case .paymentCancelled:
            handlePaymentCancelled()
            
        case .paymentFailed(let error):
            handlePaymentFailed(error: error)
            
        case .retry:
            retryCurrentFlow()
            
        case .reset:
            resetFlow()
        }
    }
    
    // MARK: - Private Methods
    
    private func startBooking(sessionType: BookingSessionType, coach: Coach) {
        Task {
            do {
                state = .loadingConfigs
                
                // Load booking configurations
                let configs = try await configService.loadConfigs()
                
                // Find the appropriate config for the session type
                let bookingConfig: BookingConfig?
                switch sessionType {
                case .single:
                    bookingConfig = configService.getSingleConfig()
                case .group:
                    // For group sessions, we'll use the first group config
                    // In a real implementation, you'd pass the selected group config
                    bookingConfig = configService.getGroupConfigs().first
                }
                
                guard let config = bookingConfig else {
                    state = .error(nil, "No booking configuration found for \(sessionType.rawValue) session")
                    return
                }
                
                // Create flow config using the actual cal_link from the database
                let validUrl = configService.getValidCalUrl(for: config)
                let flowConfig = BookingFlowConfig(
                    sessionType: sessionType,
                    calBookingUrl: validUrl, // Use validated URL
                    calAllowedHosts: ["cal.com", "www.cal.com"],
                    bookingRedirectHosts: ["rg10football.com"],
                    bookingUidQueryKey: "uid",
                    stripePriceId: config.stripePriceId,
                    merchantDisplayName: "RG10 Football"
                )
                
                // Present WebView
                state = .webViewPresented(flowConfig)
                
            } catch {
                state = .error(nil, error.localizedDescription)
            }
        }
    }
    
    private func handleWebViewDismissed() {
        switch state {
        case .webViewPresented(let config):
            state = .cancelled(config, nil)
            result = .failure(error: "Booking cancelled by user", config: config)
            
        default:
            // If WebView is dismissed in other states, reset the flow
            resetFlow()
        }
    }
    
    private func handleSuccessUrlDetected(queryParams: [String: String]) {
        guard case .webViewPresented(let config) = state else {
            state = .error(nil, "Invalid state for success URL detection")
            return
        }
        
        // Extract bookingUid from query params
        guard let bookingUid = queryParams["uid"] else {
            state = .error(config, "Missing booking UID in success URL")
            return
        }
        
        print("🔗 Success URL detected with query params: \(queryParams)")
        
        // First dismiss the WebView, then process payment after a delay
        // This prevents the presentation hierarchy conflict
        state = .webViewDismissing(config, bookingUid)
        
        // Add a longer delay to ensure WebView is fully dismissed before presenting PaymentSheet
        // This prevents the presentation hierarchy conflict
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.processPaymentIntent(config: config, queryParams: queryParams)
        }
    }
    
    private func processPaymentIntent(config: BookingFlowConfig, queryParams: [String: String]) {
        guard let bookingUid = queryParams["uid"] else {
            state = .error(config, "Missing booking UID in query parameters")
            return
        }
        
        state = .processingPayment(config, bookingUid)
        
        Task {
            do {
                // Get the Supabase user ID for webhook processing
                let supabaseUserId = getSupabaseUserId()
                guard !supabaseUserId.isEmpty else {
                    await MainActor.run {
                        self.state = .error(config, "User not authenticated")
                    }
                    return
                }
                
                print("🔗 Creating payment intent directly with Supabase user ID:")
                print("🔗 bookingUid: \(bookingUid)")
                print("🔗 user_id: \(supabaseUserId)")
                
                // Create payment intent directly from query parameters with Supabase user ID
                let paymentSheetData = try await createPaymentIntentFromQueryParams(
                    queryParams: queryParams,
                    supabaseUserId: supabaseUserId,
                    config: config
                )
                
                await MainActor.run {
                    self.state = .paymentSheetReady(config, bookingUid, paymentSheetData)
                }
                
            } catch {
                await MainActor.run {
                    // Handle special case where booking is free for subscription users
                    if case BookingError.bookingIsFree = error {
                        print("✅ Booking completed successfully - user has remaining sessions!")
                        
                        // Refresh subscription status to update session count
                        Task {
                            await self.refreshSubscriptionStatusAfterBooking(bookingUid: bookingUid)
                        }
                        
                        self.state = .completed(config, bookingUid)
                        self.result = .success(bookingUid: bookingUid, config: config)
                    } else {
                        self.state = .error(config, "Failed to create payment intent: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    private func createPaymentIntentFromQueryParams(
        queryParams: [String: String],
        supabaseUserId: String,
        config: BookingFlowConfig
    ) async throws -> PaymentSheetData {
        print("🔗 Creating payment intent from query params: \(queryParams)")
        
        // Extract booking information from query parameters
        let bookingUid = queryParams["uid"] ?? ""
        
        guard !bookingUid.isEmpty else {
            throw BookingError.invalidBookingUid
        }
        
        print("🔗 Calling Supabase edge function: payments-create-booking-intent")
        print("🔗 bookingUid: \(bookingUid)")
        print("🔗 userId: \(supabaseUserId)")
        
        // Use Supabase edge function to create booking intent (checks subscription status)
        let bookingIntent = try await paymentAPI.createBookingIntent(
            userId: supabaseUserId,
            bookingUid: bookingUid
        )
        
        print("🔗 Booking intent response: free=\(bookingIntent.free)")
        
        // Check if booking is free (user has remaining sessions)
        if bookingIntent.free {
            print("✅ Booking is FREE - user has remaining sessions!")
            // Skip payment and complete booking directly
            throw BookingError.bookingIsFree
        }
        
        // User needs to pay - create PaymentSheet data
        guard let clientSecret = bookingIntent.paymentIntentClientSecret else {
            throw BookingError.missingPaymentIntent
        }
        
        let paymentSheetData = PaymentSheetData(
            publishableKey: PaymentConfiguration.stripePublishableKey,
            paymentIntentClientSecret: clientSecret,
            customerId: bookingIntent.customerId,
            customerEphemeralKeySecret: bookingIntent.ephemeralKeySecret,
            merchantDisplayName: config.merchantDisplayName,
            allowsDelayedPaymentMethods: true
        )
        
        print("🔗 Created payment data for paid booking: \(paymentSheetData)")
        return paymentSheetData
    }
    
    private func createStripePaymentIntent(
        bookingUid: String,
        email: String,
        eventType: String,
        supabaseUserId: String
    ) async throws -> StripePaymentIntent {
        print("🔗 Creating real Stripe PaymentIntent for booking: \(bookingUid)")
        print("🔗 Including Supabase user ID: \(supabaseUserId)")
        
         // Create PaymentIntent using Stripe's API with Supabase user ID in metadata
         let requestBody: [String: Any] = [
             "amount": 5000, // $50.00 in cents
             "currency": "usd",
             "metadata[bookingUid]": bookingUid,  // ← Changed to match webhook expectation
             "metadata[email]": email,
             "metadata[event_type]": eventType,
             "metadata[supabase_user_id]": supabaseUserId
         ]
        
        guard let url = URL(string: "https://api.stripe.com/v1/payment_intents") else {
            throw PaymentError.invalidConfiguration
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(PaymentConfiguration.stripeSecretKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // Convert request body to form data
        let formData = requestBody.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        request.httpBody = formData.data(using: .utf8)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            print("❌ Stripe API error: \(String(data: data, encoding: .utf8) ?? "Unknown error")")
            throw PaymentError.networkError(NSError(domain: "StripeAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create PaymentIntent"]))
        }
        
        let paymentIntent = try JSONDecoder().decode(StripePaymentIntent.self, from: data)
        print("✅ Created real PaymentIntent: \(paymentIntent.id)")
        return paymentIntent
    }
    
    // MARK: - Database Operations
    
    private func saveBookingToDatabase(bookingUid: String, config: BookingFlowConfig) async throws {
        print("💾 Processing successful payment for booking: \(bookingUid)")
        
        // The booking was created in Cal.com and payment was successful
        // Now we need to ensure it appears in our bookings list
        
        // Option 1: Refresh bookings from Supabase (if get-bookings fetches from Cal.com)
        print("💾 Refreshing bookings list...")
        
        // Add detailed logging to see what get-bookings returns
        do {
            let response = try await EnhancedBookingService.shared.fetchBookings(forceRefresh: true)
            print("💾 get-bookings response: \(response)")
            print("💾 Total bookings returned: \(response.data.current.count + response.data.upcoming.count + response.data.past.count + response.data.cancelled.count + response.data.unconfirmed.count)")
            print("💾 Current bookings: \(response.data.current.count)")
            print("💾 Upcoming bookings: \(response.data.upcoming.count)")
            print("💾 Past bookings: \(response.data.past.count)")
            print("💾 Cancelled bookings: \(response.data.cancelled.count)")
            print("💾 Unconfirmed bookings: \(response.data.unconfirmed.count)")
        } catch {
            print("❌ Failed to fetch bookings: \(error)")
        }
        
        // Option 2: If the above doesn't work, we might need to manually sync
        // the Cal.com booking to our Supabase database
        print("💾 Checking if booking appears in list...")
        
        let currentBookings = EnhancedBookingService.shared.bookings
        let foundBooking = currentBookings.first { $0.uid == bookingUid }
        
        if foundBooking != nil {
            print("✅ Booking found in list: \(bookingUid)")
        } else {
            print("⚠️ Booking not found in list. This suggests the get-bookings edge function")
            print("⚠️ doesn't fetch from Cal.com or there's a sync issue.")
            print("⚠️ You may need to update your Supabase edge function to sync Cal.com bookings.")
        }
        
            // Notify any listening views that bookings have been updated
            await MainActor.run {
                NotificationCenter.default.post(
                    name: NSNotification.Name("BookingsUpdated"),
                    object: nil,
                    userInfo: ["bookingUid": bookingUid]
                )
            }
    }
    
    private func handlePaymentCompleted() {
        guard case .paymentSheetReady(let config, let bookingUid, _) = state else {
            state = .error(nil, "Invalid state for payment completion")
            return
        }
        
        // Save the booking to Supabase database after successful payment
        Task {
            do {
                try await saveBookingToDatabase(bookingUid: bookingUid, config: config)
                
                // Refresh subscription status to update session count
                await self.refreshSubscriptionStatusAfterBooking(bookingUid: bookingUid)
                
                await MainActor.run {
                    self.state = .completed(config, bookingUid)
                    self.result = .success(bookingUid: bookingUid, config: config)
                }
            } catch {
                await MainActor.run {
                    self.state = .error(config, "Failed to save booking: \(error.localizedDescription)")
                    self.result = .failure(error: error.localizedDescription, config: config)
                }
            }
        }
    }
    
    private func handlePaymentCancelled() {
        guard case .paymentSheetReady(let config, let bookingUid, _) = state else {
            state = .error(nil, "Invalid state for payment cancellation")
            return
        }
        
        // Cancel the booking on the backend
        Task {
            do {
                try await paymentAPI.abortSubscriptionIntent(subscriptionId: bookingUid)
            } catch {
                print("Failed to cancel booking on backend: \(error)")
            }
        }
        
        state = .cancelled(config, bookingUid)
        result = .failure(error: "Payment cancelled by user", config: config)
    }
    
    private func handlePaymentFailed(error: String) {
        guard case .paymentSheetReady(let config, let bookingUid, _) = state else {
            state = .error(nil, "Invalid state for payment failure")
            return
        }
        
        // Cancel the booking on the backend
        Task {
            do {
                try await paymentAPI.abortSubscriptionIntent(subscriptionId: bookingUid)
            } catch {
                print("Failed to cancel booking on backend: \(error)")
            }
        }
        
        state = .error(config, "Payment failed: \(error)")
        result = .failure(error: error, config: config)
    }
    
    private func retryCurrentFlow() {
        switch state {
        case .error(let config, _):
            if let config = config {
                // Retry with the same config
                state = .webViewPresented(config)
            } else {
                // Reset and allow user to start over
                resetFlow()
            }
            
        default:
            resetFlow()
        }
    }
    
    private func resetFlow() {
        state = .idle
        result = nil
    }
    
    private func getSupabaseUserId() -> String {
        // Get the actual Supabase user ID (UUID string) from AuthManager
        guard let session = AuthManager.shared.session else { return "" }
        return session.user.id.uuidString
    }
    
    private func getCurrentUserId() -> String {
        // Get current user ID from auth manager
        return SupabaseClientManager.shared.currentUserEmail ?? ""
    }
    
    // MARK: - Subscription Status Refresh
    
    /// Refreshes subscription status after a successful booking to update session count
    private func refreshSubscriptionStatusAfterBooking(bookingUid: String) async {
        print("🔄 Refreshing subscription status after booking: \(bookingUid)")
        
        do {
            // Refresh subscription status to get updated session count
            let subscriptionService = SubscriptionService.shared
            try await subscriptionService.fetchUserSubscription(forceRefresh: true)
            
            print("✅ Subscription status refreshed - session count updated")
            
            // Also refresh the unified training view if it exists
            await MainActor.run {
                // Notify any listening views that subscription status has changed
                NotificationCenter.default.post(
                    name: NSNotification.Name("SubscriptionStatusUpdated"),
                    object: nil,
                    userInfo: ["bookingUid": bookingUid]
                )
            }
            
        } catch {
            print("❌ Failed to refresh subscription status: \(error)")
        }
    }
}
    
    // MARK: - Convenience Extensions

extension BookingFlowCoordinator {
    var isIdle: Bool {
        if case .idle = state { return true }
        return false
    }
    
    var isLoading: Bool {
        if case .loadingConfigs = state { return true }
        if case .processingPayment = state { return true }
        return false
    }
    
    var shouldShowWebView: Bool {
        if case .webViewPresented = state { return true }
        return false
    }
    
    var isWebViewDismissing: Bool {
        if case .webViewDismissing = state { return true }
        return false
    }
    
    var shouldShowPaymentSheet: Bool {
        if case .paymentSheetReady = state { return true }
        return false
    }
    
    var currentConfig: BookingFlowConfig? {
        switch state {
        case .webViewPresented(let config),
             .webViewDismissing(let config, _),
             .processingPayment(let config, _),
             .paymentSheetReady(let config, _, _),
             .completed(let config, _),
             .cancelled(let config, _):
            return config
        case .error(let config, _):
            return config
        default:
            return nil
        }
    }
    
    var currentBookingUid: String? {
        switch state {
        case .webViewDismissing(_, let bookingUid),
             .processingPayment(_, let bookingUid),
             .paymentSheetReady(_, let bookingUid, _),
             .completed(_, let bookingUid):
            return bookingUid
        case .cancelled(_, let bookingUid):
            return bookingUid
        default:
            return nil
        }
    }
    
    var currentPaymentData: PaymentSheetData? {
        if case .paymentSheetReady(_, _, let paymentData) = state {
            return paymentData
        }
        return nil
    }
    
    var currentPaymentSheet: PaymentSheet? {
        if case .paymentSheetReady(_, _, let paymentData) = state {
            // Create PaymentSheet synchronously from the data
            do {
                return try PaymentSheetService.shared.createSubscriptionPaymentSheetSync(with: paymentData)
            } catch {
                print("Failed to create PaymentSheet: \(error)")
                return nil
            }
        }
        return nil
    }
}
