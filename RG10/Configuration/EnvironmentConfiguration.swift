//
//  EnvironmentConfiguration.swift
//  RG10
//
//  Created by Security Enhancement on 10/21/25.
//

import Foundation

// MARK: - Environment Configuration Manager
/// Centralized configuration management for different environments
/// Uses environment variables for sensitive data in CI/CD pipelines
class EnvironmentConfiguration {
    
    // MARK: - Environment Detection
    static var currentEnvironment: AppEnvironment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }
    
    // MARK: - Configuration Properties
    
    /// Stripe publishable key from environment or fallback
    static var stripePublishableKey: String {
        return getEnvironmentVariable(
            key: "STRIPE_PUBLISHABLE_KEY",
            fallback: currentEnvironment == .development ? 
                "pk_test_51S4YTJ2MsIjS8n0Frb5RizsyuEFmk2fq9zoo9qRdSxlEuaf0aQYsxY2Ge3JVKX7DND2mv4di6ZOAnqF7yvlA4rr100tYxyjIkS" : 
                "pk_live_YOUR_PRODUCTION_KEY_HERE"
        )
    }
    
    /// Supabase URL from environment or fallback
    static var supabaseURL: String {
        return getEnvironmentVariable(
            key: "SUPABASE_URL",
            fallback: "https://uwssjvqlsekveqvdkdnj.supabase.co"
        )
    }
    
    /// Supabase anonymous key from environment or fallback
    static var supabaseAnonKey: String {
        return getEnvironmentVariable(
            key: "SUPABASE_ANON_KEY",
            fallback: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV3c3NqdnFsc2VrdmVxdmRrZG5qIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcyMTU5OTksImV4cCI6MjA3Mjc5MTk5OX0.HG6t79U5z8w_f0Qfwgclkxs4aZOfgALbMEwXN9ZTA00"
        )
    }
    
    /// YouTube API key from environment or fallback
    static var youtubeAPIKey: String {
        return getEnvironmentVariable(
            key: "YOUTUBE_API_KEY",
            fallback: "AIzaSyC9PEMSZulrgO3hnMYqUbAKtfsM7jWAuYM"
        )
    }
    
    /// Merchant display name
    static var merchantDisplayName: String {
        return "RG10 Football"
    }
    
    /// App scheme for deep linking
    static var appScheme: String {
        return "rg10"
    }
    
    // MARK: - Helper Methods
    
    /// Gets environment variable with fallback
    private static func getEnvironmentVariable(key: String, fallback: String) -> String {
        // First try ProcessInfo environment variables (for Xcode Cloud)
        if let envValue = ProcessInfo.processInfo.environment[key], !envValue.isEmpty {
            return envValue
        }
        
        // Then try Bundle info (for manual configuration)
        if let bundleValue = Bundle.main.infoDictionary?[key] as? String, !bundleValue.isEmpty {
            return bundleValue
        }
        
        // Finally use fallback
        return fallback
    }
    
    // MARK: - Validation
    
    /// Validates that all required configuration is present
    static var isValid: Bool {
        return !stripePublishableKey.isEmpty &&
               !supabaseURL.isEmpty &&
               !supabaseAnonKey.isEmpty &&
               !youtubeAPIKey.isEmpty &&
               !merchantDisplayName.isEmpty
    }
    
    /// Returns validation errors if any
    static var validationErrors: [String] {
        var errors: [String] = []
        
        if stripePublishableKey.isEmpty || stripePublishableKey.contains("YOUR_") {
            errors.append("Stripe publishable key is not configured")
        }
        
        if supabaseURL.isEmpty {
            errors.append("Supabase URL is not configured")
        }
        
        if supabaseAnonKey.isEmpty {
            errors.append("Supabase anon key is not configured")
        }
        
        if youtubeAPIKey.isEmpty || youtubeAPIKey.contains("YOUR_") {
            errors.append("YouTube API key is not configured")
        }
        
        if merchantDisplayName.isEmpty {
            errors.append("Merchant display name is not configured")
        }
        
        return errors
    }
    
    /// Debug information about configuration sources
    static var debugInfo: String {
        var info = "Environment Configuration Debug Info:\n"
        info += "Current Environment: \(currentEnvironment.rawValue)\n"
        info += "Stripe Key Source: \(getSourceDescription(for: "STRIPE_PUBLISHABLE_KEY"))\n"
        info += "Supabase URL Source: \(getSourceDescription(for: "SUPABASE_URL"))\n"
        info += "Supabase Key Source: \(getSourceDescription(for: "SUPABASE_ANON_KEY"))\n"
        info += "YouTube Key Source: \(getSourceDescription(for: "YOUTUBE_API_KEY"))\n"
        return info
    }
    
    private static func getSourceDescription(for key: String) -> String {
        if ProcessInfo.processInfo.environment[key] != nil {
            return "Environment Variable"
        } else if Bundle.main.infoDictionary?[key] != nil {
            return "Bundle Info"
        } else {
            return "Fallback Value"
        }
    }
}

// MARK: - Environment Enum
enum AppEnvironment: String, CaseIterable {
    case development = "development"
    case staging = "staging"
    case production = "production"
    
    var displayName: String {
        switch self {
        case .development:
            return "Development"
        case .staging:
            return "Staging"
        case .production:
            return "Production"
        }
    }
}

// MARK: - Configuration Setup Instructions
/*
 XCODE CLOUD CI/CD SETUP INSTRUCTIONS:
 
 1. Environment Variables in Xcode Cloud:
    - Go to your Xcode Cloud project settings
    - Navigate to "Environment Variables" section
    - Add the following variables:
 
    Required Variables:
    - STRIPE_PUBLISHABLE_KEY: Your Stripe publishable key (pk_test_ or pk_live_)
    - SUPABASE_URL: Your Supabase project URL
    - SUPABASE_ANON_KEY: Your Supabase anonymous key
    - YOUTUBE_API_KEY: Your YouTube Data API v3 key
 
    Optional Variables:
    - APP_ENVIRONMENT: development/staging/production (auto-detected if not set)
 
 2. Local Development Setup:
    - Create a Config.xcconfig file (see Config.xcconfig.example)
    - Add your keys to the xcconfig file
    - Never commit the actual Config.xcconfig file to version control
    - Use Config.xcconfig.example as a template
 
 3. Security Best Practices:
    - Never commit API keys to version control
    - Use different keys for different environments
    - Rotate keys regularly
    - Monitor API usage and set up alerts
    - Use API key restrictions where possible
 
 4. Production Deployment:
    - Use production keys in Xcode Cloud environment variables
    - Test thoroughly in staging environment first
    - Monitor logs for any configuration issues
    - Set up proper error handling for missing configuration
 */
