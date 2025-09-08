//
//  MerchandiseView.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/6/25.
//

//
//  SupabaseMerchandiseViews.swift
//  RG10
//
//  Updated merchandise views for Supabase integration
//

import SwiftUI

// MARK: - Main Merchandise View
struct SupabaseMerchandiseView: View {
    @StateObject private var viewModel = SupabaseMerchandiseViewModel()
    @State private var selectedProduct: DBProduct?
    @State private var showingProductDetail = false
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
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
                
                // Category Filter
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 12) {
//                        // All Products button
//                        Button(action: {
//                            viewModel.selectCategory(nil)
//                        }) {
//                            Text("All")
//                                .font(.system(size: 14, weight: .medium))
//                                .foregroundColor(viewModel.selectedCategory == nil ? .white : .black)
//                                .padding(.horizontal, 16)
//                                .padding(.vertical, 8)
//                                .background(
//                                    viewModel.selectedCategory == nil ?
//                                    AppConstants.Colors.primaryRed : Color(UIColor.systemGray5)
//                                )
//                                .cornerRadius(20)
//                        }
//                        
//                        // Category buttons
//                        ForEach(viewModel.categories, id: \.id) { category in
//                            Button(action: {
//                                viewModel.selectCategory(category)
//                            }) {
//                                Text(category.category.capitalized)
//                                    .font(.system(size: 14, weight: .medium))
//                                    .foregroundColor(viewModel.selectedCategory?.id == category.id ? .white : .black)
//                                    .padding(.horizontal, 16)
//                                    .padding(.vertical, 8)
//                                    .background(
//                                        viewModel.selectedCategory?.id == category.id ?
//                                        AppConstants.Colors.primaryRed : Color(UIColor.systemGray5)
//                                    )
//                                    .cornerRadius(20)
//                            }
//                        }
//                    }
//                    .padding(.horizontal)
//                    .padding(.vertical, 8)
//                }
                
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
                                SupabaseProductCard(product: product)
                                    .onTapGesture {
                                        selectedProduct = product
                                        showingProductDetail = true
                                    }
                            }
                        }
                        .padding()
                    }
                    .background(Color(UIColor.systemGray6))
                }
            }
            .navigationTitle("Merchandise")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingProductDetail) {
                if let product = selectedProduct {
                    SupabaseProductDetailView(product: product)
                }
            }
        }
    }
}

// MARK: - Product Card
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
                
                // Price will be shown in detail view since it varies by size
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

// MARK: - Product Detail View
struct SupabaseProductDetailView: View {
    @StateObject private var viewModel: SupabaseProductDetailViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showingCheckout = false
    
    init(product: DBProduct) {
        _viewModel = StateObject(wrappedValue: SupabaseProductDetailViewModel(product: product))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Image Gallery
                    TabView {
                        ForEach(viewModel.product.imageArray.isEmpty ? [""] : viewModel.product.imageArray, id: \.self) { imageURL in
                            if !imageURL.isEmpty, let url = URL(string: imageURL) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } placeholder: {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.1))
                                        .overlay(ProgressView())
                                }
                            } else {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.1))
                                    .overlay(
                                        Image(systemName: "photo")
                                            .font(.system(size: 60))
                                            .foregroundColor(.gray.opacity(0.5))
                                    )
                            }
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .frame(height: 400)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Product Info
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Spacer()
                                
                                if viewModel.product.is_new {
                                    Text("NEW")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.green)
                                        .cornerRadius(4)
                                }
                                
                                if viewModel.product.is_featured {
                                    Text("FEATURED")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(AppConstants.Colors.primaryRed)
                                        .cornerRadius(4)
                                }
                            }
                            
                            Text(viewModel.product.name)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text(viewModel.product.description)
                                .font(.system(size: 16))
                                .foregroundColor(.black.opacity(0.8))
                        }
                        
                        Divider()
                        
                        // Size Selection
                        if viewModel.isLoadingSizes {
                            HStack {
                                ProgressView()
                                Text("Loading sizes...")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            .padding()
                        } else if !viewModel.productSizes.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Select Size")
                                    .font(.system(size: 16, weight: .semibold))
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                                    ForEach(viewModel.productSizes, id: \.id) { size in
                                        Button(action: {
                                            viewModel.selectedSize = size
                                        }) {
                                            VStack(spacing: 4) {
                                                Text(size.displayName)
                                                    .font(.system(size: 14, weight: .medium))
                                                Text(size.formattedPrice)
                                                    .font(.system(size: 12))
                                            }
                                            .foregroundColor(viewModel.selectedSize?.id == size.id ? .white : .black)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(
                                                viewModel.selectedSize?.id == size.id ?
                                                AppConstants.Colors.primaryRed : Color(UIColor.systemGray5)
                                            )
                                            .cornerRadius(8)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Price Display
                        if let selectedSize = viewModel.selectedSize {
                            HStack {
                                Text("Price:")
                                    .font(.system(size: 18))
                                Text(viewModel.formattedPrice)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(AppConstants.Colors.primaryRed)
                            }
                        }
                        
                        // Quantity Selector
                        HStack {
                            Text("Quantity")
                                .font(.system(size: 16, weight: .semibold))
                            
                            Spacer()
                            
                            HStack(spacing: 16) {
                                Button(action: viewModel.decrementQuantity) {
                                    Image(systemName: "minus.circle")
                                        .font(.system(size: 24))
                                        .foregroundColor(viewModel.quantity > 1 ? .black : .gray)
                                }
                                .disabled(viewModel.quantity <= 1)
                                
                                Text("\(viewModel.quantity)")
                                    .font(.system(size: 18, weight: .semibold))
                                    .frame(width: 40)
                                
                                Button(action: viewModel.incrementQuantity) {
                                    Image(systemName: "plus.circle")
                                        .font(.system(size: 24))
                                        .foregroundColor(viewModel.quantity < 10 ? .black : .gray)
                                }
                                .disabled(viewModel.quantity >= 10)
                            }
                        }
                        
                        // Total Price
                        if viewModel.selectedSize != nil {
                            HStack {
                                Text("Total:")
                                    .font(.system(size: 18, weight: .semibold))
                                Spacer()
                                Text(viewModel.formattedTotalPrice)
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(AppConstants.Colors.primaryRed)
                            }
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                        }
                        
                        // Checkout Button
                        Button(action: {
                            viewModel.openStripeCheckout()
                        }) {
                            HStack {
                                Image(systemName: "creditcard")
                                Text("Checkout with Stripe")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                viewModel.canAddToCart ?
                                AppConstants.Colors.primaryRed : Color.gray
                            )
                            .cornerRadius(12)
                        }
                        .disabled(!viewModel.canAddToCart)
                        
                        // Error Message
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
struct SupabaseMerchandiseView_Previews: PreviewProvider {
    static var previews: some View {
        SupabaseMerchandiseView()
    }
}
