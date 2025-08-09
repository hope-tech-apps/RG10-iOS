//
//  ExploreViewModel.swift
//  RG10
//
//  Created by Moneeb Sayed on 8/9/25.
//

import SwiftUI
import Combine

// MARK: - View Model
class ExploreViewModel: ObservableObject {
    @Published var coaches: [Coach] = [
        Coach(
            name: "Rodrigo Gudino",
            role: "Head Coach & CEO",
            imageURL: "https://www.rg10football.com/wp-content/uploads/2025/07/207C2DC5-1B43-48C0-BEA2-C436CCBC45F1.jpeg",
            cardImageURL: nil
        ),
        Coach(
            name: "Aryan Kamdar",
            role: "RG10 Coach (Chicago)",
            imageURL: "https://www.rg10football.com/wp-content/uploads/2025/07/Aryan2-683x1024.jpeg",
            cardImageURL: nil
        )
    ]
    
    @Published var recommendedVideos: [ExploreVideoItem] = [
        ExploreVideoItem(
            title: "Video title in brief",
            thumbnailURL: "",
            duration: "0:5M",
            views: nil
        ),
        ExploreVideoItem(
            title: "Video title in brief",
            thumbnailURL: "",
            duration: "1:5M",
            views: nil
        ),
        ExploreVideoItem(
            title: "Training Session Highlights",
            thumbnailURL: "",
            duration: "2:30M",
            views: nil
        )
    ]
    
    @Published var playerSpotlights: [PlayerSpotlight] = [
        PlayerSpotlight(
            name: "Player's name",
            description: "A brief about. A rising star known for his unmatched speed and precision on the field. His dedication and discipline have made him a role model for aspiring players around the world.",
            imageURL: "https://www.rg10football.com/wp-content/uploads/2025/07/IMG_5462-scaled.jpeg"
        ),
        PlayerSpotlight(
            name: "Another Player",
            description: "Exceptional midfielder with vision and technical skills that set him apart. Leading by example both on and off the pitch.",
            imageURL: ""
        ),
        PlayerSpotlight(
            name: "Featured Player",
            description: "Young talent making waves in the academy. Combines natural ability with relentless work ethic.",
            imageURL: ""
        )
    ]
}
