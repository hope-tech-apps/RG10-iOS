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
        ZStack(alignment: .bottomLeading) {
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
            
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                
                Image(AppConstants.Images.logoColor)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 167, height: 117)

                Text(LocalizedStrings.welcomeTitle)
                    .font(.system(size: AppConstants.Fonts.titleSize, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding()
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
