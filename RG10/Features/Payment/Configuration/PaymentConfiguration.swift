//
//  PaymentConfiguration.swift
//  RG10
//
//  Created by Moneeb Sayed on 1/17/25.
//

import Foundation

// MARK: - Payment Configuration

struct PaymentConfiguration {
    
    // MARK: - Stripe Keys
    
    /// Stripe publishable key for your app
    /// TODO: Replace with your actual Stripe publishable key
    /// Get this from your Stripe Dashboard: https://dashboard.stripe.com/apikeys
    static let stripePublishableKey = "pk_test_51S4YTJ2MsIjS8n0Frb5RizsyuEFmk2fq9zoo9qRdSxlEuaf0aQYsxY2Ge3JVKX7DND2mv4di6ZOAnqF7yvlA4rr100tYxyjIkS" // Test key for development
    
    /// Stripe secret key (for server-side operations only)
    /// This should NEVER be included in your iOS app
    /// Keep this on your server/backend only
    // static let stripeSecretKey = "REMOVED_FOR_SECURITY"
    
    // MARK: - Supabase Configuration
    
    /// Supabase URL for your project
    static let supabaseURL = "https://uwssjvqlsekveqvdkdnj.supabase.co"
    
    /// Supabase anon key
    static let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV3c3NqdnFsc2VrdmVxdmRrZG5qIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcyMTU5OTksImV4cCI6MjA3Mjc5MTk5OX0.HG6t79U5z8w_f0Qfwgclkxs4aZOfgALbMEwXN9ZTA00"
    
    // MARK: - App Configuration
    
    /// Merchant display name for Stripe
    static let merchantDisplayName = "RG10 Football"
    
    /// App scheme for deep linking
    static let appScheme = "rg10"
    
    // MARK: - Validation
    
    /// Validates that all required configuration is present
    static var isValid: Bool {
        return !stripePublishableKey.isEmpty &&
               !supabaseURL.isEmpty &&
               !supabaseAnonKey.isEmpty &&
               !merchantDisplayName.isEmpty
    }
    
    /// Returns validation errors if any
    static var validationErrors: [String] {
        var errors: [String] = []
        
        if stripePublishableKey.isEmpty || stripePublishableKey.contains("your_publishable_key_here") {
            errors.append("Stripe publishable key is not configured")
        }
        
        if supabaseURL.isEmpty {
            errors.append("Supabase URL is not configured")
        }
        
        if supabaseAnonKey.isEmpty {
            errors.append("Supabase anon key is not configured")
        }
        
        if merchantDisplayName.isEmpty {
            errors.append("Merchant display name is not configured")
        }
        
        return errors
    }
}

// MARK: - Environment Configuration

extension PaymentConfiguration {
    
    /// Determines if we're in development mode
    static var isDevelopment: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    /// Determines if we're in production mode
    static var isProduction: Bool {
        return !isDevelopment
    }
    
    /// Gets the appropriate Stripe key based on environment
    static var currentStripeKey: String {
        if isDevelopment {
            return stripePublishableKey
        } else {
            // In production, you might want to use a different key
            return stripePublishableKey
        }
    }
}

// MARK: - Setup Instructions

/*
 SETUP INSTRUCTIONS:
 
 1. Stripe Configuration:
    - Go to https://dashboard.stripe.com/apikeys
    - Copy your publishable key (starts with pk_test_ or pk_live_)
    - Replace the stripePublishableKey value above
    - NEVER put your secret key (sk_test_ or sk_live_) in your iOS app
 
 2. Supabase Configuration:
    - Your Supabase URL and anon key are already configured
    - Make sure your Supabase project has the required edge functions:
      - payments-create-booking-intent
      - billing-create-subscription-session
      - cancel-subscription
      - cancel-booking
      - abort-subscription-intent
      - get-bookings
 
 3. Edge Functions Setup:
    - Each edge function should handle the appropriate payment logic
    - Functions should return the expected response models
    - Make sure to handle errors gracefully
 
 4. Testing:
    - Use Stripe test mode for development
    - Test with Stripe test card numbers
    - Switch to live mode only for production
 
 5. Security:
    - Never commit secret keys to version control
    - Use environment variables or secure configuration for production
    - Validate all payment responses on your server
 */



