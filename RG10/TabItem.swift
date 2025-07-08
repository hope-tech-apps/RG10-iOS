//
//  TabItem.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/4/25.
//

import Foundation

enum TabItem: CaseIterable {
    case home
    case training
    case book
    case explore
    case account
    
    var title: String {
        switch self {
        case .home: return LocalizedStrings.homeTab
        case .training: return LocalizedStrings.trainingTab
        case .book: return LocalizedStrings.bookTab
        case .explore: return LocalizedStrings.exploreTab
        case .account: return LocalizedStrings.accountTab
        }
    }
    
    var icon: String {
        switch self {
        case .home: return Icons.home
        case .training: return Icons.fire
        case .book: return Icons.book
        case .explore: return Icons.compass
        case .account: return Icons.account
        }
    }
    
    // Get available tabs based on authentication status
    static func availableTabs(isAuthenticated: Bool) -> [TabItem] {
        if isAuthenticated {
            return [.home, .training, .book, .explore]
        } else {
            return TabItem.allCases
        }
    }
}
