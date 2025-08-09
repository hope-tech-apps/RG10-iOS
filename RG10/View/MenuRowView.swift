//
//  MenuRowView.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/4/25.
//

import SwiftUI

// MARK: - Menu Row View
struct MenuRowView: View {
    let title: String
    let icon: String
    var iconColor: Color = .gray
    var isDisabled: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(icon: icon)
                    .renderingMode(.template)
                    .iconStyle(size: 20, color: isDisabled ? .gray.opacity(0.5) : iconColor)
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(isDisabled ? .gray.opacity(0.5) : .black)
                
                Spacer()
                
                if !isDisabled && title == LocalizedStrings.signInMenuItem {
                    Image(Icons.chevronRight)
                        .renderingMode(.template)
                        .iconStyle(size: 14, color: .gray)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
        }
        .disabled(isDisabled)
    }
}

