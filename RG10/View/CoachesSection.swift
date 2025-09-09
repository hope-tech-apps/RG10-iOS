//
//  CoachesSection.swift
//  RG10
//
//  Created by Moneeb Sayed on 8/9/25.
//

import SwiftUI

struct CoachesSection: View {
    let coaches: [Coach]
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Meet the Coaches")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(Array(coaches.enumerated()), id: \.element.id) { index, coach in
                        CoachCard(coach: coach) {
                            // Navigate to staff view with selected index
                            navigationManager.navigate(to: .staff(selectedIndex: index), in: .explore)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}
