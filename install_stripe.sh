#!/bin/bash

# Stripe iOS SDK Installation Script for RG10
# This script helps you add Stripe to your Xcode project properly

echo "🔧 Stripe iOS SDK Installation Guide"
echo "====================================="
echo ""
echo "Since manually editing the .pbxproj file can corrupt it,"
echo "please follow these steps in Xcode:"
echo ""
echo "1. Open RG10.xcodeproj in Xcode"
echo "2. Select your project in the navigator (top-level 'RG10')"
echo "3. Go to the 'Package Dependencies' tab"
echo "4. Click the '+' button to add a new package"
echo "5. Enter the URL: https://github.com/stripe/stripe-ios.git"
echo "6. Click 'Add Package'"
echo "7. Select these products:"
echo "   ✅ Stripe"
echo "   ✅ StripePaymentSheet"
echo "8. Click 'Add Package'"
echo ""
echo "9. Select your RG10 target"
echo "10. Go to 'Frameworks, Libraries, and Embedded Content'"
echo "11. Make sure both Stripe libraries are added"
echo ""
echo "12. Update PaymentConfiguration.swift with your Stripe key:"
echo "    static let stripePublishableKey = \"pk_test_your_actual_key_here\""
echo ""
echo "13. Build and test your project!"
echo ""
echo "🎉 Your payment system is ready to use!"
echo ""
echo "Test with Stripe test card: 4242424242424242"



