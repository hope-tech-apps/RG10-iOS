//
//  HomeViewModel.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/4/25.
//

import Foundation
import SwiftUI
import Combine

class HomeViewModel: HomeViewModelProtocol {
    @Published var carouselItems: [CarouselItem] = []
    @Published var videos: [YouTubeVideo] = [
        YouTubeVideo(
            title: "RG10 Football - Our Journey",
            url: "https://youtu.be/TlQ8bLELCu8"
        ),
        YouTubeVideo(
            title: "Training Excellence",
            url: "https://youtu.be/j4kj-Yrl_uU"
        ),
        YouTubeVideo(
            title: "Building Champions",
            url: "https://youtu.be/WBqLygBUPKY"
        )
    ]
    
    @Published var currentCarouselIndex: Int = 0
    @Published var selectedTab: TabItem = .home
    
    private let allCarouselItems: [CarouselItem] = [
        CarouselItem(
            imageName: AppConstants.Images.soccerBackground,
            title: "RG10 FOOTBALL",
            subtitle: "Unleash Your Full Potential on the Field, and off the Field",
            buttonTitle: "Book Now",
            buttonAction: .bookNow,
            requiresAuth: false
        ),
        CarouselItem(
            imageName: AppConstants.Images.trainingFooter,
            title: "Training Excellence",
            subtitle: "Professional coaching to elevate your game",
            buttonTitle: "Learn More",
            buttonAction: .learnMore,
            requiresAuth: false
        ),
        CarouselItem(
            imageName: AppConstants.Images.soccerBackground,
            title: "Join RG10 Family",
            subtitle: "Unleash Your Full Potential on the Field, and off the Field",
            buttonTitle: "Apply Now",
            buttonAction: .applyNow,
            requiresAuth: false // Show only when NOT authenticated
        )
    ]
    
    init() {
        filterCarouselItems(isAuthenticated: AuthManager.shared.isAuthenticated)
    }
    
    func filterCarouselItems(isAuthenticated: Bool) {
        // Filter out "Apply Now" slide if user is authenticated
        if isAuthenticated {
            carouselItems = allCarouselItems.filter { item in
                // Remove the Apply Now slide for authenticated users
                if case .applyNow = item.buttonAction {
                    return false
                }
                return true
            }
        } else {
            carouselItems = allCarouselItems
        }
        
        // Reset index if it's out of bounds
        if currentCarouselIndex >= carouselItems.count {
            currentCarouselIndex = 0
        }
    }
    
    func nextCarouselItem() {
        currentCarouselIndex = (currentCarouselIndex + 1) % carouselItems.count
    }
    
    func previousCarouselItem() {
        currentCarouselIndex = currentCarouselIndex == 0 ? carouselItems.count - 1 : currentCarouselIndex - 1
    }
    
    func bookNow() {
        // This is now handled in CarouselView
    }
}

