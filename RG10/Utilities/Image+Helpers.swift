//
//  Image+Helpers.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/10/25.
//

import SwiftUI

extension Image {
    init(icon: String) {
        // Check if it's an SF Symbol (contains dots or specific keywords)
        if icon.contains(".") || icon.contains("figure.run") {
            self.init(systemName: icon)
        } else {
            // It's a custom SVG
            self.init(icon)
        }
    }
}
