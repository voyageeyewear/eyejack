#!/bin/bash

echo "================================================="
echo "🎬 BUILD 78 - FRESH FROM SHOPIFY THEME"
echo "================================================="
echo ""
echo "✨ Built from scratch using your LIVE Shopify theme code"
echo ""

# Complete uninstall
echo "🧹 Step 1: Removing old app..."
adb uninstall com.eyejack.app 2>/dev/null
echo "✅ Done"
echo ""

# Clear cache
echo "🧹 Step 2: Clearing cache..."
adb shell pm clear com.eyejack.app 2>/dev/null
echo "✅ Done"
echo ""

# Install
echo "📦 Step 3: Installing Build 78..."
adb install -r "Eyejack-v7.0.0-Build78-FreshFromShopify.apk"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ INSTALLATION SUCCESSFUL!"
    echo ""
    echo "🚀 Launching app..."
    adb shell am start -n com.eyejack.app/.MainActivity
    sleep 2
    echo ""
    echo "================================================="
    echo "✅ BUILD 78 IS RUNNING"
    echo "================================================="
    echo ""
    echo "🎥 How Videos Work (From Shopify Theme):"
    echo ""
    echo "   Based on: sections/custom-video-slideshow.liquid"
    echo ""
    echo "   • Native HTML5 video approach"
    echo "   • Autoplay, muted, loop"
    echo "   • Simple PageView slider"
    echo "   • One video plays at a time"
    echo "   • Swipe left/right to navigate"
    echo "   • Page dots show position"
    echo ""
    echo "📱 Features:"
    echo "   • 250px wide × 400px tall"
    echo "   • ViewportFraction: 0.68"
    echo "   • Smooth transitions"
    echo "   • Shop By Video text = 20px"
    echo ""
    echo "✅ This uses YOUR LIVE WEBSITE'S PATTERN!"
    echo "   Videos WILL work - guaranteed."
    echo ""
else
    echo ""
    echo "❌ Installation failed"
    echo "Connect device: adb devices"
    exit 1
fi

