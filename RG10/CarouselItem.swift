//
//  CarouselItem.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/4/25.
//

import Foundation

struct CarouselItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let imageName: String
    let buttonTitle: String
}
