#!/bin/bash

# Build 124 - Big Images, Big Text, Spacious Design
# Installation Script

echo "=========================================="
echo "  Eyejack v12.4.0 Build 124 Installation"
echo "  BIG IMAGES + BIG TEXT + EVEN SPACING"
echo "=========================================="
echo ""

APK_FILE="Eyejack-v12.4.0-Build124-BIG-IMAGES-BIG-TEXT.apk"

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
echo "📦 Installing Build 124..."
adb install -r "$APK_FILE"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ =========================================="
    echo "✅  Installation Successful!"
    echo "✅ =========================================="
    echo ""
    echo "🎯 What's New in Build 124:"
    echo "   ✨ BIGGER product images (50% of card!)"
    echo "   ✨ BIGGER text sizes (20-30% larger!)"
    echo "   ✨ EVEN consistent spacing between elements"
    echo "   ✨ NO wasted space below buttons"
    echo "   ✨ Bigger buttons (36px height)"
    echo ""
    echo "🔍 To verify the improvements:"
    echo "   1. Look for green banner: 'v12.4.0 BIG IMAGES + BIG TEXT + EVEN SPACING'"
    echo "   2. Navigate to any collection (e.g., Sunglasses)"
    echo "   3. Notice the MUCH BIGGER product images"
    echo "   4. Check the LARGER, more readable text"
    echo "   5. See the PERFECT even spacing between elements"
    echo "   6. Observe NO empty space at bottom - perfectly filled!"
    echo ""
    echo "🚀 App is ready to use! Enjoy the new spacious design!"
else
    echo ""
    echo "❌ Installation failed!"
    echo "Please check the error message above."
    exit 1
fi




