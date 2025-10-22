# Xcode Cloud CI/CD Security Setup Guide

## 🔐 Security Enhancement Overview

This guide will help you set up secure API key management for your RG10 iOS app using Xcode Cloud CI/CD pipeline.

## 📋 Current Security Issues Fixed

### Before (Security Issues):
- ❌ Hardcoded Stripe publishable key in source code
- ❌ Hardcoded Supabase URL and anonymous key in multiple files
- ❌ Hardcoded YouTube API key in source code
- ❌ Duplicate configuration across multiple files
- ❌ No environment-specific configuration

### After (Security Enhanced):
- ✅ Environment-based configuration management
- ✅ Xcode Cloud environment variable support
- ✅ Local development configuration via xcconfig files
- ✅ Centralized configuration management
- ✅ Debug information for configuration sources
- ✅ Validation and error handling

## 🚀 Xcode Cloud Setup Instructions

### Step 1: Add Environment Variables in Xcode Cloud

1. Go to your Xcode Cloud project dashboard
2. Navigate to your project settings
3. Click on "Environment Variables" section
4. Add the following variables:

#### Required Environment Variables:
```
STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_key_here
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_supabase_anon_key_here
YOUTUBE_API_KEY=your_youtube_api_key_here
```

#### Optional Environment Variables:
```
APP_ENVIRONMENT=production
```

### Step 2: Environment-Specific Configuration

#### Development Environment:
- Use test keys for all services
- Enable debug logging
- Use development Supabase project

#### Production Environment:
- Use live keys for all services
- Disable debug logging
- Use production Supabase project

### Step 3: Local Development Setup

1. Copy the example configuration file:
   ```bash
   cp Config.xcconfig.example Config.xcconfig
   ```

2. Edit `Config.xcconfig` with your actual keys:
   ```
   STRIPE_PUBLISHABLE_KEY = pk_test_your_actual_stripe_key
   SUPABASE_URL = https://your-project.supabase.co
   SUPABASE_ANON_KEY = your_actual_supabase_anon_key
   YOUTUBE_API_KEY = your_actual_youtube_api_key
   ```

3. Add `Config.xcconfig` to `.gitignore` (already done)

## 🔧 Configuration Architecture

### EnvironmentConfiguration.swift
- Centralized configuration management
- Environment variable support
- Fallback values for development
- Validation and error handling
- Debug information

### PaymentConfiguration.swift
- Updated to use EnvironmentConfiguration
- Maintains backward compatibility
- Enhanced security documentation

### SupabaseManager.swift
- Updated to use EnvironmentConfiguration
- Centralized Supabase client management

### YouTubeService.swift
- Updated to use EnvironmentConfiguration
- Dynamic API key loading

## 🛡️ Security Best Practices

### 1. Key Management
- ✅ Never commit API keys to version control
- ✅ Use different keys for different environments
- ✅ Rotate keys regularly (quarterly recommended)
- ✅ Monitor API usage and set up alerts

### 2. API Key Restrictions
- **Stripe**: Restrict to your app's bundle ID
- **YouTube**: Restrict to YouTube Data API v3 and your app
- **Supabase**: Use Row Level Security (RLS) policies

### 3. Environment Separation
- **Development**: Test keys, debug logging enabled
- **Staging**: Test keys, production-like environment
- **Production**: Live keys, minimal logging

### 4. Monitoring and Alerting
- Set up API usage monitoring
- Configure alerts for unusual activity
- Monitor failed authentication attempts
- Track API quota usage

## 🔍 Debugging Configuration Issues

### Debug Information
The `EnvironmentConfiguration` class provides debug information:

```swift
print(EnvironmentConfiguration.debugInfo)
```

This will show you:
- Current environment
- Configuration source for each key (Environment Variable, Bundle Info, or Fallback)

### Validation
Check configuration validity:

```swift
if !EnvironmentConfiguration.isValid {
    let errors = EnvironmentConfiguration.validationErrors
    print("Configuration errors: \(errors)")
}
```

## 📱 Testing Your Setup

### 1. Local Testing
1. Create `Config.xcconfig` with your keys
2. Build and run the app
3. Check debug output for configuration sources
4. Verify all features work correctly

### 2. Xcode Cloud Testing
1. Add environment variables to Xcode Cloud
2. Trigger a build
3. Check build logs for any configuration issues
4. Test the built app

### 3. Production Testing
1. Use production keys in Xcode Cloud environment variables
2. Test thoroughly in staging environment first
3. Deploy to production
4. Monitor for any issues

## 🚨 Troubleshooting

### Common Issues:

#### 1. "Configuration errors" in logs
- **Cause**: Missing environment variables or invalid keys
- **Solution**: Check Xcode Cloud environment variables or local Config.xcconfig

#### 2. API calls failing
- **Cause**: Invalid or expired API keys
- **Solution**: Verify keys are correct and not expired

#### 3. Build failures in Xcode Cloud
- **Cause**: Missing environment variables
- **Solution**: Ensure all required environment variables are set in Xcode Cloud

#### 4. Different behavior between local and Xcode Cloud
- **Cause**: Different configuration sources
- **Solution**: Check debug info to see configuration sources

## 📚 Additional Resources

- [Xcode Cloud Environment Variables Documentation](https://developer.apple.com/documentation/xcode/xcode-cloud-environment-variables)
- [Stripe API Keys Documentation](https://stripe.com/docs/keys)
- [Supabase API Keys Documentation](https://supabase.com/docs/guides/api/api-keys)
- [YouTube Data API v3 Documentation](https://developers.google.com/youtube/v3/getting-started)

## 🔄 Migration Checklist

- [ ] Create EnvironmentConfiguration.swift
- [ ] Update PaymentConfiguration.swift
- [ ] Update SupabaseManager.swift
- [ ] Update YouTubeService.swift
- [ ] Create Config.xcconfig.example
- [ ] Update .gitignore
- [ ] Add environment variables to Xcode Cloud
- [ ] Test local development setup
- [ ] Test Xcode Cloud build
- [ ] Verify production deployment
- [ ] Update team documentation
- [ ] Remove old hardcoded keys from codebase

## 📞 Support

If you encounter any issues with this setup, check:
1. Debug information from EnvironmentConfiguration
2. Xcode Cloud build logs
3. API service dashboards for key validity
4. This documentation for troubleshooting steps
