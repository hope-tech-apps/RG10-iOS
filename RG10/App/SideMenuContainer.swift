//
//  SideMenuContainer.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/8/25.
//

import SwiftUI

struct SideMenuContainer: View {
    @Binding var isShowing: Bool
    @EnvironmentObject var navigationManager: NavigationManager
    
    private let menuWidth = UIScreen.main.bounds.width * 0.8
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            if isShowing {
                // Background overlay
                Color.black
                    .opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isShowing = false
                        }
                    }
                
                // Side Menu
                HStack {
                    SideMenuView(isShowing: $isShowing)
                        .environmentObject(navigationManager)
                        .frame(width: menuWidth)
                        .offset(x: dragOffset)
                        .transition(.move(edge: .leading))
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if value.translation.width < 0 {
                                        dragOffset = value.translation.width
                                    }
                                }
                                .onEnded { value in
                                    if value.translation.width < -50 {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            isShowing = false
                                            dragOffset = 0
                                        }
                                    } else {
                                        withAnimation(.spring()) {
                                            dragOffset = 0
                                        }
                                    }
                                }
                        )
                    
                    Spacer()
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isShowing)
    }
}
