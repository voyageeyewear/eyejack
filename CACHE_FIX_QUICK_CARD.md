# 🔥 Android Cache Fix - Quick Card

## 😤 Changes Not Showing?

### ⚡ FASTEST FIX (30 seconds):
```bash
cd "/Users/ssenterprises/Eyejack Native Application"
./INSTALL_FRESH_BUILD138.sh
```

---

## 🎯 One-Line Solutions

### Clear App Cache Only (5 seconds):
```bash
adb shell pm clear com.eyejack.shopify_app
```

### Reinstall Fresh (15 seconds):
```bash
adb uninstall com.eyejack.shopify_app && \
adb install Eyejack-v12.10.0-Build138-FRESH-20251113_165946.apk && \
adb shell pm clear com.eyejack.shopify_app
```

### Rebuild + Install (3-5 minutes):
```bash
cd eyejack_flutter_app && flutter clean && \
flutter build apk --release && cd .. && \
adb uninstall com.eyejack.shopify_app && \
adb install eyejack_flutter_app/build/app/outputs/flutter-apk/app-release.apk && \
adb shell pm clear com.eyejack.shopify_app
```

---

## 🚨 Nuclear Option (If Nothing Works):

```bash
# Delete all caches and rebuild from scratch
cd eyejack_flutter_app
flutter clean
rm -rf build/ android/.gradle/ android/app/build/
rm -rf ~/.gradle
flutter pub get
flutter build apk --release
cd ..
adb uninstall com.eyejack.shopify_app
adb install eyejack_flutter_app/build/app/outputs/flutter-apk/app-release.apk
adb shell pm clear com.eyejack.shopify_app
```

**Time:** ~6 minutes (Gradle cache rebuild takes longest)

---

## 💊 Prevention Medicine

### After Every Fresh Install:
```bash
adb shell pm clear com.eyejack.shopify_app
```

### Before Every Build:
```bash
flutter clean
```

---

## 🎓 Remember:

1. **Always clear app data after install**
2. **Flutter clean before important builds**
3. **Don't partially delete ~/.gradle (all or nothing)**
4. **Use the install script - it does everything right**

---

## 📱 Verify Changes Are There:

```bash
# Check version
adb shell dumpsys package com.eyejack.shopify_app | grep versionName
# Should show: versionName=12.10.0

adb shell dumpsys package com.eyejack.shopify_app | grep versionCode
# Should show: versionCode=138
```

---

## 🆘 Still Not Working?

### Try on Real Device:
```bash
# Make sure you're on the right device
adb devices

# If multiple devices, specify one
adb -s DEVICE_ID install app.apk
adb -s DEVICE_ID shell pm clear com.eyejack.shopify_app
```

### Restart Device:
```bash
adb reboot
# Wait 30 seconds, then reinstall
```

---

## ✅ Success Indicators:

When you open a product page, you should see:

1. **Bottom sticky cart:**
   - ✅ Green "Earn reward points" banner on top
   - ✅ Two buttons side-by-side
   - ✅ "Add To Cart" (black) + "Buy Now" (green)

2. **Scroll down:**
   - ✅ "Product Highlights" section
   - ✅ Multiple images in collage layout
   - ✅ Located above "Product Specifications"

---

## 💾 Bookmark These Files:

1. **INSTALL_FRESH_BUILD138.sh** - Use this always!
2. **ANDROID_CACHE_FIX_GUIDE.md** - Detailed troubleshooting
3. **BUILD138_CACHE_SOLUTION_SUMMARY.md** - What was fixed
4. **This file** - Quick reference

---

**Keep this handy! Android caching is a common headache. 🔥**



