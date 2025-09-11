//
//  MerchandiseDetailView.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/10/25.
//

import SwiftUI

struct MerchandiseDetailView: View {
    let product: Merchandise
    @StateObject private var viewModel: MerchandiseDetailViewModel
    @State private var showingStripeError = false
    
    init(product: Merchandise) {
        self.product = product
        self._viewModel = StateObject(wrappedValue: MerchandiseDetailViewModel(product: product))
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
