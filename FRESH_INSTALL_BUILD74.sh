#!/bin/bash

# Fresh Install Script for Build 74
# This script completely removes old app and installs fresh

echo "🧹 STEP 1: Uninstalling old Eyejack app..."
adb uninstall com.eyejack.app 2>/dev/null || echo "No previous installation found"

echo ""
echo "🧹 STEP 2: Clearing device cache..."
adb shell pm clear com.eyejack.app 2>/dev/null || echo "Cache cleared"

echo ""
echo "🧹 STEP 3: Killing any running instances..."
adb shell am force-stop com.eyejack.app 2>/dev/null || echo "No running instances"

echo ""
echo "📦 STEP 4: Installing fresh APK..."
adb install -r "Eyejack-v6.3.0-Build74-SimultaneousVideos.apk"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ SUCCESS! Fresh installation complete!"
    echo ""
    echo "🚀 Starting app..."
    adb shell am start -n com.eyejack.app/.MainActivity
    echo ""
    echo "✅ App launched!"
    echo ""
    echo "📱 New features you should see:"
    echo "   1. ⏭️  Skip button (appears after 5 seconds on splash)"
    echo "   2. 🎥 New Arrivals circle - playing video"
    echo "   3. 🎥 BOGO circle - playing video"
    echo "   4. 🎬 Shop By Video - ALL videos play simultaneously"
    echo "   5. ✍️  Shop By Video text - matches other sections (20px)"
    echo ""
    echo "🔍 To see debug logs for Shop By Video:"
    echo "   adb logcat | grep '🎥 Initializing'"
    echo "   adb logcat | grep '✅ Video'"
else
    echo ""
    echo "❌ Installation failed!"
    echo "Please connect your device/emulator and try again"
fi

