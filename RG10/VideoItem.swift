//
//  VideoItem.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/4/25.
//

import Foundation
import SwiftUI

struct VideoItem: Identifiable {
    let id = UUID()
    let thumbnailImage: String
    let backgroundColor: Color
    let duration: String
}
