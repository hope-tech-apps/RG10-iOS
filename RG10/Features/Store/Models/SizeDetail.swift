//
//  SizeDetail.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/10/25.
//

import SwiftUI

struct SizeDetail {
    let id: Int
    let productId: Int
    let sizeName: String
    let sizeType: String
    let price: Double
    let stripePriceId: String?
    let inStock: Bool
    
    var displayName: String {
        if sizeType.isEmpty || sizeType == "Unknown" {
            return sizeName.uppercased()
        }
        return "\(sizeName.uppercased()) (\(sizeType))"
    }
    
    var formattedPrice: String {
        String(format: "$%.2f", price)
    }
}
