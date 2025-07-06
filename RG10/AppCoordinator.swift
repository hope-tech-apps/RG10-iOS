//
//  AppCoordinator.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/4/25.
//

import Foundation
import Combine

class AppCoordinator: ObservableObject {
    enum Screen {
        case loading
        case welcome
        case home
    }
    
    @Published var currentScreen: Screen = .loading
    
    func navigateToWelcome() {
        currentScreen = .welcome
    }
    
    func navigateToHome() {
        currentScreen = .home
    }
}
