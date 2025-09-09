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
                    
                    Text("Last updated: January 2025")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Text("Your privacy is important to us")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppConstants.Colors.primaryRed)
                        .padding(.top, 4)
                }
                .padding(.bottom, 8)
                
                // ... rest of your content remains the same ...
            }
            .padding()
        }
        .background(Color(UIColor.systemGray6))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Privacy Policy") // Add navigation title
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
