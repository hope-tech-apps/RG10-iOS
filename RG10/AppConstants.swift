//
//  AppConstants.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/4/25.
//

import SwiftUI

// MARK: - App Constants
enum AppConstants {
    enum Timing {
        static let loadingScreenDuration: TimeInterval = 1.0
        static let welcomeScreenDuration: TimeInterval = 1.0
        static let animationDuration: TimeInterval = 0.5
    }
    
    enum Images {
        static let logoColor = "rg10-color"
        static let logoWhite = "rg10-white"
        static let soccerBackground = "soccer_background"
        static let videoThumbnail1 = "video_thumbnail_1"
        static let videoThumbnail2 = "video_thumbnail_2"
    }
    
    enum Colors {
        static let primaryRed = Color(red: 204/255, green: 51/255, blue: 51/255)
        static let overlayDark = Color.black.opacity(0.5)
        static let overlayLight = Color.black.opacity(0.3)
        static let tabBarShadow = Color.black.opacity(0.1)
        static let alertBackground = Color(red: 1.0, green: 0.9, blue: 0.9)
        static let developmentOverlay = Color.black.opacity(0.9)
    }
    
    enum Fonts {
        static let titleSize: CGFloat = 48
        static let headingSize: CGFloat = 28
        static let subheadingSize: CGFloat = 20
        static let bodySize: CGFloat = 16
        static let captionSize: CGFloat = 10
    }
    
    enum Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let extraLarge: CGFloat = 40
    }
    
    enum Sizes {
        static let logoWidth: CGFloat = 200
        static let logoHeight: CGFloat = 80
        static let logoSideMenuHeight: CGFloat = 60
        static let navigationLogoHeight: CGFloat = 40
        static let tabIconSize: CGFloat = 20
        static let carouselHeight: CGFloat = 400
        static let videoThumbnailWidth: CGFloat = 240
        static let videoThumbnailHeight: CGFloat = 160
        static let navigationButtonSize: CGFloat = 44
        static let pageIndicatorSize: CGFloat = 8
    }
    
    enum CurveAnimation {
        static let defaultCurve = Animation.easeInOut(duration: Timing.animationDuration)
        static let menuCurve = Animation.easeInOut(duration: 0.3)
    }
}
