#!/bin/bash

echo "🔥 SIMPLE FRESH BUILD - Build 138"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

cd "/Users/ssenterprises/Eyejack Native Application/eyejack_flutter_app"

# Step 1: Flutter clean
echo "🧹 Step 1/4: Cleaning Flutter..."
flutter clean
rm -rf build/

# Step 2: Clean local Gradle only (not global cache)
echo "🧹 Step 2/4: Cleaning local Gradle..."
rm -rf android/.gradle/
rm -rf android/app/build/

# Step 3: Get dependencies
echo "📦 Step 3/4: Getting dependencies..."
flutter pub get

# Step 4: Build fresh APK
echo "🔨 Step 4/4: Building fresh APK..."
flutter build apk --release

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Fresh APK built successfully!"
    
    # Copy with timestamp
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    cp build/app/outputs/flutter-apk/app-release.apk \
       "../Eyejack-v12.10.0-Build138-FRESH-${TIMESTAMP}.apk"
    
    echo ""
    echo "📦 APK saved as: Eyejack-v12.10.0-Build138-FRESH-${TIMESTAMP}.apk"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ BUILD COMPLETE!"
    echo ""
    echo "🔥 NOW INSTALL WITH FULL CACHE CLEAR:"
    echo ""
    echo "# On your device, run these commands:"
    echo "adb uninstall com.eyejack.shopify_app"
    echo "adb install Eyejack-v12.10.0-Build138-FRESH-${TIMESTAMP}.apk"
    echo "adb shell pm clear com.eyejack.shopify_app"
    echo ""
    echo "This will completely clear all cached data!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
else
    echo ""
    echo "❌ Build failed!"
    exit 1
fi



