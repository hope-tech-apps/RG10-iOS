//
//  LoadingScreen.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/4/25.
//


import SwiftUI

struct LoadingScreen: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color.black)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Rectangle()
                    .fill(AppConstants.Colors.primaryRed)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Image(AppConstants.Images.logoWhite)
                    .resizable()
                    .scaledToFit()
                    .frame(width: AppConstants.Sizes.logoWidth, height: AppConstants.Sizes.logoHeight)
                
                Spacer()
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(Layout.progressViewScale)
                    .padding(.bottom, Layout.progressViewBottomPadding)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + AppConstants.Timing.loadingScreenDuration) {
                withAnimation(AppConstants.CurveAnimation.defaultCurve) {
                    coordinator.navigateToWelcome()
                }
            }
        }
    }
}

#Preview {
    LoadingScreen()
}
