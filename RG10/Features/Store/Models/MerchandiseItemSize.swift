//
//  DBProductSize.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/10/25.
//

import SwiftUI

struct MerchandiseItemSize: Codable {
    let id: Int
    let product_id: Int
    let size_id: Int
    let price: Double
    let stripe_price_id: String?
}
