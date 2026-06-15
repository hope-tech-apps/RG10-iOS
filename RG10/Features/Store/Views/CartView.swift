//
//  CartView.swift
//  RG10
//
//  The native store bag: line items, quantity controls, subtotal, and a
//  token-free checkout handoff to Shopify via a cart permalink in StoreWebView.
//
//  On open the cart defensively refreshes prices and availability from the
//  latest products.json so stale lines (sold out / removed) are pruned.
//

import SwiftUI

struct CartView: View {
    @EnvironmentObject private var cartStore: CartStore
    @EnvironmentObject private var navigationManager: NavigationManager

    @State private var checkoutDestination: StoreBrowserDestination?
    @State private var isRefreshing = false

    private let service = MerchandiseService.shared

    var body: some View {
        Group {
            if cartStore.isEmpty {
                emptyState
            } else {
                cartContent
            }
        }
        .navigationTitle("Your Bag")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            if !cartStore.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear") {
                        cartStore.clear()
                    }
                    .foregroundColor(AppConstants.Colors.primaryRed)
                    .font(.system(size: 15, weight: .medium))
                }
            }
        }
        .sheet(item: $checkoutDestination) { destination in
            StoreWebView(
                url: destination.url,
                title: "Checkout",
                onDismiss: { checkoutDestination = nil }
            )
        }
        .task {
            await refreshCart()
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bag")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))

            Text("Your bag is empty")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)

            Text("Browse the team gear and add your favorites.")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: continueShopping) {
                Text("Continue shopping")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(AppConstants.Colors.primaryRed)
                    .cornerRadius(10)
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }

    // MARK: - Cart Content

    private var cartContent: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(cartStore.items) { item in
                        CartLineRow(item: item)
                    }
                }
                .padding(16)
            }
            .background(Color(UIColor.systemGray6))

            checkoutBar
        }
    }

    private var checkoutBar: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Subtotal")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Text(cartStore.displaySubtotal)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
            }

            Button(action: checkout) {
                Text("Checkout")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(AppConstants.Colors.primaryRed)
                    .cornerRadius(10)
            }

            Button(action: continueShopping) {
                Text("Continue shopping")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(AppConstants.Colors.primaryRed)
            }
        }
        .padding(16)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: -2)
    }

    // MARK: - Actions

    private func refreshCart() async {
        guard !cartStore.isEmpty, !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }
        if let products = try? await service.fetchProducts() {
            cartStore.refresh(with: products)
        }
    }

    private func checkout() {
        guard let url = cartStore.checkoutURL() else { return }
        checkoutDestination = StoreBrowserDestination(url: url)
    }

    private func continueShopping() {
        navigationManager.popToRoot()
    }
}

// MARK: - Cart Line Row

private struct CartLineRow: View {
    @EnvironmentObject private var cartStore: CartStore
    let item: CartItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            thumbnail

            VStack(alignment: .leading, spacing: 6) {
                Text(item.productTitle)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                    .lineLimit(2)

                if !item.variantTitle.isEmpty {
                    Text(item.variantTitle)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }

                Text(item.displayUnitPrice)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppConstants.Colors.primaryRed)

                HStack(spacing: 12) {
                    stepper
                    Spacer()
                    Button(action: { cartStore.remove(variantID: item.variantID) }) {
                        Image(systemName: "trash")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 1)
    }

    private var thumbnail: some View {
        Group {
            if let urlString = item.imageURL, let url = URL(string: urlString) {
                DownsampledAsyncImage(
                    url: url,
                    targetSize: CGSize(width: 140, height: 140),
                    contentMode: .fill
                )
                .frame(width: 70, height: 70)
                .clipped()
                .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 70, height: 70)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray.opacity(0.5))
                    )
            }
        }
    }

    private var stepper: some View {
        HStack(spacing: 0) {
            Button(action: { cartStore.setQuantity(item.quantity - 1, for: item.variantID) }) {
                Image(systemName: "minus")
                    .frame(width: 32, height: 32)
                    .foregroundColor(AppConstants.Colors.primaryRed)
            }

            Text("\(item.quantity)")
                .font(.system(size: 14, weight: .semibold))
                .frame(minWidth: 28)

            Button(action: { cartStore.setQuantity(item.quantity + 1, for: item.variantID) }) {
                Image(systemName: "plus")
                    .frame(width: 32, height: 32)
                    .foregroundColor(AppConstants.Colors.primaryRed)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}
