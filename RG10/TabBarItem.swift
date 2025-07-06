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
                Image(systemName: tab.icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? Color(red: 204/255, green: 51/255, blue: 51/255) : .gray)
                
                Text(tab.title)
                    .font(.system(size: 10))
                    .foregroundColor(isSelected ? Color(red: 204/255, green: 51/255, blue: 51/255) : .gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
}
