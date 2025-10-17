//
//  Booking.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/17/25.
//


import Foundation

// MARK: - Booking Models

struct Booking: Identifiable, Codable {
    let id: String
    let uid: String
    let title: String
    let start: Date
    let end: Date
    let status: BookingStatus
    let attendeeEmail: String
    let attendeeName: String?
    let eventTypeId: Int?
    let meetingUrl: String?
    let location: String?
    let description: String?
    let canCancel: Bool
    let canReschedule: Bool
    let durationMinutes: Int
    let isUpcoming: Bool
    let isPast: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, uid, title, start, end, status
        case attendeeEmail = "attendee_email"
        case attendeeName = "attendee_name"
        case eventTypeId = "event_type_id"
        case meetingUrl = "meeting_url"
        case location, description
        case canCancel = "canCancel"
        case canReschedule = "canReschedule"
        case durationMinutes = "durationMinutes"
        case isUpcoming = "isUpcoming"
        case isPast = "isPast"
    }
}

enum BookingStatus: String, Codable {
    case confirmed = "confirmed"
    case cancelled = "cancelled"
    case pending = "pending"
    case rejected = "rejected"
    case upcoming = "upcoming"
    case past = "past"
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

struct FetchBookingsRequest {
    let email: String
    let take: Int = 25
    let page: Int = 1
    let status: BookingStatus?
}

struct CancelBookingRequest: Codable {
    let bookingUid: String
    let cancellationReason: String?
}

struct RescheduleBookingRequest: Codable {
    let bookingUid: String
    let start: String  // ISO 8601 format
    let reschedulingReason: String?
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
