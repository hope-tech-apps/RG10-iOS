//
//  StaffHeroHeader.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/10/25.
//

import SwiftUI

struct StaffHeroHeader: View {
    var body: some View {
        ZStack {
            // Background
            Rectangle()
                .fill(Color.black)
                .frame(height: 200)
            
            // Pattern overlay
            GeometryReader { geometry in
                ForEach(0..<5, id: \.self) { row in
                    ForEach(0..<8, id: \.self) { col in
                        Image(Icons.shield)
                            .renderingMode(.template)
                            .iconStyle(size: 30, color: .white.opacity(0.05))
                            .position(
                                x: CGFloat(col) * 60 + 30,
                                y: CGFloat(row) * 60 + 30
                            )
                    }
                }
            }
            .frame(height: 200)
            
            // Content
            VStack(spacing: 8) {
                Text("OUR TEAM")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppConstants.Colors.primaryRed)
                    .tracking(2)
                
                Text("Meet the Coaches")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Dedicated to Building Champions")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.top, 40)
        }
        .frame(height: 200)
    }
}
