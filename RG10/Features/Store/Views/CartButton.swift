//
//  CartButton.swift
//  RG10
//
//  Store header bag icon with a live item-count badge, driven by CartStore.
//

import SwiftUI

struct CartButton: View {
    @EnvironmentObject private var cartStore: CartStore
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "bag")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(AppConstants.Colors.primaryRed)
                    .padding(4)

                if cartStore.itemCount > 0 {
                    Text("\(cartStore.itemCount)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(AppConstants.Colors.primaryRed)
                        .clipShape(Capsule())
                        .offset(x: 6, y: -6)
                }
            }
        }
        .accessibilityLabel("Cart, \(cartStore.itemCount) items")
    }
}
