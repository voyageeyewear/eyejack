#!/bin/bash

# Build 123 - No Gap Above Add To Cart Fix
# Installation Script

echo "=========================================="
echo "  Eyejack v12.3.0 Build 123 Installation"
echo "  NO GAP ABOVE ADD TO CART FIX"
echo "=========================================="
echo ""

APK_FILE="Eyejack-v12.3.0-Build123-NO-GAP-ABOVE-CART.apk"

# Check if APK exists
if [ ! -f "$APK_FILE" ]; then
    echo "❌ Error: APK file not found: $APK_FILE"
    echo "Please make sure you're in the correct directory."
    exit 1
fi

echo "📱 Checking for connected devices..."
DEVICES=$(adb devices | grep -w "device" | wc -l)

if [ $DEVICES -eq 0 ]; then
    echo "❌ No devices found!"
    echo ""
    echo "Please:"
    echo "  1. Connect your Android device via USB"
    echo "  2. Enable USB debugging"
    echo "  3. Or start an emulator"
    exit 1
fi

echo "✅ Found $DEVICES device(s)"
echo ""
echo "🗑️  Uninstalling old version (if exists)..."
adb uninstall com.example.eyejack_shopify_app 2>/dev/null || true

echo ""
echo "📦 Installing Build 123..."
adb install -r "$APK_FILE"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ =========================================="
    echo "✅  Installation Successful!"
    echo "✅ =========================================="
    echo ""
    echo "🎯 What to look for:"
    echo "   • Green banner: 'v12.3.0 NO GAP ABOVE ADD TO CART'"
    echo "   • Version badge: 'v12.3.0 NO-GAP'"
    echo "   • ADD TO CART button sits directly below product details"
    echo "   • NO gap between product info and buttons!"
    echo ""
    echo "📍 To verify the fix:"
    echo "   1. Open the app"
    echo "   2. Navigate to any collection (e.g., Sunglasses)"
    echo "   3. Check product cards"
    echo "   4. Verify NO gap above ADD TO CART button"
    echo ""
    echo "🚀 App is ready to use!"
else
    echo ""
    echo "❌ Installation failed!"
    echo "Please check the error message above."
    exit 1
fi




