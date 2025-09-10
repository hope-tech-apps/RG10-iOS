//
//  MerchandiseView.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/6/25.
//

import SwiftUI

struct SupabaseMerchandiseView: View {
    @StateObject private var viewModel = SupabaseMerchandiseViewModel()
    
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
                    
                    Text("Try adjusting your filters or search terms")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.filteredProducts, id: \.id) { product in
                            NavigationLink(value: NavigationDestination.merchandiseDetail(product)) {
                                SupabaseProductCard(product: product)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
                .background(Color(UIColor.systemGray6))
            }
        }
        .navigationTitle("Merchandise")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }
}

// MARK: - Product Card (Keep the same)
struct SupabaseProductCard: View {
    let product: DBProduct
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Product Image
            ZStack(alignment: .topTrailing) {
                if let firstImageURL = product.imageArray.first,
                   let url = URL(string: firstImageURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 180)
                            .clipped()
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 180)
                            .overlay(
                                ProgressView()
                            )
                    }
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
                
                // Badges
                VStack(spacing: 4) {
                    if product.is_new {
                        Text("NEW")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green)
                            .cornerRadius(4)
                    }
                    if product.is_featured {
                        Text("FEATURED")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppConstants.Colors.primaryRed)
                            .cornerRadius(4)
                    }
                }
                .padding(8)
            }
            
            // Product Info
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(height: 50, alignment: .top)
                    .lineLimit(2)
                
                Text(product.description)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .lineLimit(1)
                
                Text("View Options")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppConstants.Colors.primaryRed)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Simple Product Detail View
struct SupabaseProductDetailView: View {
    let product: DBProduct
    @StateObject private var viewModel: SupabaseProductDetailViewModel
    @State private var showingStripeError = false
    
    init(product: DBProduct) {
        self.product = product
        self._viewModel = StateObject(wrappedValue: SupabaseProductDetailViewModel(product: product))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Image Gallery
                if !product.imageArray.isEmpty {
                    TabView {
                        ForEach(product.imageArray, id: \.self) { imageURL in
                            if let url = URL(string: imageURL) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } placeholder: {
                                    ProgressView()
                                        .frame(maxWidth: .infinity, minHeight: 400)
                                }
                            }
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .frame(height: 400)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    // Product Info
                    HStack {
                        Text(product.name)
                            .font(.system(size: 24, weight: .bold))
                        
                        Spacer()
                        
                        if product.is_new {
                            Label("NEW", systemImage: "sparkle")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green)
                                .cornerRadius(6)
                        }
                    }
                    
                    Text(product.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    // Size Selection
                    if viewModel.isLoadingSizes {
                        HStack {
                            ProgressView()
                            Text("Loading sizes...")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    } else if !viewModel.productSizes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Select Size")
                                .font(.headline)
                            
                            ForEach(viewModel.productSizes, id: \.id) { size in
                                HStack {
                                    Button(action: {
                                        viewModel.selectedSize = size
                                    }) {
                                        HStack {
                                            Image(systemName: viewModel.selectedSize?.id == size.id ? "checkmark.circle.fill" : "circle")
                                            Text(size.displayName)
                                            Spacer()
                                            Text(size.formattedPrice)
                                                .fontWeight(.semibold)
                                        }
                                        .padding()
                                        .background(
                                            viewModel.selectedSize?.id == size.id ?
                                            AppConstants.Colors.primaryRed.opacity(0.1) :
                                            Color(UIColor.secondarySystemBackground)
                                        )
                                        .cornerRadius(10)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    } else {
                        Text("No sizes available")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                    
                    // Quantity
//                    HStack {
//                        Text("Quantity")
//                            .font(.headline)
//                        
//                        Spacer()
//                        
//                        HStack(spacing: 20) {
//                            Button(action: viewModel.decrementQuantity) {
//                                Image(systemName: "minus.circle.fill")
//                                    .font(.title2)
//                                    .foregroundColor(viewModel.quantity > 1 ? AppConstants.Colors.primaryRed : .gray)
//                            }
//                            .disabled(viewModel.quantity <= 1)
//                            
//                            Text("\(viewModel.quantity)")
//                                .font(.title2.bold())
//                                .frame(width: 50)
//                            
//                            Button(action: viewModel.incrementQuantity) {
//                                Image(systemName: "plus.circle.fill")
//                                    .font(.title2)
//                                    .foregroundColor(viewModel.quantity < 10 ? AppConstants.Colors.primaryRed : .gray)
//                            }
//                            .disabled(viewModel.quantity >= 10)
//                        }
//                    }
//                    .padding(.vertical)
                    
                    // Total
                    if viewModel.selectedSize != nil {
                        HStack {
                            Text("Total")
                                .font(.title2.bold())
                            Spacer()
                            Text(viewModel.formattedTotalPrice)
                                .font(.title.bold())
                                .foregroundColor(AppConstants.Colors.primaryRed)
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                    
                    // Checkout Button
                    Button(action: {
                        if product.stripe_payment_link != nil {
                            viewModel.openStripeCheckout()
                        } else {
                            showingStripeError = true
                        }
                    }) {
                        Label("Checkout with Stripe", systemImage: "creditcard.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                viewModel.canAddToCart ?
                                AppConstants.Colors.primaryRed :
                                Color.gray
                            )
                            .cornerRadius(12)
                    }
                    .disabled(!viewModel.canAddToCart)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await viewModel.loadProductSizes()
            }
        }
        .alert("Payment Unavailable", isPresented: $showingStripeError) {
            Button("OK") { }
        } message: {
            Text("Payment link is not configured for this product.")
        }
    }
}

// MARK: - Preview
struct SupabaseMerchandiseView_Previews: PreviewProvider {
    static var previews: some View {
        SupabaseMerchandiseView()
    }
}
