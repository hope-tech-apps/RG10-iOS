//
//  RoundedCorner.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/10/25.
//

import SwiftUI


// MARK: - Corner Radius Extension

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
