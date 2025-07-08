//
//  CarouselView.swift
//  RG10
//
//  Created by Moneeb Sayed on 7/4/25.
//

import SwiftUI

struct CarouselView<ViewModel: HomeViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        ZStack {
            // Background Image
            Image(viewModel.carouselItems[viewModel.currentCarouselIndex].imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 400)
                .clipped()
            
            // Gradient Overlay
            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.0), Color.black.opacity(0.5)]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Content
            VStack {
                Spacer()
                
                Text(viewModel.carouselItems[viewModel.currentCarouselIndex].title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text(viewModel.carouselItems[viewModel.currentCarouselIndex].subtitle)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 8)
                
                Button(action: { viewModel.bookNow() }) {
                    Text(viewModel.carouselItems[viewModel.currentCarouselIndex].buttonTitle)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(Color(red: 204/255, green: 51/255, blue: 51/255))
                        .cornerRadius(25)
                }
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
            
            // Navigation Arrows
            HStack {
                navigationButton(
                    icon: Icons.chevronLeft,
                    action: { viewModel.previousCarouselItem()
                    })
                .padding(.leading, 16)
                
                Spacer()
                
                navigationButton(
                    icon: Icons.chevronRight,
                    action: { viewModel.nextCarouselItem()
                    })
                .padding(.trailing, 16)
            }
            
            // Page Indicators
            VStack {
                Spacer()
                HStack(spacing: 8) {
                    ForEach(0..<viewModel.carouselItems.count, id: \.self) { index in
                        Circle()
                            .fill(index == viewModel.currentCarouselIndex ? Color.white : Color.white.opacity(0.5))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 16)
            }
        }
    }
}

extension CarouselView {
    func navigationButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            IconView(iconName: icon, size: 20, color: .black)
                .frame(width: 44, height: 44)
                .background(Color.white)
                .clipShape(Circle())
        }
    }
}
