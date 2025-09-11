//
//  Merchandise.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/6/25.
//

import Foundation
import Supabase
import SwiftUI
import Combine

// MARK: - Database Models
struct Merchandise: Codable, Hashable {
    let id: Int
    let name: String
    let description: String
    let category_id: Int?
    let image_urls: [String]?
    let is_new: Bool
    let is_featured: Bool
    let stripe_product_id: String?
    let stripe_payment_link: String?
    let created_at: String  // Changed to String to handle raw format
    let updated_at: String  // Changed to String to handle raw format
    
    var imageArray: [String] {
        return image_urls ?? []
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Merchandise, rhs: Merchandise) -> Bool {
        lhs.id == rhs.id
    }
}
