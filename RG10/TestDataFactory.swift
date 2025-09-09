//
//  TestDataFactory.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/4/25.
//

import SwiftUI

enum TestDataFactory {
    static func makeCarouselItems() -> [CarouselItem] {
        return [
            CarouselItem(
                imageName: "carousel_training",
                title: "RG10 FOOTBALL",
                subtitle: "Unleash Your Full Potential on the Field, and off the Field",
                buttonTitle: "Book Now",
                buttonAction: .bookNow,
                requiresAuth: false
            ),
            CarouselItem(
                imageName: "carousel_excellence",
                title: "Training Excellence",
                subtitle: "Professional coaching to elevate your game",
                buttonTitle: "Learn More",
                buttonAction: .learnMore,
                requiresAuth: false
            ),
            CarouselItem(
                imageName: "carousel_join",
                title: "Join RG10 Family",
                subtitle: "Start your journey with us today",
                buttonTitle: "Apply Now",
                buttonAction: .applyNow,
                requiresAuth: false
            )
        ]
    }
    
    static func makeVideoItems() -> [VideoItem] {
        [
            VideoItem(
                thumbnailImage: AppConstants.Images.videoThumbnail1,
                backgroundColor: AppConstants.Colors.primaryRed,
                duration: "2:45"
            ),
            VideoItem(
                thumbnailImage: AppConstants.Images.videoThumbnail2,
                backgroundColor: .black,
                duration: "3:20"
            )
        ]
    }
}
