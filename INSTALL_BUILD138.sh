#!/bin/bash

echo "🚀 Installing Eyejack v12.10.0 (Build 138) - Professional Product Page"
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

# Uninstall old version
echo "🗑️  Uninstalling old version..."
adb uninstall com.eyejack.shopify_app 2>/dev/null

echo ""
echo "📦 Installing Build 138..."
adb install -r "Eyejack-v12.10.0-Build138-PROFESSIONAL-CART.apk"

if [ $? -eq 0 ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ Installation Complete!"
    echo ""
    echo "🎯 NEW FEATURES:"
    echo "  1. ✨ Professional Sticky Cart Design"
    echo "     - Reward points banner"
    echo "     - Side-by-side buttons (Add to Cart + Buy Now)"
    echo "     - Professional price display with discount"
    echo "     - Compact spacing"
    echo ""
    echo "  2. 🖼️  Product Highlights Image Collage"
    echo "     - Dynamic collage layout above specifications"
    echo "     - Uses product images 2-7 in mosaic style"
    echo "     - Beautiful rounded corners and spacing"
    echo ""
    echo "📝 WHAT TO TEST:"
    echo "  - Open any product page"
    echo "  - Check bottom sticky cart design"
    echo "  - Scroll down to see Product Highlights collage"
    echo "  - Test Add To Cart and Buy Now buttons"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
else
    echo ""
    echo "❌ Installation failed!"
    exit 1
fi



