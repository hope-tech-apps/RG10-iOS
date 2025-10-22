//
//  DebugConfiguration.swift
//  RG10
//
//  Created for debugging Xcode Cloud issues
//

import Foundation

// MARK: - Debug Configuration Helper
/// Helper to debug Xcode Cloud configuration issues
class DebugConfiguration {
    
    /// Print all configuration information for debugging
    static func printConfigurationDebugInfo() {
        print("🔍 Configuration Debug Info:")
        print("================================")
        
        // Environment detection
        print("Current Environment: \(EnvironmentConfiguration.currentEnvironment.rawValue)")
        
        // Configuration sources
        print("Configuration Sources:")
        print("- Stripe Key Source: \(getSourceDescription(for: "STRIPE_PUBLISHABLE_KEY"))")
        print("- Supabase URL Source: \(getSourceDescription(for: "SUPABASE_URL"))")
        print("- Supabase Key Source: \(getSourceDescription(for: "SUPABASE_ANON_KEY"))")
        print("- YouTube Key Source: \(getSourceDescription(for: "YOUTUBE_API_KEY"))")
        
        // Validation
        print("\nValidation:")
        print("- Configuration Valid: \(EnvironmentConfiguration.isValid)")
        if !EnvironmentConfiguration.isValid {
            print("- Validation Errors: \(EnvironmentConfiguration.validationErrors)")
        }
        
        // Bundle info
        print("\nBundle Info:")
        print("- Bundle ID: \(Bundle.main.bundleIdentifier ?? "Unknown")")
        print("- App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")")
        print("- Build Number: \(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown")")
        
        print("================================")
    }
    
    private static func getSourceDescription(for key: String) -> String {
        if ProcessInfo.processInfo.environment[key] != nil {
            return "Environment Variable ✅"
        } else if Bundle.main.infoDictionary?[key] != nil {
            return "Bundle Info ✅"
        } else {
            return "Fallback Value ⚠️"
        }
    }
}
