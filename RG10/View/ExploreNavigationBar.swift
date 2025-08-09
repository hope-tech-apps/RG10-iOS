//
//  ExploreNavigationBar.swift
//  RG10
//
//  Created by Moneeb Sayed on 8/9/25.
//


import SwiftUI

struct ExploreNavigationBar: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        HStack(spacing: 16) {
            // Profile Image
            if let user = authManager.currentUser {
                AsyncImage(url: URL(string: "https://ui-avatars.com/api/?name=\(user.displayName ?? user.username)&background=CC3333&color=fff")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Circle()
                        .fill(AppConstants.Colors.primaryRed)
                        .overlay(
                            Text(user.username.prefix(1).uppercased())
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        )
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            } else {
                Image(Icons.account)
                    .renderingMode(.template)
                    .iconStyle(size: 24, color: .gray)
                    .frame(width: 40, height: 40)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            // Logo
            Image(AppConstants.Images.logoColor)
                .resizable()
                .scaledToFit()
                .frame(height: 30)
            
            Spacer()
            
            // Premium Button
            Button(action: {}) {
                Text("Premium")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white)
    }
}
