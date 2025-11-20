#!/bin/bash

echo "🚀 Installing Build 140 - Ultra Refined"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Copy APK
cp eyejack_flutter_app/build/app/outputs/flutter-apk/app-release.apk Eyejack-v12.12.0-Build140-ULTRA-REFINED.apk

# Uninstall old
adb uninstall com.eyejack.shopify_app

# Install new
adb install Eyejack-v12.12.0-Build140-ULTRA-REFINED.apk

# Clear cache
adb shell pm clear com.eyejack.shopify_app

echo "✅ Done!"



