#!/bin/bash

echo "🔥 INSTALLING FRESH BUILD 138 - WITH COMPLETE CACHE CLEAR"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if adb is available
if ! command -v adb &> /dev/null; then
    echo "❌ Error: adb not found"
    exit 1
fi

# Check if device is connected
if ! adb devices | grep -q "device$"; then
    echo "❌ Error: No Android device connected"
    exit 1
fi

echo "📱 Device: $(adb devices | grep device$ | awk '{print $1}')"
echo ""

# Find the latest FRESH APK
FRESH_APK=$(ls -t Eyejack-v12.10.0-Build138-FRESH-*.apk 2>/dev/null | head -1)

if [ -z "$FRESH_APK" ]; then
    FRESH_APK="Eyejack-v12.10.0-Build138-PROFESSIONAL-CART.apk"
fi

echo "📦 Installing: $FRESH_APK"
echo ""

# Step 1: Force stop app
echo "🛑 Step 1/5: Force stopping app..."
adb shell am force-stop com.eyejack.shopify_app 2>/dev/null

# Step 2: Clear app data (if installed)
echo "🧹 Step 2/5: Clearing app data..."
adb shell pm clear com.eyejack.shopify_app 2>/dev/null

# Step 3: Uninstall old version
echo "🗑️  Step 3/5: Uninstalling old version..."
adb uninstall com.eyejack.shopify_app 2>/dev/null

# Step 4: Install fresh APK
echo "📲 Step 4/5: Installing fresh APK..."
adb install "$FRESH_APK"

if [ $? -eq 0 ]; then
    # Step 5: Clear cache immediately after install
    echo "🔥 Step 5/5: Clearing cache on fresh install..."
    adb shell pm clear com.eyejack.shopify_app
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ INSTALLATION COMPLETE WITH FULL CACHE CLEAR!"
    echo ""
    echo "🎯 YOUR NEW CHANGES SHOULD NOW BE VISIBLE:"
    echo "   ✅ Professional sticky cart (reward banner + side-by-side buttons)"
    echo "   ✅ Product Highlights image collage (above specifications)"
    echo ""
    echo "📱 Open the app now and check any product page!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
else
    echo ""
    echo "❌ Installation failed!"
    exit 1
fi



