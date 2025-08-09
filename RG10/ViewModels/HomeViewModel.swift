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
    @Published var videos: [VideoItem] = TestDataFactory.makeVideoItems()
    
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
