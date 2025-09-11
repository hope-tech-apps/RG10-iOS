//
//  WelcomeScreen.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/4/25.
//

import SwiftUI

struct WelcomeScreen: View {
    @Binding var showWelcome: Bool
    
    var body: some View {
        ZStack {
            Image(AppConstants.Images.soccerBackground)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            LinearGradient(
                gradient: Gradient(colors: [
                    AppConstants.Colors.overlayLight,
                    AppConstants.Colors.overlayDark
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Image(AppConstants.Images.logoColor)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 70)
                
                Text(LocalizedStrings.welcomeTitle)
                    .font(.system(size: AppConstants.Fonts.titleSize, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, AppConstants.Spacing.medium)
                
                Spacer()
                    .frame(height: 100)
            }
        }
        .onTapGesture {
            navigateToHome()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + AppConstants.Timing.welcomeScreenDuration) {
                navigateToHome()
            }
        }
    }
    
    private func navigateToHome() {
        withAnimation {
            showWelcome = false
        }
    }
}

//#Preview {
//    WelcomeScreen()
//}
