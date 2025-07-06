//
//  TestDataFactory.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/4/25.
//

import SwiftUI

enum TestDataFactory {
    static func makeCarouselItems() -> [CarouselItem] {
        [
            CarouselItem(
                title: LocalizedStrings.carouselTitle1,
                subtitle: LocalizedStrings.carouselSubtitle1,
                imageName: AppConstants.Images.soccerBackground,
                buttonTitle: LocalizedStrings.carouselButton1
            ),
            CarouselItem(
                title: LocalizedStrings.carouselTitle2,
                subtitle: LocalizedStrings.carouselSubtitle2,
                imageName: AppConstants.Images.soccerBackground,
                buttonTitle: LocalizedStrings.carouselButton2
            ),
            CarouselItem(
                title: LocalizedStrings.carouselTitle3,
                subtitle: LocalizedStrings.carouselSubtitle3,
                imageName: AppConstants.Images.soccerBackground,
                buttonTitle: LocalizedStrings.carouselButton3
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
