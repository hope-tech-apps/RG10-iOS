//
//  BookingConfigService.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/17/25.
//

import Foundation
import Supabase
import Combine

class BookingConfigService: ObservableObject {
    static let shared = BookingConfigService()
    
    @Published private(set) var configs: [BookingConfig] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    
    private let client = SupabaseClientManager.shared.client
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    // MARK: - Public Methods
    
    func loadConfigs() async throws -> [BookingConfig] {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            // Use real data structure matching the database
            let mockConfigs = [
                BookingConfig(
                    id: 2,
                    name: "Group Session (3-5)",
                    calName: "rodrigo-group-session",
                    calId: "3446743",
                    calLink: "https://cal.com/hopetechapps/rodrigo-group-session",
                    stripeProductId: "prod_T7JrAK9V4PDHmf",
                    stripePriceId: "price_1SB5G92MsljS8n0FXgcKTdgt",
                    minAttendees: 3
                ),
                BookingConfig(
                    id: 5,
                    name: "Group Session (6-8)",
                    calName: "rodrigo-group-session",
                    calId: "3446743",
                    calLink: "https://cal.com/hopetechapps/rodrigo-group-session",
                    stripeProductId: "prod_T7JrAK9V4PDHmf",
                    stripePriceId: "price_1SB5GG2MsljS8n0F1le18aMx",
                    minAttendees: 6
                ),
                BookingConfig(
                    id: 6,
                    name: "Group Session (9+)",
                    calName: "rodrigo-group-session",
                    calId: "3446743",
                    calLink: "https://cal.com/hopetechapps/rodrigo-group-session",
                    stripeProductId: "prod_T7JrAK9V4PDHmf",
                    stripePriceId: "price_1SB5Gb2MsljS8n0FDFDmmkes",
                    minAttendees: 9
                ),
                BookingConfig(
                    id: 7,
                    name: "Single Session",
                    calName: "rodrigo-single-session",
                    calId: "3389625",
                    calLink: "https://cal.com/hopetechapps/rodrigo-single-session",
                    stripeProductId: "prod_T6wRvML3AnUFGF",
                    stripePriceId: "price_1SAIYX2MsIjS8n0FOgbsMGbb",
                    minAttendees: 1
                )
            ]
            
            await MainActor.run {
                configs = mockConfigs
                isLoading = false
            }
            
            return mockConfigs
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
            }
            throw BookingFlowError.configLoadFailed(error.localizedDescription)
        }
    }
    
    func getConfig(for sessionType: BookingSessionType) -> BookingConfig? {
        switch sessionType {
        case .single:
            return configs.first { $0.calName.contains("single") }
        case .group:
            // For group sessions, we'll let the user choose the specific group size
            return configs.first { $0.calName.contains("group") }
        }
    }
    
    func getGroupConfigs() -> [BookingConfig] {
        return configs.filter { $0.calName.contains("group") }
            .sorted { $0.minAttendees < $1.minAttendees }
    }
    
    func getSingleConfig() -> BookingConfig? {
        return configs.first { $0.calName.contains("single") }
    }
    
    func createFlowConfig(from bookingConfig: BookingConfig, coach: Coach) -> BookingFlowConfig {
        // Build the Cal.com URL with coach-specific parameters
        let calUrl = buildCalUrl(from: bookingConfig, coach: coach)
        
        return BookingFlowConfig(
            sessionType: bookingConfig.calName.contains("group") ? .group : .single,
            calBookingUrl: calUrl,
            calAllowedHosts: ["cal.com", "www.cal.com"],
            bookingRedirectHosts: ["rg10football.com"],
            bookingUidQueryKey: "uid",
            stripePriceId: bookingConfig.stripePriceId,
            merchantDisplayName: "RG10 Football"
        )
    }
    
    func getValidCalUrl(for config: BookingConfig) -> String {
        // Try the stored URL first
        if !config.calLink.isEmpty && config.calLink.hasPrefix("https://") {
            print("🔗 Using stored URL: \(config.calLink)")
            return config.calLink
        }
        
        // Fallback: construct URL from cal_name
        let baseUrl = "https://cal.com/hopetechapps/"
        let constructedUrl = baseUrl + config.calName
        print("🔗 Using constructed URL: \(constructedUrl)")
        return constructedUrl
    }
    
    // MARK: - Private Methods
    
    private func buildCalUrl(from config: BookingConfig, coach: Coach) -> String {
        // Extract the base Cal.com URL and add coach-specific parameters
        var urlComponents = URLComponents(string: config.calLink)
        
        // Add coach-specific query parameters if needed
        var queryItems = urlComponents?.queryItems ?? []
        
        // Add any coach-specific parameters here
        // For example, if the coach has a specific Cal.com username
        if let coachUsername = extractCoachUsername(from: coach.scheduleLink) {
            queryItems.append(URLQueryItem(name: "username", value: coachUsername))
        }
        
        urlComponents?.queryItems = queryItems
        return urlComponents?.string ?? config.calLink
    }
    
    private func extractCoachUsername(from scheduleLink: String?) -> String? {
        guard let link = scheduleLink,
              let url = URL(string: link) else { return nil }
        
        // Extract username from Cal.com URL
        // Example: https://cal.com/coach-username -> "coach-username"
        let pathComponents = url.pathComponents.filter { !$0.isEmpty && $0 != "/" }
        return pathComponents.first
    }
}
