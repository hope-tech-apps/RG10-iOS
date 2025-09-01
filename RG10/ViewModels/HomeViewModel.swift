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
    @Published var carouselItems: [CarouselItem] = TestDataFactory.makeCarouselItems()
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
    
    func nextCarouselItem() {
        currentCarouselIndex = (currentCarouselIndex + 1) % carouselItems.count
    }
    
    func previousCarouselItem() {
        currentCarouselIndex = currentCarouselIndex == 0 ? carouselItems.count - 1 : currentCarouselIndex - 1
    }
    
    func bookNow() {
        // Handle booking action
        print("Book now tapped")
    }
}
