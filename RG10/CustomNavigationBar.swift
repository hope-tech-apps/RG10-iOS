//
//  CustomNavigationBar.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/4/25.
//

import SwiftUI

struct CustomNavigationBar: View {
    @Binding var showMenu: Bool
    
    var body: some View {
        HStack {
            Button(action: { showMenu.toggle() }) {
                IconView(iconName: Icons.hamburgerMenu, size: 24, color: .black)
            }
            .accessibilityIdentifier(AccessibilityIdentifiers.menuButton)
            
            Spacer()
            
            Image(AppConstants.Images.logoColor)
                .resizable()
                .scaledToFit()
                .frame(height: AppConstants.Sizes.navigationLogoHeight)
            
            Spacer()
            
            // Placeholder for balance
            Color.clear
                .frame(width: 30, height: 30)
        }
        .padding(.horizontal, AppConstants.Spacing.medium)
        .padding(.vertical, AppConstants.Spacing.small)
        .background(Color.white)
    }
}
