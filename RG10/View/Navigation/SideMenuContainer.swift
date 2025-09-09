//
//  SideMenuContainer.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/8/25.
//

import SwiftUI

struct SideMenuContainer: View {
    @Binding var isShowing: Bool
    let menuWidth: CGFloat
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black
                .opacity(isShowing ? max(0, min(1, 0.3 * (CGFloat(1.0) - abs(dragOffset) / menuWidth))) : 0)
                .ignoresSafeArea()
                .onTapGesture {
                    close()
                }
                .animation(.easeInOut(duration: 0.3), value: isShowing)
            
            // Side Menu
            HStack {
                SideMenuView(isShowing: $isShowing)
                    .environmentObject(AppCoordinator())
                    .frame(width: menuWidth)
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 5, y: 0)
                    .offset(x: isShowing ? dragOffset : -menuWidth)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                // Allow dragging in both directions but limit to menu width
                                let translation = value.translation.width
                                if translation < 0 {
                                    // Dragging left (closing)
                                    dragOffset = max(translation, -menuWidth)
                                } else {
                                    // Dragging right (opening more) - add resistance
                                    dragOffset = min(translation * 0.3, 30)
                                }
                            }
                            .onEnded { value in
                                let velocity = value.predictedEndTranslation.width
                                let translation = value.translation.width
                                
                                // Determine if we should close based on drag distance or velocity
                                if translation < -menuWidth * 0.4 || velocity < -menuWidth {
                                    close()
                                } else {
                                    // Snap back to open
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        dragOffset = 0
                                    }
                                }
                            }
                    )
                
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                dragOffset = 0
            }
        }
    }
    
    private func close() {
        withAnimation(.easeInOut(duration: 0.25)) {
            dragOffset = -menuWidth
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            isShowing = false
            dragOffset = 0
        }
    }
}
