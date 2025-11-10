#!/bin/bash

echo "========================================="
echo "🎬 Build 75 - Video Debug Installation"
echo "========================================="
echo ""

# Step 1: Uninstall
echo "🧹 STEP 1: Uninstalling old app..."
adb uninstall com.eyejack.app 2>/dev/null
echo "✅ Uninstalled"
echo ""

# Step 2: Install fresh
echo "📦 STEP 2: Installing Build 75..."
adb install -r "Eyejack-v6.3.1-Build75-VideoDebug.apk"

if [ $? -ne 0 ]; then
    echo "❌ Installation failed!"
    echo "Make sure device is connected: adb devices"
    exit 1
fi

echo "✅ Installed successfully!"
echo ""

# Step 3: Clear logcat
echo "🧹 STEP 3: Clearing old logs..."
adb logcat -c
echo "✅ Logs cleared"
echo ""

# Step 4: Launch app
echo "🚀 STEP 4: Launching app..."
adb shell am start -n com.eyejack.app/.MainActivity
sleep 3
echo "✅ App launched"
echo ""

# Step 5: Show video logs
echo "========================================="
echo "🔍 WATCHING VIDEO INITIALIZATION LOGS"
echo "========================================="
echo ""
echo "Scroll down to 'Shop By Video' section in the app..."
echo "Then watch the logs below:"
echo ""
echo "---"

# Start watching logs
adb logcat | grep -E "(🎬|🎥|✅|❌|⚠️|▶️|VIDEO SLIDER)"

