//
//  Icons.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/4/25.
//

import SwiftUI

enum Icons {
    // Navigation & UI Controls
    static let hamburgerMenu = "Burger"
    static let chevronLeft = "chevron.left" // Keep SF Symbol for now
    static let chevronRight = "chevron.right" // Keep SF Symbol for now
    static let play = "Play"
    static let pause = "Pause"
    static let stop = "Stop"
    static let xmark = "Close"
    static let xmarkCircleFill = "Close"
    static let moreCircle = "More circle"
    static let moreSquare = "More square"
    
    // Tab Bar Icons
    static let home = "Home"
    static let training = "figure.run" // Keep SF Symbol for now
    static let book = "Calendar"
    static let explore = "map" // Keep SF Symbol for now
    static let account = "User"
    
    // Menu Icons
    static let signIn = "Login"
    static let signOut = "Logout"
    static let createAccount = "Add user"
    static let exploreTrainings = "figure.run.circle" // Keep SF Symbol for now
    static let watchVideos = "Video"
    static let ourCoaches = "Users"
    static let playerSpotlights = "Star"
    static let merchStore = "Bag 1"
    static let bookSession = "Calendar"
    static let myAppointments = "Calendar"
    static let myPlans = "Document"
    static let aboutRG10 = "Info circle"
    static let termsOfService = "Document"
    static let privacyPolicy = "Lock"
    static let exclamationMark = "Danger"
    
    // Additional Icons - Organized by Category
    
    // Communication
    static let alarm = "Alarm clock"
    static let bell = "Bell"
    static let call = "Call"
    static let callMissed = "Call missed"
    static let callSilent = "Call silent"
    static let calling = "Calling"
    static let mail = "Mail"
    static let messageCircle = "Message circle"
    static let messageSquare = "Message square"
    static let microphone = "Microphone"
    static let noSound = "No sound (microphone)"
    
    // Media & Entertainment
    static let camera = "Camera"
    static let gamepad = "Gamepad"
    static let oldschoolGamepad = "Oldschool gamepad"
    static let headphones = "Headphones"
    static let music = "Music"
    static let musicPlate = "Music plate"
    static let volumeUp = "Volume up"
    static let volumeDown = "Volume down"
    static let volumeOff1 = "Volume off 1"
    static let volumeOff2 = "Volume off 2"
    
    // Sports
    static let basketball = "Basketball"
    
    // Shopping & Commerce
    static let bag1 = "Bag 1"
    static let bag2 = "Bag 2"
    static let bag3 = "Bag 3"
    static let cart = "Cart"
    static let creditCard = "Credit card"
    static let wallet = "Wallet"
    static let receipt = "Receipt"
    static let sale = "Sale"
    static let coupon1 = "Coupon 1"
    static let coupon2 = "Coupon 2"
    static let coupon3 = "Coupon 3"
    
    // Documents & Files
    static let bookmark = "Bookmark"
    static let document = "Document"
    static let document2 = "Document 2"
    static let documentAdd = "Document add"
    static let documentDelete = "Document delite"
    static let download = "Download 2"
    static let cloudDownload = "Cloud download"
    static let cloudUpload = "Cloud upload"
    static let cloud = "Cloud"
    static let folder = "Folder"
    static let copy = "Copy"
    
    // Editing & Tools
    static let edit1 = "Edit 1"
    static let edit2 = "Edit 2"
    static let filter = "Filter"
    static let filter1 = "Filter-1"
    static let paperclip = "Paperclip"
    static let colorPalette = "Color Palette"
    static let scale = "Scale"
    static let calculator = "Calculator"
    
    // Navigation & Location
    static let compass = "Compas"
    static let location = "Location"
    static let flag = "Flag"
    static let rocket = "Rocket"
    
    // Security & Privacy
    static let lock = "Lock"
    static let lockOpen = "Lock open"
    static let lockCheck = "Lock check"
    static let lockX = "Lock x"
    static let shield = "Shield"
    static let shield1 = "Shield-1"
    static let shield2 = "Shield-2"
    static let key = "Key"
    static let eye = "Eye"
    static let hide = "Hide"
    
    // UI Elements
    static let box1 = "Box 1"
    static let box2 = "Box 2"
    static let browser = "Browser"
    static let category = "Category"
    static let category2 = "Category 2"
    static let check = "Check"
    static let plus = "Plus"
    static let minus = "Minus"
    static let zoomIn = "Zoom in"
    static let zoomOut = "Zoom out"
    
    // Data & Analytics
    static let chart = "Chart"
    static let chart1 = "Chart 1"
    static let graph = "Graph"
    
    // Devices
    static let iPhone = "iPhone"
    static let laptop = "Laptop"
    static let screen = "Screen"
    static let mouse = "Mouse"
    
    // Status & Information
    static let infoCircle = "Info circle"
    static let infoSquare = "Info square"
    static let loading = "Loading"
    static let timeCircle = "Time Circle"
    static let timeSquare = "Time square"
    static let timer = "Timer"
    
    // Actions
    static let send = "Send"
    static let share = "Share"
    static let save = "Save"
    static let search = "Search"
    static let settings = "Settings"
    static let toggleLeft = "Toggle left"
    static let toggleRight = "Toggle right"
    static let trashCan = "Trash can"
    
    // Miscellaneous
    static let coffee = "Coffee"
    static let coins = "Coins"
    static let figma = "Figma"
    static let fire = "Fire"
    static let gift = "Gift"
    static let heart = "Heart"
    static let heartbeat = "Heartbeat"
    static let layers = "Layers"
    static let lightning = "Lightning"
    static let link = "Link"
    static let link2 = "Link 2"
    static let scanner = "Scanner"
    
    // Development Icons (for DEBUG mode)
    static let hammer = "hammer.fill" // Keep SF Symbol as no equivalent in SVG list
    static let `case` = "Case"
}

// MARK: - Icon Helper Methods
extension Icons {
    /// Returns the appropriate icon image for use in SwiftUI
    /// For SVG assets, this assumes they are added as template images in Assets.xcassets
    static func image(for iconName: String) -> Image {
        // Check if it's an SF Symbol (contains dots)
        if iconName.contains(".") {
            return Image(systemName: iconName)
        } else {
            // It's a custom SVG asset
            return Image(iconName)
        }
    }
}
