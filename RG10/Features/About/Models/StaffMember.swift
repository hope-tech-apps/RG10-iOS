//
//  StaffMember.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/10/25.
//


import SwiftUI

struct StaffMember: Identifiable {
    let id = UUID()
    let name: String
    let position: String
    let mainImageURL: String
    let additionalImages: [String]
    let bio: [String]
    let subheading: String?
    let subContent: [String]?
    let achievements: [String]? // Added for highlighting key achievements
}
