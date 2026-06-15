//
//  TSTSpotlightView.swift
//  RG10
//
//  Detail screen for the RG10 at TST 2026 spotlight. Reached from the Home
//  spotlight card; its primary action sends the user to the team-gear store.
//

import SwiftUI

struct TSTSpotlightView: View {
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero
                ZStack(alignment: .bottomLeading) {
                    Image(AppConstants.Images.soccerBackground)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 280)
                        .clipped()

                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.black.opacity(0.0), Color.black.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 280)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("TST 2026")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                            .tracking(2)

                        Text("WE WERE AT TST 2026")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(24)
                }
                .frame(maxWidth: .infinity)
                .clipped()

                // Body
                VStack(alignment: .leading, spacing: 24) {
                    Text("RG10 took the pitch at TST 2026 — The Soccer Tournament, one of the world's premier 7v7 events. Rep the squad with the official 2026 TST team gear.")
                        .font(.system(size: 16))
                        .foregroundColor(.black.opacity(0.8))
                        .lineSpacing(4)

                    Button(action: {
                        navigationManager.navigate(to: .merchandise, in: .home)
                    }) {
                        HStack {
                            Image(systemName: "bag.fill")
                            Text("Shop the Team Gear")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppConstants.Colors.primaryRed)
                        .cornerRadius(12)
                    }
                }
                .padding(24)
            }
        }
        .navigationTitle("TST 2026")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }
}

// MARK: - Preview
struct TSTSpotlightView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TSTSpotlightView()
                .environmentObject(NavigationManager.shared)
        }
    }
}
