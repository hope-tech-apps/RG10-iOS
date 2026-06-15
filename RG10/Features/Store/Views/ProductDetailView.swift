//
//  ProductDetailView.swift
//  RG10
//
//  Native product detail for the live Flite Sports Shopify store. Replaces the
//  old "tap product → open web page" behavior with an in-app gallery, size /
//  variant picker, quantity stepper, and "Add to Bag" that feeds CartStore.
//
//  Products with more than one option dimension can't be resolved to a single
//  variant in-app, so they fall back to the web product page in StoreWebView.
//

import SwiftUI

struct ProductDetailView: View {
    let product: ShopifyProduct

    @EnvironmentObject private var cartStore: CartStore
    @EnvironmentObject private var navigationManager: NavigationManager

    @State private var selectedOptionValue: String?
    @State private var quantity: Int = 1
    @State private var showAddedConfirmation = false
    @State private var webDestination: StoreBrowserDestination?

    private let galleryHeight: CGFloat = 360

    /// The variant matching the current selection, if resolvable and available.
    private var selectedVariant: ShopifyVariant? {
        product.variant(forOptionValue: selectedOptionValue)
    }

    private var canAddToBag: Bool {
        guard let variant = selectedVariant else { return false }
        return variant.available
    }

    var body: some View {
        Group {
            if product.isNativelyPurchasable {
                nativeDetail
            } else {
                multiOptionFallback
            }
        }
        .navigationTitle(product.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                CartButton {
                    navigationManager.navigate(to: .cart, in: navigationManager.selectedTab)
                }
            }
        }
        .sheet(item: $webDestination) { destination in
            StoreWebView(
                url: destination.url,
                title: "Flite Sports",
                onDismiss: { webDestination = nil }
            )
        }
        .onAppear(perform: preselectDefaultVariant)
    }

    // MARK: - Native Detail

    private var nativeDetail: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                gallery

                VStack(alignment: .leading, spacing: 12) {
                    Text(product.title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.black)

                    priceLabel

                    if let option = product.primaryOption, !option.values.isEmpty {
                        variantSelector(option: option)
                    }

                    quantityStepper

                    addToBagButton

                    if !descriptionText.isEmpty {
                        Divider()
                            .padding(.vertical, 4)
                        Text("Description")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                        Text(descriptionText)
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
        }
        .background(Color.white)
        .overlay(alignment: .bottom) {
            if showAddedConfirmation {
                addedToast
            }
        }
    }

    private var gallery: some View {
        Group {
            let urls = product.imageURLs
            if urls.isEmpty {
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: galleryHeight)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 50))
                            .foregroundColor(.gray.opacity(0.5))
                    )
            } else if urls.count == 1 {
                DownsampledAsyncImage(
                    url: urls[0],
                    targetSize: CGSize(width: 600, height: 600),
                    contentMode: .fit
                )
                .frame(height: galleryHeight)
                .frame(maxWidth: .infinity)
            } else {
                TabView {
                    ForEach(urls, id: \.absoluteString) { url in
                        DownsampledAsyncImage(
                            url: url,
                            targetSize: CGSize(width: 600, height: 600),
                            contentMode: .fit
                        )
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: galleryHeight)
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
            }
        }
        .background(Color(UIColor.systemGray6))
    }

    private var priceLabel: some View {
        Group {
            if let variant = selectedVariant {
                Text(variant.displayPrice)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppConstants.Colors.primaryRed)
            } else if !product.displayPrice.isEmpty {
                Text(product.displayPrice)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppConstants.Colors.primaryRed)
            }
        }
    }

    private func variantSelector(option: ShopifyOption) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(option.name)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: 8)], spacing: 8) {
                ForEach(option.values, id: \.self) { value in
                    let variant = product.variant(forOptionValue: value)
                    let isAvailable = variant?.available ?? false
                    let isSelected = selectedOptionValue == value

                    Button(action: {
                        if isAvailable { selectedOptionValue = value }
                    }) {
                        Text(isAvailable ? value : "\(value) — Sold out")
                            .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                            .multilineTextAlignment(.center)
                            .foregroundColor(swatchForeground(isSelected: isSelected, isAvailable: isAvailable))
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .padding(.horizontal, 6)
                            .background(swatchBackground(isSelected: isSelected, isAvailable: isAvailable))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        isSelected ? AppConstants.Colors.primaryRed : Color.gray.opacity(0.4),
                                        lineWidth: isSelected ? 2 : 1
                                    )
                            )
                            .cornerRadius(8)
                    }
                    .disabled(!isAvailable)
                }
            }
        }
    }

    private func swatchForeground(isSelected: Bool, isAvailable: Bool) -> Color {
        if !isAvailable { return .gray.opacity(0.5) }
        return isSelected ? .white : .black
    }

    private func swatchBackground(isSelected: Bool, isAvailable: Bool) -> Color {
        if !isAvailable { return Color.gray.opacity(0.1) }
        return isSelected ? AppConstants.Colors.primaryRed : Color.white
    }

    private var quantityStepper: some View {
        HStack(spacing: 16) {
            Text("Quantity")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black)

            Spacer()

            HStack(spacing: 0) {
                Button(action: { if quantity > 1 { quantity -= 1 } }) {
                    Image(systemName: "minus")
                        .frame(width: 40, height: 40)
                        .foregroundColor(quantity > 1 ? AppConstants.Colors.primaryRed : .gray.opacity(0.4))
                }
                .disabled(quantity <= 1)

                Text("\(quantity)")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(minWidth: 36)

                Button(action: { quantity += 1 }) {
                    Image(systemName: "plus")
                        .frame(width: 40, height: 40)
                        .foregroundColor(AppConstants.Colors.primaryRed)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }

    private var addToBagButton: some View {
        Button(action: addToBag) {
            HStack {
                Image(systemName: "bag.badge.plus")
                Text(canAddToBag ? "Add to Bag" : "Select a size")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(canAddToBag ? AppConstants.Colors.primaryRed : Color.gray.opacity(0.4))
            .cornerRadius(10)
        }
        .disabled(!canAddToBag)
        .padding(.top, 4)
    }

    private var addedToast: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
            Text("Added to your bag")
                .font(.system(size: 15, weight: .semibold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.85))
        .cornerRadius(24)
        .padding(.bottom, 24)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Multi-option Fallback

    private var multiOptionFallback: some View {
        VStack(spacing: 20) {
            gallery

            Text(product.title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text("This product has multiple options. Open the product page to choose and add it to your bag.")
                .font(.system(size: 15))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: openWebProduct) {
                HStack {
                    Image(systemName: "safari")
                    Text("View on Flite Sports")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(AppConstants.Colors.primaryRed)
                .cornerRadius(10)
            }

            Spacer()
        }
        .padding(.top, 12)
        .background(Color.white)
    }

    // MARK: - Actions

    private var descriptionText: String {
        HTMLText.plainText(from: product.bodyHTML)
    }

    private func preselectDefaultVariant() {
        guard product.isNativelyPurchasable, selectedOptionValue == nil else { return }
        if product.options.isEmpty {
            // Option-less product: the lone variant is implicitly selected.
            return
        }
        // Preselect the first available size so "Add to Bag" is reachable.
        if let option = product.primaryOption,
           let firstAvailable = option.values.first(where: { value in
               product.variant(forOptionValue: value)?.available ?? false
           }) {
            selectedOptionValue = firstAvailable
        }
    }

    private func addToBag() {
        guard let variant = selectedVariant, variant.available else { return }
        cartStore.add(product: product, variant: variant, quantity: quantity)
        withAnimation(.easeInOut(duration: 0.25)) {
            showAddedConfirmation = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.easeInOut(duration: 0.25)) {
                showAddedConfirmation = false
            }
        }
    }

    private func openWebProduct() {
        guard let url = product.webURL else { return }
        webDestination = StoreBrowserDestination(url: url)
    }
}
