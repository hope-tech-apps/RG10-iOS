//
//  MerchandiseView.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/6/25.
//
//  Native grid of the live Flite Sports Shopify collection. Tapping a product,
//  or the "Shop the full collection" header, opens an in-app browser for size
//  selection, cart, and Shopify checkout.
//

import SwiftUI
import Combine

/// Wraps a URL so it can drive `sheet(item:)` for the in-app store browser.
struct StoreBrowserDestination: Identifiable {
    let url: URL
    var id: String { url.absoluteString }
}

struct MerchandiseView: View {
    @StateObject private var viewModel = MerchandiseViewModel()
    @EnvironmentObject private var navigationManager: NavigationManager
    @State private var browserDestination: StoreBrowserDestination?

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)

                TextField("Search products...", text: $viewModel.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onChange(of: viewModel.searchText) { _ in
                        viewModel.filterProducts()
                    }

                if !viewModel.searchText.isEmpty {
                    Button(action: {
                        viewModel.searchText = ""
                        viewModel.filterProducts()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(12)
            .background(Color(UIColor.systemGray5))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.vertical, 8)

            // Shop the full collection
            Button(action: { openCollection() }) {
                HStack {
                    Image(systemName: "bag.fill")
                    Text("Shop the full collection")
                        .font(.system(size: 16, weight: .semibold))
                    Spacer()
                    Image(systemName: "arrow.up.right")
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(AppConstants.Colors.primaryRed)
                .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)

            // Products Grid
            if viewModel.isLoading {
                Spacer()
                ProgressView("Loading products...")
                    .padding()
                Spacer()
            } else if let error = viewModel.errorMessage {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    Text(error)
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button("Retry") {
                        Task {
                            await viewModel.loadProducts()
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(AppConstants.Colors.primaryRed)
                    .cornerRadius(8)

                    Button("Open the store") {
                        openCollection()
                    }
                    .foregroundColor(AppConstants.Colors.primaryRed)
                    .font(.system(size: 15, weight: .medium))
                }
                Spacer()
            } else if viewModel.filteredProducts.isEmpty {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "bag.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.5))

                    Text("No products found")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)

                    Text("Try adjusting your search, or shop the full collection.")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.filteredProducts, id: \.id) { product in
                            Button(action: { openProduct(product) }) {
                                MerchandiseCard(product: product)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
                .background(Color(UIColor.systemGray6))
            }
        }
        .navigationTitle("Team Gear")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                CartButton {
                    navigationManager.navigate(to: .cart, in: navigationManager.selectedTab)
                }
            }
        }
        .sheet(item: $browserDestination) { destination in
            StoreWebView(
                url: destination.url,
                title: "Flite Sports",
                onDismiss: { browserDestination = nil }
            )
        }
    }

    private func openCollection() {
        guard let url = URL(string: StoreConstants.collectionURL) else { return }
        browserDestination = StoreBrowserDestination(url: url)
    }

    private func openProduct(_ product: ShopifyProduct) {
        navigationManager.navigate(to: .productDetail(product), in: navigationManager.selectedTab)
    }
}

// MARK: - Preview
struct MerchandiseView_Previews: PreviewProvider {
    static var previews: some View {
        MerchandiseView()
    }
}
