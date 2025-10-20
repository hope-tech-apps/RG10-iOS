//
//  BookingFlowModels.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/17/25.
//

import Foundation

// MARK: - Booking Flow Configuration Models

struct BookingFlowConfig: Codable, Sendable, Equatable {
    let sessionType: BookingSessionType
    let calBookingUrl: String
    let calAllowedHosts: [String]
    let bookingRedirectHosts: [String]
    let bookingUidQueryKey: String
    let stripePriceId: String
    let merchantDisplayName: String
    
    static let defaultConfig = BookingFlowConfig(
        sessionType: .single,
        calBookingUrl: "",
        calAllowedHosts: ["cal.com", "www.cal.com"],
        bookingRedirectHosts: ["rg10football.com"],
        bookingUidQueryKey: "uid",
        stripePriceId: "",
        merchantDisplayName: "RG10 Football"
    )
}

struct BookingConfig: Codable, Sendable {
    let id: Int
    let name: String
    let calName: String
    let calId: String
    let calLink: String
    let stripeProductId: String
    let stripePriceId: String
    let minAttendees: Int
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case calName = "cal_name"
        case calId = "cal_id"
        case calLink = "cal_link"
        case stripeProductId = "stripe_product_id"
        case stripePriceId = "stripe_price_id"
        case minAttendees = "min_attendees"
    }
}

// MARK: - Booking Flow State

enum BookingFlowState: Sendable, Equatable {
    case idle
    case loadingConfigs
    case webViewPresented(BookingFlowConfig)
    case webViewDismissing(BookingFlowConfig, String) // config, bookingUid
    case processingPayment(BookingFlowConfig, String) // config, bookingUid
    case paymentSheetReady(BookingFlowConfig, String, PaymentSheetData) // config, bookingUid, paymentData
    case completed(BookingFlowConfig, String) // config, bookingUid
    case cancelled(BookingFlowConfig, String?) // config, bookingUid (optional)
    case error(BookingFlowConfig?, String) // config (optional), error message
}

// MARK: - Booking Flow Events

enum BookingFlowEvent: Sendable {
    case startBooking(sessionType: BookingSessionType, coach: Coach)
    case webViewDismissed
    case successUrlDetected([String: String]) // query parameters
    case paymentCompleted
    case paymentCancelled
    case paymentFailed(String) // error message
    case retry
    case reset
}

// MARK: - Booking Flow Result

struct BookingFlowResult: Sendable {
    let success: Bool
    let bookingUid: String?
    let error: String?
    let config: BookingFlowConfig?
    
    static func success(bookingUid: String, config: BookingFlowConfig) -> BookingFlowResult {
        BookingFlowResult(success: true, bookingUid: bookingUid, error: nil, config: config)
    }
    
    static func failure(error: String, config: BookingFlowConfig?) -> BookingFlowResult {
        BookingFlowResult(success: false, bookingUid: nil, error: error, config: config)
    }
}

// MARK: - WebView Configuration

struct WebViewConfig: Sendable {
    let url: String
    let allowedHosts: [String]
    let successUrlPattern: String
    let bookingUidQueryKey: String
    
    init(from config: BookingFlowConfig) {
        self.url = config.calBookingUrl
        self.allowedHosts = config.calAllowedHosts
        self.successUrlPattern = "https://\(config.bookingRedirectHosts.first ?? "rg10football.com")/booking-complete"
        self.bookingUidQueryKey = config.bookingUidQueryKey
    }
}

// MARK: - Booking Flow Error

enum BookingFlowError: LocalizedError, Sendable {
    case configLoadFailed(String)
    case invalidBookingUrl
    case webViewError(String)
    case paymentIntentFailed(String)
    case paymentFailed(String)
    case bookingCancellationFailed(String)
    case invalidBookingUid
    case networkError(String)
    
    var errorDescription: String? {
        switch self {
        case .configLoadFailed(let message):
            return "Failed to load booking configuration: \(message)"
        case .invalidBookingUrl:
            return "Invalid booking URL"
        case .webViewError(let message):
            return "WebView error: \(message)"
        case .paymentIntentFailed(let message):
            return "Payment setup failed: \(message)"
        case .paymentFailed(let message):
            return "Payment failed: \(message)"
        case .bookingCancellationFailed(let message):
            return "Failed to cancel booking: \(message)"
        case .invalidBookingUid:
            return "Invalid booking identifier"
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
}
