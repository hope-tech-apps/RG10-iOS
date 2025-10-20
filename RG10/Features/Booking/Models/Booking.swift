//
//  Booking.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/17/25.
//

import Foundation
import Supabase

// MARK: - Enhanced Booking Models (Matching Kotlin Implementation)

struct Booking: Identifiable, Codable, Sendable {
    let id: Int
    let uid: String
    let title: String
    let description: String?
    let hosts: [BookingHost]?
    let status: BookingStatus
    let cancellationReason: String?
    let cancelledByEmail: String?
    let rescheduledByEmail: String?
    let start: Date
    let end: Date
    let duration: Int?
    let eventTypeId: Int?
    let eventType: BookingEventType?
    let meetingUrl: String?
    let location: String?
    let absentHost: Bool?
    let createdAt: Date?
    let updatedAt: Date?
    let metadata: [String: AnyJSON]?
    let rating: Int?
    let icsUid: String?
    let attendees: [BookingAttendee]?
    let guests: [BookingGuest]?
    let bookingFieldsResponses: BookingFieldsResponse?
    let durationMinutes: Int?
    let isCurrent: Bool?
    let isUpcoming: Bool?
    let isPast: Bool?
    let canCancel: Bool?
    let canReschedule: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, uid, title, description, hosts, status
        case cancellationReason = "cancellationReason"
        case cancelledByEmail = "cancelledByEmail"
        case rescheduledByEmail = "rescheduledByEmail"
        case start, end, duration
        case eventTypeId = "eventTypeId"
        case eventType = "eventType"
        case meetingUrl = "meetingUrl"
        case location, absentHost
        case createdAt = "createdAt"
        case updatedAt = "updatedAt"
        case metadata, rating
        case icsUid = "icsUid"
        case attendees, guests
        case bookingFieldsResponses = "bookingFieldsResponses"
        case durationMinutes = "durationMinutes"
        case isCurrent = "isCurrent"
        case isUpcoming = "isUpcoming"
        case isPast = "isPast"
        case canCancel = "canCancel"
        case canReschedule = "canReschedule"
    }
}

// MARK: - Supporting Models

struct BookingHost: Codable, Sendable {
    let id: Int
    let name: String
    let email: String
    let username: String
    let timeZone: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, email, username
        case timeZone = "timeZone"
    }
}

struct BookingEventType: Codable, Sendable {
    let id: Int
    let slug: String
}

struct BookingAttendee: Codable, Sendable {
    let name: String
    let email: String
    let timeZone: String
    let language: String
    let absent: Bool
}

struct BookingGuest: Codable, Sendable {
    let id: Int
    let name: String
    let email: String
    let username: String
    let timezone: String
}

struct BookingLocation: Codable, Sendable {
    let value: String
    let optionValue: String
}

struct BookingFieldsResponse: Codable, Sendable {
    let email: String
    let name: String
    let guests: [BookingGuest]
    let notes: String?
    let location: BookingLocation
    let attendees: String?
}

// MARK: - Booking Types (Matching Kotlin DBBookingTypes)

struct BookingType: Codable, Identifiable, Sendable {
    let id: Int
    let name: String
    let description: String?
    let duration: Int
    let price: Double?
    let currency: String?
    let isActive: Bool
    let stripePriceId: String?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, duration, price, currency
        case isActive = "is_active"
        case stripePriceId = "stripe_price_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum BookingStatus: String, Codable, CaseIterable, Sendable {
    case confirmed = "confirmed"
    case cancelled = "cancelled"
    case pending = "pending"
    case rejected = "rejected"
    case accepted = "accepted"  // ← Added missing case
    case upcoming = "upcoming"
    case past = "past"
    case current = "current"
    case unconfirmed = "unconfirmed"
}

// MARK: - Enhanced Response Models (Matching Kotlin)

struct GetBookingsResponse: Codable, Sendable {
    let status: String
    let data: GetBookingsResponseData
    let message: String
    let meta: GetBookingsResponseMeta
}

struct GetBookingsResponseData: Codable, Sendable {
    let current: [Booking]
    let upcoming: [Booking]
    let past: [Booking]
    let cancelled: [Booking]
    let unconfirmed: [Booking]
}

struct GetBookingsResponseMeta: Codable, Sendable {
    let totalCount: Int
    let counts: GetBookingsResponseMetaCounts
    let page: Int
    let take: Int
    let hasNextPage: Bool
}

struct GetBookingsResponseMetaCounts: Codable, Sendable {
    let current: Int
    let upcoming: Int
    let past: Int
    let cancelled: Int
    let unconfirmed: Int
}

// MARK: - Edge Function Response Models

struct EdgeFunctionResponse<T: Codable>: Codable {
    let status: String
    let data: T?
    let message: String?
    let error: String?
    let meta: MetaData?
}

struct MetaData: Codable {
    let totalCount: Int
    let page: Int
    let take: Int
    let hasNextPage: Bool
}

// MARK: - Request Models

struct FetchBookingsRequest: Codable, Sendable {
    let email: String
    let take: Int
    let page: Int
    let status: BookingStatus?
    
    init(email: String, take: Int = 25, page: Int = 1, status: BookingStatus? = nil) {
        self.email = email
        self.take = take
        self.page = page
        self.status = status
    }
}

struct CancelBookingRequest: Codable, Sendable {
    let bookingUid: String
    let cancellationReason: String?
    let cancelSubsequentBookings: Bool?
    let paymentIntentId: String?
    
    init(bookingUid: String, cancellationReason: String? = nil, cancelSubsequentBookings: Bool = false, paymentIntentId: String? = nil) {
        self.bookingUid = bookingUid
        self.cancellationReason = cancellationReason
        self.cancelSubsequentBookings = cancelSubsequentBookings
        self.paymentIntentId = paymentIntentId
    }
}

struct RescheduleBookingRequest: Codable, Sendable {
    let bookingUid: String
    let start: String  // ISO 8601 format
    let reschedulingReason: String?
    
    init(bookingUid: String, start: Date, reschedulingReason: String? = nil) {
        self.bookingUid = bookingUid
        let formatter = ISO8601DateFormatter()
        self.start = formatter.string(from: start)
        self.reschedulingReason = reschedulingReason
    }
}

// MARK: - Booking Session Type (Matching Kotlin)

enum BookingSessionType: String, Codable, Sendable {
    case single = "SINGLE"
    case group = "GROUP"
    
    static func from(value: String?) -> BookingSessionType {
        if let value = value, value.lowercased().contains("group") {
            return .group
        } else {
            return .single
        }
    }
}

// MARK: - Coach Model Extension

extension Coach {
    var calendarPath: String {
        // Extract the path from the full Cal.com URL
        if let url = URL(string: scheduleLink ?? "") {
            return url.path
        }
        return ""
    }
    
    var calendarUsername: String {
        // Extract username from Cal.com URL (e.g., "hopetechapps" from the URL)
        if let url = URL(string: scheduleLink ?? "") {
            let pathComponents = url.pathComponents.filter { !$0.isEmpty && $0 != "/" }
            return pathComponents.first ?? ""
        }
        return ""
    }
}
