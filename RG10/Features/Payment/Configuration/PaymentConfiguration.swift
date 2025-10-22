//
//  PaymentConfiguration.swift
//  RG10
//
//  Created by Moneeb Sayed on 1/17/25.
//

import Foundation

// MARK: - Payment Configuration

struct PaymentConfiguration {
    
    // MARK: - Configuration Properties (Now using EnvironmentConfiguration)
    
    /// Stripe publishable key for your app
    /// Now sourced from environment variables for better security
    static var stripePublishableKey: String {
        return EnvironmentConfiguration.stripePublishableKey
    }
    
    /// Stripe secret key (for server-side operations only)
    /// This should NEVER be included in your iOS app
    /// Keep this on your server/backend only
    // static let stripeSecretKey = "REMOVED_FOR_SECURITY"
    
    // MARK: - Supabase Configuration
    
    /// Supabase URL for your project
    static var supabaseURL: String {
        return EnvironmentConfiguration.supabaseURL
    }
    
    /// Supabase anon key
    static var supabaseAnonKey: String {
        return EnvironmentConfiguration.supabaseAnonKey
    }
    
    // MARK: - App Configuration
    
    /// Merchant display name for Stripe
    static var merchantDisplayName: String {
        return EnvironmentConfiguration.merchantDisplayName
    }
    
    /// App scheme for deep linking
    static var appScheme: String {
        return EnvironmentConfiguration.appScheme
    }
    
    // MARK: - Validation
    
    /// Validates that all required configuration is present
    static var isValid: Bool {
        return EnvironmentConfiguration.isValid
    }
    
    /// Returns validation errors if any
    static var validationErrors: [String] {
        return EnvironmentConfiguration.validationErrors
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
        return stripePublishableKey
    }
}

// MARK: - Setup Instructions

/*
 SECURITY ENHANCED SETUP INSTRUCTIONS:
 
 1. Environment Configuration:
    - Use EnvironmentConfiguration.swift for all API keys
    - Keys are now sourced from environment variables or Bundle info
    - See Config.xcconfig.example for local development setup
 
 2. Xcode Cloud CI/CD Setup:
    - Add environment variables in Xcode Cloud project settings:
      * STRIPE_PUBLISHABLE_KEY
      * SUPABASE_URL  
      * SUPABASE_ANON_KEY
      * YOUTUBE_API_KEY
    - Never commit actual keys to version control
 
 3. Local Development:
    - Copy Config.xcconfig.example to Config.xcconfig
    - Add your actual keys to Config.xcconfig
    - Add Config.xcconfig to .gitignore
    - Use different keys for different environments
 
 4. Security Best Practices:
    - Rotate API keys regularly
    - Monitor API usage and set up alerts
    - Use API key restrictions where possible
    - Validate all payment responses on your server
    - Never put secret keys in client applications
 
 5. Supabase Edge Functions:
    - Make sure your Supabase project has the required edge functions
    - Functions should handle all sensitive operations server-side
    - Use proper error handling and validation
 */



