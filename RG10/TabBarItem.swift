//
//  TabBarItem.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/4/25.
//

import SwiftUI

struct TabBarItem: View {
    let tab: TabItem
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                IconView(
                    iconName: tab.icon,
                    size: 20,
                    color: isSelected ? AppConstants.Colors.primaryRed : .gray
                )
                
                Text(tab.title)
                    .font(.system(size: 10))
                    .foregroundColor(isSelected ? AppConstants.Colors.primaryRed : .gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
}
