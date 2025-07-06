//
//  HomeViewModelProtocol.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/4/25.
//

import Foundation

protocol HomeViewModelProtocol: ObservableObject {
    var carouselItems: [CarouselItem] { get }
    var videos: [VideoItem] { get }
    var currentCarouselIndex: Int { get set }
    var selectedTab: TabItem { get set }
    
    func nextCarouselItem()
    func previousCarouselItem()
    func bookNow()
}
