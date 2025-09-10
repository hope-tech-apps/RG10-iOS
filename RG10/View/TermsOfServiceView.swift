//
//  TermsOfServiceView.swift
//  RG10
//
//  Terms of Service page for RG10 Football
//

import SwiftUI

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Terms and Conditions")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("Effective Date: January 2025")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Text("Welcome to RG10 App")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppConstants.Colors.primaryRed)
                        .padding(.top, 4)
                }
                .padding(.bottom, 8)
                
                // Introduction
                Text("By accessing or using our app, you agree to be bound by these Terms and Conditions. If you do not agree, please do not use the app.")
                    .font(.system(size: 14))
                    .foregroundColor(.black.opacity(0.8))
                    .padding(.bottom, 8)
                
                // Sections
                TermsSection(
                    title: "1. Use of the App",
                    content: "• You must be at least 13 years old to use this app.\n• You agree to use the app only for lawful purposes and in accordance with these Terms.\n• You are responsible for maintaining the confidentiality of your account login details."
                )
                
                TermsSection(
                    title: "2. Services Provided",
                    content: "• RG10 App provides football (soccer) training resources, tutorials, and related services.\n• We reserve the right to modify, suspend, or discontinue any features of the app at any time without notice."
                )
                
                TermsSection(
                    title: "3. Subscriptions & Payments",
                    content: "• Some features may require a paid subscription.\n• All payments are processed securely by third-party providers (e.g., Apple App Store, Google Play).\n• Subscriptions automatically renew unless canceled in your account settings."
                )
                
                TermsSection(
                    title: "4. User Content",
                    content: "• If you submit content (e.g., comments, videos, feedback), you grant RG10 App a worldwide, non-exclusive, royalty-free license to use, display, and distribute it within the app.\n• You must not upload content that is illegal, offensive, or infringes on others' rights."
                )
                
                TermsSection(
                    title: "5. Intellectual Property",
                    content: "• All materials in the app (logos, videos, tutorials, branding, etc.) are owned by RG10 Football unless otherwise stated.\n• You may not copy, distribute, or modify any content without prior written consent."
                )
                
                TermsSection(
                    title: "6. Privacy",
                    content: "Your privacy is important to us. Please see our Privacy Policy for details on how we handle your information."
                )
                
                TermsSection(
                    title: "7. Limitation of Liability",
                    content: "• RG10 App is provided \"as is\" without guarantees.\n• We are not responsible for injuries, losses, or damages that may occur from following training methods or using the app. Always consult with a professional before engaging in physical activity."
                )
                
                TermsSection(
                    title: "8. Termination",
                    content: "• We may suspend or terminate your account if you violate these Terms.\n• You may stop using the app at any time by deleting your account."
                )
                
                TermsSection(
                    title: "9. Governing Law",
                    content: "These Terms shall be governed by the laws of the State of North Carolina. Any disputes shall be handled in the courts of North Carolina."
                )
                
                TermsSection(
                    title: "10. Contact",
                    content: "If you have questions about these Terms, please contact us at:"
                )
                
                // Contact Card
                VStack(alignment: .leading, spacing: 8) {
                    Text("RG10 Football")
                        .font(.system(size: 16, weight: .semibold))
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(AppConstants.Colors.primaryRed)
                        Text("info@rg10football.com")
                            .font(.system(size: 14))
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppConstants.Colors.primaryRed.opacity(0.1))
                .cornerRadius(12)
                
                // Footer
                VStack(spacing: 16) {
                    Divider()
                    
                    Text("By using RG10 Football, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions.")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
            }
            .padding()
        }
        .background(Color(UIColor.systemGray6))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Terms of Service")
        .toolbar(.hidden, for: .tabBar)
    }
}

struct TermsSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
            
            Text(content)
                .font(.system(size: 14))
                .foregroundColor(.black.opacity(0.8))
                .lineSpacing(4)
        }
    }
}
