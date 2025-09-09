//
//  CarouselItem.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/4/25.
//

import Foundation

struct CarouselItem: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let subtitle: String
    let buttonTitle: String
    let buttonAction: CarouselAction
    let requiresAuth: Bool // Add this to filter based on auth
    
    enum CarouselAction {
        case bookNow
        case learnMore
        case applyNow
        case custom(action: () -> Void)
    }
}
