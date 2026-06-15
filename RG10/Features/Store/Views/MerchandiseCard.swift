//
//  MerchandiseCard.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/10/25.
//
//  Grid card for a single Shopify product from the live Flite Sports store.
//

import SwiftUI

struct MerchandiseCard: View {
    let product: ShopifyProduct

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Product Image
            ZStack(alignment: .topTrailing) {
                if let imageURL = product.firstImageURL {
                    DownsampledAsyncImage(
                        url: imageURL,
                        targetSize: CGSize(width: 180, height: 180),
                        contentMode: .fill
                    )
                    .frame(height: 180)
                    .frame(maxWidth: .infinity)
                    .clipped()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 180)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(.gray.opacity(0.5))
                        )
                }

                // Sold-out badge
                if product.isSoldOut {
                    Text("SOLD OUT")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.75))
                        .cornerRadius(4)
                        .padding(8)
                }
            }

            // Product Info
            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(height: 40, alignment: .top)
                    .lineLimit(2)

                if !product.displayPrice.isEmpty {
                    Text(product.displayPrice)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppConstants.Colors.primaryRed)
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}
