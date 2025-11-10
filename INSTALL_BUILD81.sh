#!/bin/bash

echo "🚀 Installing Eyejack Build 81 - Video Thumbnails & Spacing Fix"
echo "================================================================"
echo ""
echo "✅ IMPROVEMENTS:"
echo "   1. Removed white space before first video"
echo "   2. Added thumbnails to all videos"
echo "   3. Videos aligned properly from left edge"
echo ""
echo "📦 APK: Eyejack-v8.0.1-Build81-VideoThumbnails.apk"
echo ""

# Check if device connected
if ! adb devices | grep -q "device$"; then
    echo "❌ No device connected!"
    echo "Please connect your Android device and enable USB debugging."
    exit 1
fi

echo "📱 Device connected!"
echo ""

# Uninstall old version
echo "🗑️  Uninstalling old version..."
adb uninstall com.eyejack.shopify_app 2>/dev/null
echo ""

# Install new APK
echo "📲 Installing Build 81..."
adb install -r "Eyejack-v8.0.1-Build81-VideoThumbnails.apk"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ INSTALLATION SUCCESSFUL!"
    echo ""
    echo "🎯 What's Fixed:"
    echo "   ✓ No white space before first video"
    echo "   ✓ Thumbnails show while videos load"
    echo "   ✓ Better visual experience"
    echo "   ✓ Circular categories perfect"
    echo ""
    echo "🚀 Ready to test!"
else
    echo ""
    echo "❌ Installation failed!"
    echo "Try manually: adb install -r Eyejack-v8.0.1-Build81-VideoThumbnails.apk"
fi

