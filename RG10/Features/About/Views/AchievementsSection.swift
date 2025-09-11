//
//  AchievementsSection.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/10/25.
//

import SwiftUI

struct AchievementsSection: View {
    let achievements: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(achievements, id: \.self) { achievement in
                    AchievementBadge(text: achievement)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 20)
        }
        .background(Color.gray.opacity(0.05))
    }
}
