//
//  StripePaymentIntent.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/17/25.
//

import Foundation

struct StripePaymentIntent: Codable {
    let id: String
    let clientSecret: String
    let customerId: String?
    let ephemeralKeySecret: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case clientSecret = "client_secret"
        case customerId = "customer"
        case ephemeralKeySecret = "ephemeral_key_secret"
    }
}
