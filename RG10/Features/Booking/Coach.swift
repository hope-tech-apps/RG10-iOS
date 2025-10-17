//
//  Coach.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/17/25.
//


import Foundation
import Combine

// MARK: - Coach Model

// MARK: - Coach Availability

struct CoachAvailability: Codable, Equatable {
    let monday: [TimeSlot]?
    let tuesday: [TimeSlot]?
    let wednesday: [TimeSlot]?
    let thursday: [TimeSlot]?
    let friday: [TimeSlot]?
    let saturday: [TimeSlot]?
    let sunday: [TimeSlot]?
}

struct TimeSlot: Codable, Equatable {
    let start: String // e.g., "09:00"
    let end: String   // e.g., "17:00"
}

// MARK: - Coach View Model

class CoachViewModel: ObservableObject {
    static let shared = CoachViewModel()
    @Published var coaches: [Coach] = []
    @Published var featuredCoach: Coach?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedCoach: Coach?
    @Published var searchText = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadCoaches()
        setupSearch()
    }
    
    // MARK: - Computed Properties
    
    var filteredCoaches: [Coach] {
        if searchText.isEmpty {
            return coaches
        } else {
            return coaches.filter { coach in
                coach.name.localizedCaseInsensitiveContains(searchText) ||
                coach.role.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var availableCoaches: [Coach] {
        return coaches.filter { coach in
            // Filter for coaches with schedule links
            ((coach.scheduleLink?.isEmpty) == nil)
        }
    }
        
    // MARK: - Data Loading
    
    func loadCoaches() {
        // For now, using static data. In production, this would fetch from Supabase
        self.coaches = Self.defaultCoaches
        self.featuredCoach = coaches.first
    }
    
    func fetchCoachesFromSupabase() async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            // This would be replaced with actual Supabase query
            // let coaches = try await SupabaseManager.shared.supabase
            //     .from("coaches")
            //     .select()
            //     .execute()
            //     .value
            
            // For now, simulate async loading
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
            
            await MainActor.run {
                self.coaches = Self.defaultCoaches
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }
    
    // MARK: - Coach Selection
    
    func selectCoach(_ coach: Coach) {
        selectedCoach = coach
        
        // Store preferred coach
//        UserDefaults.standard.set(coach.name, forKey: UserDefaults.Keys.preferredCoachId)
    }
    
    func getCoachByName(_ name: String) -> Coach? {
        return coaches.first { $0.name == name }
    }
    
    // MARK: - Search Setup
    
    private func setupSearch() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Coach Actions
    
    func bookSessionWithCoach(_ coach: Coach) -> URL? {
        return URL(string: coach.scheduleLink ?? "")
    }
    
    func getCoachImage(for coach: Coach) -> URL? {
        if let cardImage = coach.cardImageURL, !cardImage.isEmpty {
            return URL(string: cardImage)
        }
        return URL(string: coach.imageURL)
    }
    
    // MARK: - Default Data
    
    static let defaultCoaches: [Coach] = [
        Coach(
            name: "Rodrigo Gudino",
            role: "Head Coach & CEO",
            imageURL: "https://www.rg10football.com/wp-content/uploads/2025/07/207C2DC5-1B43-48C0-BEA2-C436CCBC45F1.jpeg",
            cardImageURL: nil,
            scheduleLink: "https://www.cal.com/hopetechapps/rodrigo-trainings"
        ),
        Coach(
            name: "Aryan Kamdar",
            role: "RG10 Coach (Chicago)",
            imageURL: "https://www.rg10football.com/wp-content/uploads/2025/07/Aryan2-683x1024.jpeg",
            cardImageURL: nil,
            scheduleLink: "https://www.cal.com/hopetechapps/ayran-trainings"
        )
    ]
}

// MARK: - Coach Extensions

extension Coach {
    /// Extract calendar event type from Cal.com URL
    var calendarEventType: String {
        if let url = URL(string: scheduleLink ?? "") {
            let components = url.pathComponents.filter { !$0.isEmpty && $0 != "/" }
            return components.last ?? ""
        }
        return ""
    }
}

//// MARK: - Mock Data Extension for Testing
//
//extension CoachViewModel {
//    /// Load mock data for testing
//    func loadMockData() {
//        coaches = Self.mockCoaches
//        featuredCoach = coaches.first
//    }
//    
//    static let mockCoaches: [Coach] = [
//        Coach(
//            name: "Test Coach 1",
//            role: "Senior Coach",
//            imageURL: "https://via.placeholder.com/150",
//            cardImageURL: nil,
//            scheduleLink: "https://cal.com/test/coach1",
//            bio: "Test bio for coach 1",
//            specialties: ["Test Skill 1", "Test Skill 2"],
//            location: "Test Location 1",
//            yearsExperience: 10,
//            certifications: ["Test Cert 1"],
//            availability: nil
//        ),
//        Coach(
//            name: "Test Coach 2",
//            role: "Junior Coach",
//            imageURL: "https://via.placeholder.com/150",
//            cardImageURL: nil,
//            scheduleLink: "https://cal.com/test/coach2",
//            bio: "Test bio for coach 2",
//            specialties: ["Test Skill 3"],
//            location: "Test Location 2",
//            yearsExperience: 5,
//            certifications: ["Test Cert 2"],
//            availability: nil
//        )
//    ]
//}
