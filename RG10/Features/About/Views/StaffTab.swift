//
//  StaffTab.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/10/25.
//

import SwiftUI

struct StaffTab: View {
    let name: String
    let position: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(name)
                    .font(.system(size: 16, weight: isSelected ? .bold : .semibold))
                    .foregroundColor(isSelected ? AppConstants.Colors.primaryRed : .black)
                
                Text(position)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(isSelected ? AppConstants.Colors.primaryRed.opacity(0.8) : .gray)
                    .lineLimit(1)
                
                // Selection indicator - more prominent
                Capsule()
                    .fill(AppConstants.Colors.primaryRed)
                    .frame(width: isSelected ? 40 : 0, height: 3)
                    .opacity(isSelected ? 1 : 0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? AppConstants.Colors.primaryRed.opacity(0.08) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? AppConstants.Colors.primaryRed.opacity(0.2) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

@available(iOS 26.0, *)
struct GlassStaffTab: View {
    let name: String
    let position: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(name)
                    .font(.system(size: 16, weight: isSelected ? .bold : .semibold))
                    .foregroundColor(isSelected ? AppConstants.Colors.primaryRed : .black)
                
                Text(position)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(isSelected ? AppConstants.Colors.primaryRed.opacity(0.8) : .gray)
                    .lineLimit(1)
                
                // Selection indicator - more prominent
                Capsule()
                    .fill(AppConstants.Colors.primaryRed)
                    .frame(width: isSelected ? 40 : 0, height: 3)
                    .opacity(isSelected ? 1 : 0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? AppConstants.Colors.primaryRed.opacity(0.08) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? AppConstants.Colors.primaryRed.opacity(0.2) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
//        .glassEffect()
    }
}
