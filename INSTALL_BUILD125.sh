#!/bin/bash

# Build 125 - More Spacing & Rounded Buttons
# Installation Script

echo "=========================================="
echo "  Eyejack v12.5.0 Build 125 Installation"
echo "  MORE SPACING + ROUNDED BUTTONS"
echo "=========================================="
echo ""

APK_FILE="Eyejack-v12.5.0-Build125-MORE-SPACING-ROUNDED.apk"

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
adb uninstall com.eyejack.app 2>/dev/null || true

echo ""
echo "📦 Installing Build 125..."
adb install -r "$APK_FILE"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ =========================================="
    echo "✅  Installation Successful!"
    echo "✅ =========================================="
    echo ""
    echo "🎯 What's New in Build 125:"
    echo "   📐 MORE SPACING: 8px between all content blocks"
    echo "      • Title → Review: 8px"
    echo "      • Review → Price: 8px"
    echo "      • Price → EMI: 8px"
    echo "      • EMI → In Stock: 8px"
    echo "      • In Stock → Buttons: Spacer + 8px"
    echo ""
    echo "   🔘 ROUNDED BUTTONS:"
    echo "      • ADD TO CART: 8px rounded corners"
    echo "      • BUY 1 GET 1 FREE: 8px rounded corners"
    echo ""
    echo "   📏 BUTTON MARGINS:"
    echo "      • 8px margin from left and right"
    echo "      • Buttons don't touch edges"
    echo "      • Professional, modern look"
    echo ""
    echo "🔍 To verify:"
    echo "   1. Look for: 'v12.5.0 MORE SPACING + ROUNDED BUTTONS'"
    echo "   2. Navigate to any collection"
    echo "   3. Notice clear 8px spacing between all elements"
    echo "   4. See rounded corners on both buttons"
    echo "   5. Notice buttons have margins from edges"
    echo ""
    echo "🚀 App is ready! Enjoy the cleaner, more modern layout!"
else
    echo ""
    echo "❌ Installation failed!"
    echo "Please check the error message above."
    exit 1
fi




