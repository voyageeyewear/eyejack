#!/bin/bash

echo "🚀 Installing Eyejack v12.11.0 (Build 139) - Slim & Sleek Design"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if adb is available
if ! command -v adb &> /dev/null; then
    echo "❌ Error: adb not found. Please install Android SDK Platform Tools."
    exit 1
fi

# Check if device is connected
if ! adb devices | grep -q "device$"; then
    echo "❌ Error: No Android device connected."
    echo "   Please connect your device and enable USB debugging."
    exit 1
fi

echo "📱 Device connected: $(adb devices | grep device$ | awk '{print $1}')"
echo ""

# Step 1: Force stop app
echo "🛑 Step 1/4: Force stopping app..."
adb shell am force-stop com.eyejack.shopify_app 2>/dev/null

# Step 2: Uninstall old version
echo "🗑️  Step 2/4: Uninstalling old version..."
adb uninstall com.eyejack.shopify_app 2>/dev/null

# Step 3: Install fresh APK
echo "📲 Step 3/4: Installing Build 139..."
adb install "Eyejack-v12.11.0-Build139-SLIM-SLEEK.apk"

if [ $? -eq 0 ]; then
    # Step 4: Clear cache
    echo "🔥 Step 4/4: Clearing cache..."
    adb shell pm clear com.eyejack.shopify_app 2>/dev/null
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ INSTALLATION COMPLETE!"
    echo ""
    echo "🎯 WHAT'S NEW IN BUILD 139:"
    echo ""
    echo "  1. ✨ Slim & Sleek Sticky Cart"
    echo "     - 30% less height (100px vs 140px)"
    echo "     - ALL price info in ONE LINE:"
    echo "       Price → Compare Price → Discount % → Tax info"
    echo "     - Compact 8px spacing"
    echo "     - Smaller, professional buttons"
    echo ""
    echo "  2. 🖼️  No More Image Cropping"
    echo "     - All Product Highlights images show completely"
    echo "     - No cropping on bottom row"
    echo "     - Grey background fills letterbox space"
    echo ""
    echo "📝 WHAT TO CHECK:"
    echo "  ✅ Open any product page"
    echo "  ✅ Bottom sticky cart is now slim and sleek"
    echo "  ✅ Price, discount, tax all in one line"
    echo "  ✅ Scroll to Product Highlights - no cropping!"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
else
    echo ""
    echo "❌ Installation failed!"
    exit 1
fi



