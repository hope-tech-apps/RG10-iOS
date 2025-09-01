//
//  CoachesSection.swift
//  RG10
//
//  Created by Moneeb Sayed on 8/9/25.
//

import SwiftUI

// MARK: - Coaches Section
struct CoachesSection: View {
    let coaches: [Coach]
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Meet the Coaches")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(coaches) { coach in
                        CoachCard(coach: coach) {
                            let index = coaches.firstIndex(where: { $0.id == coach.id })
                            coordinator.showStaff(selectedStaff: index)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}
