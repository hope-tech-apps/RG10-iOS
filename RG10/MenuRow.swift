//
//  MenuRow.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/4/25.
//

import SwiftUI

struct MenuRow: View {
    let title: String
    let icon: String
    var iconColor: Color = .gray
    var isDisabled: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isDisabled ? .gray.opacity(0.5) : iconColor)
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(isDisabled ? .gray.opacity(0.5) : .black)
                
                Spacer()
                
                if !isDisabled && title == LocalizedStrings.signInMenuItem {
                    Image(systemName: Icons.chevronRight)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
        }
        .disabled(isDisabled)
    }
}
