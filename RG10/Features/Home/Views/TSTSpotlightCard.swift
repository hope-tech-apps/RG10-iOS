//
//  TSTSpotlightCard.swift
//  RG10
//
//  Home spotlight promoting RG10's appearance at TST 2026 and the official
//  team gear. Tapping it opens the TST spotlight detail screen.
//

import SwiftUI

struct TSTSpotlightCard: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomLeading) {
                Image(AppConstants.Images.soccerBackground)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 180)
                    .clipped()

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                AppConstants.Colors.primaryRed.opacity(0.85),
                                AppConstants.Colors.primaryRed.opacity(0.55)
                            ],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(height: 180)

                VStack(alignment: .leading, spacing: 6) {
                    Text("RG10 AT TST 2026")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)

                    Text("We brought the squad to The Soccer Tournament. Shop the official team gear.")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.95))
                        .lineLimit(2)
                }
                .padding(16)
            }
            .frame(height: 180)
            .frame(maxWidth: .infinity)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
