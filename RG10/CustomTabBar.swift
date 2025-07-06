//
//  CustomTabBar.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/4/25.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: TabItem
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabItem.allCases, id: \.self) { tab in
                TabBarItem(tab: tab, isSelected: selectedTab == tab) {
                    selectedTab = tab
                }
            }
        }
        .padding(.top, 8)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -5)
    }
}
