#!/bin/bash

echo "========================================="
echo "🎬 Build 76 - Proper Video Playback"
echo "========================================="
echo ""

# Uninstall
echo "🧹 Uninstalling old app..."
adb uninstall com.eyejack.app 2>/dev/null
echo ""

# Install
echo "📦 Installing Build 76..."
adb install -r "Eyejack-v6.4.0-Build76-OneVideoAtTime.apk"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Installation successful!"
    echo ""
    echo "🚀 Launching app..."
    adb shell am start -n com.eyejack.app/.MainActivity
    echo ""
    echo "========================================="
    echo "✅ BUILD 76 INSTALLED!"
    echo "========================================="
    echo ""
    echo "🎥 How Videos Work Now:"
    echo "   • ONE video plays at a time"
    echo "   • Swipe left/right to change videos"
    echo "   • Current video plays automatically"
    echo "   • Other videos paused"
    echo "   • Pre-loads next/previous videos"
    echo "   • Shows thumbnails for non-playing videos"
    echo ""
    echo "📱 Features:"
    echo "   • PageView with swipe navigation"
    echo "   • Page indicators (dots)"
    echo "   • Green play icon on current video"
    echo "   • Smooth transitions"
    echo "   • Shop By Video text = 20px"
    echo ""
else
    echo ""
    echo "❌ Installation failed!"
    exit 1
fi

