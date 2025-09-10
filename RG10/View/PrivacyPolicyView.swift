//
//  PrivacyPolicyView.swift
//  RG10
//
//  Privacy Policy page for RG10 Football
//

import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Privacy Policy")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("Effective Date: January 2025")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Text("Your privacy is important to us")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppConstants.Colors.primaryRed)
                        .padding(.top, 4)
                }
                .padding(.bottom, 8)
                
                // Sections
                PrivacySection(
                    title: "1. Information We Collect",
                    content: "We may collect the following types of information:\n• Personal Information (if provided): Name, email address, account login details.\n• Usage Data: How you interact with the app, training sessions, features used.\n• Device Information: Device type, operating system, app version.\n• Payment Information: If you purchase subscriptions, payments are handled by Apple App Store or Google Play. We do not store your payment details.",
                    icon: "doc.text.fill"
                )
                
                PrivacySection(
                    title: "2. How We Use Your Information",
                    content: "We use your information to:\n• Provide and improve the app's features.\n• Personalize your training experience.\n• Send important updates (e.g., changes to Terms or app features).\n• Respond to support requests.",
                    icon: "gear.badge.checkmark"
                )
                
                PrivacySection(
                    title: "3. Sharing of Information",
                    content: "• We do not sell or rent your personal information.\n• We may share data with trusted third-party service providers (e.g., analytics, crash reports, payment processors) to help improve our services.\n• We may disclose information if required by law.",
                    icon: "person.2.fill"
                )
                
                PrivacySection(
                    title: "4. Data Security",
                    content: "• We take reasonable steps to protect your information from unauthorized access or misuse.\n• However, no system is 100% secure, and we cannot guarantee absolute security.",
                    icon: "lock.shield.fill"
                )
                
                PrivacySection(
                    title: "5. Children's Privacy",
                    content: "• The RG10 App is not directed to children under 13 years old.\n• We do not knowingly collect information from children under 13. If we learn that we have, we will delete it promptly.",
                    icon: "figure.2.and.child.holdinghands"
                )
                
                PrivacySection(
                    title: "6. Your Rights",
                    content: "Depending on your location, you may have rights such as:\n• Accessing or updating your information.\n• Requesting deletion of your data.\n• Opting out of marketing communications.\n\nTo exercise your rights, contact us at info@rg10football.com.",
                    icon: "person.badge.shield.checkmark.fill"
                )
                
                PrivacySection(
                    title: "7. Changes to This Policy",
                    content: "We may update this Privacy Policy from time to time. We will notify you by updating the \"Effective Date\" at the top of this page.",
                    icon: "arrow.triangle.2.circlepath"
                )
                
                PrivacySection(
                    title: "8. Contact Us",
                    content: "If you have questions about this Privacy Policy, contact us at:",
                    icon: "envelope.fill"
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
                    
                    Text("© 2025 RG10 Football. All rights reserved.")
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
        .navigationTitle("Privacy Policy")
        .toolbar(.hidden, for: .tabBar)
    }
}

struct PrivacySection: View {
    let title: String
    let content: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(AppConstants.Colors.primaryRed)
                    .frame(width: 28)
                
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
            }
            
            Text(content)
                .font(.system(size: 14))
                .foregroundColor(.black.opacity(0.8))
                .lineSpacing(4)
                .padding(.leading, 40)
        }
    }
}
