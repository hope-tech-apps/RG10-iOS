//
//  IconView.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/22/25.
//

import SwiftUI

/// A view that displays either an SF Symbol or a custom SVG image
struct IconView: View {
    let iconName: String
    var size: CGFloat = 20
    var color: Color = .black
    
    var body: some View {
        if iconName.contains(".") {
            // SF Symbol
            Image(systemName: iconName)
                .font(.system(size: size))
                .foregroundColor(color)
        } else {
            // Custom SVG image
            Image(iconName)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .foregroundColor(color)
        }
    }
}

// MARK: - Updated MenuRow

// MARK: - Updated CustomNavigationBar

// MARK: - Updated TabBarItem

// MARK: - Updated VideoThumbnail

// MARK: - Updated CarouselView Navigation Buttons
