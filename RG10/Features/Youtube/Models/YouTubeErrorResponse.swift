//
//  YouTubeErrorResponse.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/10/25.
//


import Foundation
import Combine

struct YouTubeErrorResponse: Codable {
    struct ErrorDetail: Codable {
        struct ErrorItem: Codable {
            let domain: String?
            let reason: String?
            let message: String?
        }
        
        let code: Int
        let message: String
        let status: String?
        let errors: [ErrorItem]?
    }
    
    let error: ErrorDetail
}

