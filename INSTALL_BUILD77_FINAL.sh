#!/bin/bash

echo "=================================="
echo "🎬 BUILD 77 - FINAL FIX"
echo "=================================="
echo ""

# Uninstall completely
echo "🧹 Step 1: Complete uninstall..."
adb uninstall com.eyejack.app 2>/dev/null
echo "✅ Uninstalled"
echo ""

# Clear everything
echo "🧹 Step 2: Clearing all cache..."
adb shell pm clear com.eyejack.app 2>/dev/null
echo "✅ Cache cleared"
echo ""

# Install fresh
echo "📦 Step 3: Installing Build 77..."
adb install -r "Eyejack-v6.4.1-Build77-BackToWorking.apk"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ INSTALLATION SUCCESSFUL!"
    echo ""
    echo "🚀 Launching app..."
    adb shell am start -n com.eyejack.app/.MainActivity
    sleep 2
    echo ""
    echo "=================================="
    echo "✅ BUILD 77 IS RUNNING"
    echo "=================================="
    echo ""
    echo "📱 Navigate to 'Shop By Video'"
    echo ""
    echo "🎥 Expected behavior:"
    echo "   • First video plays automatically"
    echo "   • Swipe left/right to change"
    echo "   • Each video plays when selected"
    echo "   • Videos are muted and loop"
    echo "   • Smooth performance"
    echo ""
    echo "✅ Videos should work perfectly now!"
else
    echo ""
    echo "❌ Installation failed"
    echo "Make sure device is connected:"
    echo "   adb devices"
    exit 1
fi

