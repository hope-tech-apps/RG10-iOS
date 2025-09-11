//
//  StaffSelectorTabs.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/10/25.
//

import SwiftUI

struct StaffSelectorTabs: View {
    let staffMembers: [StaffMember]
    @Binding var selectedIndex: Int?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(Array(staffMembers.enumerated()), id: \.element.id) { index, member in
                    StaffTab(
                        name: member.name,
                        position: member.position,
                        isSelected: index == selectedIndex
                    ) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedIndex = index
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(
            Rectangle()
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
}
