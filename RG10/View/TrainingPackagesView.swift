//
//  TrainingPackagesView.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/4/25.
//


import SwiftUI

struct TrainingPackagesView: View {
    @StateObject private var viewModel = TrainingPackagesViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Training Packages")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(AppConstants.Colors.primaryRed)
                        
                        Text("Pricing starts at $85/hr for a single session but take advantage of our monthly packages which come at a lower rate below.")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .italic()
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    
                    // Packages Section
                    VStack(spacing: 16) {
                        ForEach(viewModel.packages) { package in
                            PackageCard(
                                package: package,
                                isExpanded: viewModel.expandedPackage == package.id,
                                onTap: {
                                    viewModel.togglePackage(package.id)
                                },
                                onBook: {
                                    viewModel.bookPackage(package)
                                }
                            )
                        }
                    }
                    .padding()
                    
                    // Bottom CTA Section
                    VStack(spacing: 20) {
                        Text("Ready to elevate your game?")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                        
                        Button(action: viewModel.signUpNow) {
                            Text("Sign Up Now")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(AppConstants.Colors.primaryRed)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        Text("Have questions? Contact us at info@rg10football.com")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 40)
                    .background(Color(UIColor.systemGray6))
                }
            }
        }
    }
}

// MARK: - Package Card Component
struct PackageCard: View {
    let package: TrainingPackage
    let isExpanded: Bool
    let onTap: () -> Void
    let onBook: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onTap) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(package.title)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(package.subtitle)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text(package.price)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(20)
                .background(
                    LinearGradient(
                        colors: [package.color, package.color.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    DetailRow(icon: "calendar", title: "Sessions", description: package.sessions)
                    Divider()
                    DetailRow(icon: "target", title: "Focus", description: package.focus)
                    Divider()
                    DetailRow(icon: "clock", title: "Duration", description: package.duration)
                    Divider()
                    DetailRow(icon: "person.fill", title: "Ideal For", description: package.idealFor)
                    
                    Button(action: onBook) {
                        Text("Book This Package")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(package.color)
                            .cornerRadius(8)
                    }
                    .padding(.top, 8)
                }
                .padding(20)
                .background(Color.white)
                .transition(.asymmetric(
                    insertion: .push(from: .top).combined(with: .opacity),
                    removal: .push(from: .bottom).combined(with: .opacity)
                ))
            }
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Detail Row Component
struct DetailRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
                
                Text(description)
                    .font(.system(size: 15))
                    .foregroundColor(.black)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
}

struct TrainingPackage: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let price: String
    let sessions: String
    let focus: String
    let duration: String
    let idealFor: String
    let color: Color
}

// MARK: - Preview
struct TrainingPackagesView_Previews: PreviewProvider {
    static var previews: some View {
        TrainingPackagesView()
    }
}
