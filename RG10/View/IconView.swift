//
//  IconView.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/22/25.
//

import SwiftUI

// MARK: - Icon View Helper
struct IconView: View {
    let iconName: String
    let size: CGFloat
    let color: Color
    
    var body: some View {
        Image(icon: iconName)
            .renderingMode(.template)
            .iconStyle(size: size, color: color)
    }
}
