//
//  MockHomeViewModel.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/4/25.
//


import XCTest
import SwiftUI
@testable import RG10
internal import Combine

// MARK: - Mock ViewModel for Testing
class MockHomeViewModel: HomeViewModelProtocol {
    @Published var carouselItems: [CarouselItem] = []
    @Published var videos: [VideoItem] = []
    @Published var currentCarouselIndex: Int = 0
    @Published var selectedTab: TabItem = .home
    
    var bookNowCalled = false
    var nextCarouselItemCallCount = 0
    var previousCarouselItemCallCount = 0
    
    func nextCarouselItem() {
        nextCarouselItemCallCount += 1
        currentCarouselIndex = (currentCarouselIndex + 1) % carouselItems.count
    }
    
    func previousCarouselItem() {
        previousCarouselItemCallCount += 1
        currentCarouselIndex = currentCarouselIndex == 0 ? carouselItems.count - 1 : currentCarouselIndex - 1
    }
    
    func bookNow() {
        bookNowCalled = true
    }
}

// MARK: - HomeViewModel Tests
class HomeViewModelTests: XCTestCase {
    var sut: HomeViewModel!
    
    override func setUp() {
        super.setUp()
        sut = HomeViewModel()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertEqual(sut.currentCarouselIndex, 0)
        XCTAssertEqual(sut.selectedTab, .home)
        XCTAssertEqual(sut.carouselItems.count, 3)
        XCTAssertEqual(sut.videos.count, 2)
    }
    
    func testNextCarouselItem() {
        // Given
        let initialIndex = sut.currentCarouselIndex
        
        // When
        sut.nextCarouselItem()
        
        // Then
        XCTAssertEqual(sut.currentCarouselIndex, initialIndex + 1)
        
        // Test wrap around
        sut.currentCarouselIndex = sut.carouselItems.count - 1
        sut.nextCarouselItem()
        XCTAssertEqual(sut.currentCarouselIndex, 0)
    }
    
    func testPreviousCarouselItem() {
        // Given
        sut.currentCarouselIndex = 1
        
        // When
        sut.previousCarouselItem()
        
        // Then
        XCTAssertEqual(sut.currentCarouselIndex, 0)
        
        // Test wrap around
        sut.currentCarouselIndex = 0
        sut.previousCarouselItem()
        XCTAssertEqual(sut.currentCarouselIndex, sut.carouselItems.count - 1)
    }
    
    func testSelectedTabChange() {
        // Given
        let newTab = TabItem.training
        
        // When
        sut.selectedTab = newTab
        
        // Then
        XCTAssertEqual(sut.selectedTab, newTab)
    }
}

// MARK: - AppCoordinator Tests
class AppCoordinatorTests: XCTestCase {
    var sut: AppCoordinator!
    
    override func setUp() {
        super.setUp()
        sut = AppCoordinator()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testInitialScreen() {
        XCTAssertEqual(sut.currentScreen, .loading)
    }
    
    func testNavigateToWelcome() {
        // When
        sut.navigateToWelcome()
        
        // Then
        XCTAssertEqual(sut.currentScreen, .welcome)
    }
    
    func testNavigateToHome() {
        // When
        sut.navigateToHome()
        
        // Then
        XCTAssertEqual(sut.currentScreen, .home)
    }
}

// MARK: - Model Tests
class ModelTests: XCTestCase {
    
    func testCarouselItemCreation() {
        // Given
        let title = "Test Title"
        let subtitle = "Test Subtitle"
        let imageName = "test_image"
        let buttonTitle = "Test Button"
        
        // When
        let item = CarouselItem(
            title: title,
            subtitle: subtitle,
            imageName: imageName,
            buttonTitle: buttonTitle
        )
        
        // Then
        XCTAssertEqual(item.title, title)
        XCTAssertEqual(item.subtitle, subtitle)
        XCTAssertEqual(item.imageName, imageName)
        XCTAssertEqual(item.buttonTitle, buttonTitle)
        XCTAssertNotNil(item.id)
    }
    
    func testVideoItemCreation() {
        // Given
        let thumbnailImage = "thumbnail"
        let backgroundColor = Color.red
        let duration = "2:30"
        
        // When
        let video = VideoItem(
            thumbnailImage: thumbnailImage,
            backgroundColor: backgroundColor,
            duration: duration
        )
        
        // Then
        XCTAssertEqual(video.thumbnailImage, thumbnailImage)
        XCTAssertEqual(video.backgroundColor, backgroundColor)
        XCTAssertEqual(video.duration, duration)
        XCTAssertNotNil(video.id)
    }
    
    func testTabItemProperties() {
        // Test all tab items
        XCTAssertEqual(TabItem.home.title, "Home")
        XCTAssertEqual(TabItem.home.icon, "house.fill")
        
        XCTAssertEqual(TabItem.training.title, "Training")
        XCTAssertEqual(TabItem.training.icon, "figure.run")
        
        XCTAssertEqual(TabItem.book.title, "Book")
        XCTAssertEqual(TabItem.book.icon, "calendar")
        
        XCTAssertEqual(TabItem.explore.title, "Explore")
        XCTAssertEqual(TabItem.explore.icon, "map")
        
        XCTAssertEqual(TabItem.account.title, "Account")
        XCTAssertEqual(TabItem.account.icon, "person.fill")
    }
    
    func testTabItemAllCases() {
        let allCases = TabItem.allCases
        XCTAssertEqual(allCases.count, 5)
        XCTAssertTrue(allCases.contains(.home))
        XCTAssertTrue(allCases.contains(.training))
        XCTAssertTrue(allCases.contains(.book))
        XCTAssertTrue(allCases.contains(.explore))
        XCTAssertTrue(allCases.contains(.account))
    }
}

// MARK: - Integration Tests
class IntegrationTests: XCTestCase {
    
    func testCarouselNavigationFlow() {
        // Given
        let viewModel = HomeViewModel()
        let initialIndex = viewModel.currentCarouselIndex
        let itemCount = viewModel.carouselItems.count
        
        // When - Navigate through all items
        for _ in 0..<itemCount {
            viewModel.nextCarouselItem()
        }
        
        // Then - Should return to initial index
        XCTAssertEqual(viewModel.currentCarouselIndex, initialIndex)
    }
    
    func testAppCoordinatorFlow() {
        // Given
        let coordinator = AppCoordinator()
        
        // When & Then
        XCTAssertEqual(coordinator.currentScreen, .loading)
        
        coordinator.navigateToWelcome()
        XCTAssertEqual(coordinator.currentScreen, .welcome)
        
        coordinator.navigateToHome()
        XCTAssertEqual(coordinator.currentScreen, .home)
    }
}
