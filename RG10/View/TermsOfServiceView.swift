//
//  TermsOfServiceView.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/8/25.
//

import SwiftUI

struct TermsOfServiceView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Terms of Service")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("Last updated: January 2025")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 8)
                
                // Sections
                TermsSection(
                    title: "1. Acceptance of Terms",
                    content: "By accessing and using the RG10 Football app and services, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use our services."
                )
                
                TermsSection(
                    title: "2. Description of Services",
                    content: "RG10 Football provides football training services including:\n• Private and group training sessions\n• Online training videos and content\n• Booking and scheduling platform\n• Merchandise sales\n• Camp and clinic registrations"
                )
                
                TermsSection(
                    title: "3. User Registration",
                    content: "To access certain features, you must register for an account. You agree to:\n• Provide accurate and complete information\n• Maintain the security of your password\n• Notify us of any unauthorized use\n• Be responsible for all activities under your account"
                )
                
                TermsSection(
                    title: "4. Booking and Cancellation Policy",
                    content: "• Sessions must be booked at least 24 hours in advance\n• Cancellations must be made at least 24 hours before the session\n• Late cancellations may result in forfeiture of payment\n• Group sessions require minimum attendance to proceed\n• We reserve the right to cancel sessions due to weather or other circumstances"
                )
                
                TermsSection(
                    title: "5. Payment Terms",
                    content: "• All payments are processed securely through Stripe\n• Prices are in USD and subject to change\n• Refunds are subject to our cancellation policy\n• Premium subscriptions auto-renew unless cancelled\n• You are responsible for all applicable taxes"
                )
                
                TermsSection(
                    title: "6. Code of Conduct",
                    content: "Users agree to:\n• Treat coaches and other participants with respect\n• Follow safety guidelines and instructions\n• Arrive on time for scheduled sessions\n• Wear appropriate athletic attire\n• Not engage in harmful or disruptive behavior"
                )
                
                TermsSection(
                    title: "7. Intellectual Property",
                    content: "All content, including videos, images, logos, and training materials, are the property of RG10 Football. Users may not reproduce, distribute, or create derivative works without express written permission."
                )
                
                TermsSection(
                    title: "8. Assumption of Risk",
                    content: "Participation in football training involves inherent risks. By using our services, you acknowledge these risks and agree to participate at your own risk. We recommend consulting with a physician before beginning any training program."
                )
                
                TermsSection(
                    title: "9. Limitation of Liability",
                    content: "RG10 Football and its coaches shall not be liable for any direct, indirect, incidental, or consequential damages arising from the use of our services, except where prohibited by law."
                )
                
                TermsSection(
                    title: "10. Privacy",
                    content: "Your use of our services is also governed by our Privacy Policy. Please review our Privacy Policy to understand our practices."
                )
                
                TermsSection(
                    title: "11. Modifications",
                    content: "We reserve the right to modify these terms at any time. Continued use of the services after changes constitutes acceptance of the modified terms."
                )
                
                TermsSection(
                    title: "12. Governing Law",
                    content: "These terms shall be governed by the laws of the State of North Carolina, without regard to its conflict of law provisions."
                )
                
                TermsSection(
                    title: "13. Contact Information",
                    content: "For questions about these Terms of Service, please contact us at:\n\nRG10 Football\nEmail: legal@rg10football.com\nPhone: (555) 123-4567"
                )
                
                // Footer
                VStack(spacing: 16) {
                    Divider()
                    
                    Text("By using RG10 Football, you acknowledge that you have read, understood, and agree to be bound by these Terms of Service.")
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
                .foregroundColor(AppConstants.Colors.primaryRed)
            }
        }
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
