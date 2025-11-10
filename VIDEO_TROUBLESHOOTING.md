# 🎥 Video Not Playing - Troubleshooting Guide

## Issue: Videos in "Shop By Video" section are not playing

---

## 🚀 Solution 1: Fresh Install (Most Common Fix)

### Run the automated script:
```bash
cd "/Users/ssenterprises/Eyejack Native Application"
./FRESH_INSTALL_BUILD74.sh
```

This will:
1. Completely uninstall old app
2. Clear ALL cached data
3. Install fresh Build 74 APK
4. Launch the app

---

## 🔍 Solution 2: Debug & Verify

### Check if videos are initializing:
```bash
adb logcat | grep "🎥"
```

**You should see:**
```
🎥 Initializing 4 videos to play simultaneously
✅ Video 0 initialized and playing simultaneously
✅ Video 1 initialized and playing simultaneously
✅ Video 2 initialized and playing simultaneously
✅ Video 3 initialized and playing simultaneously
```

### If you see errors:
```bash
adb logcat | grep "❌"
```

This will show any video initialization errors.

---

## 🌐 Solution 3: Check Internet Connection

Videos stream from `eyejack.in` - you need:
- ✅ Active internet connection
- ✅ Device has network access
- ✅ No firewall blocking video streaming

### Test internet on device:
```bash
adb shell ping -c 3 eyejack.in
```

---

## 💾 Solution 4: Check Device Storage

Videos need space to buffer and cache.

### Check available storage:
```bash
adb shell df -h
```

Make sure you have at least **500 MB free**.

---

## 🔄 Solution 5: Complete Clean Rebuild

If nothing works, rebuild APK from scratch:

```bash
cd eyejack_flutter_app

# 1. Clean everything
flutter clean
rm -rf build/
rm -rf .dart_tool/

# 2. Get dependencies
flutter pub get

# 3. Build fresh APK
flutter build apk --release

# 4. Copy to main directory
cd ..
cp eyejack_flutter_app/build/app/outputs/flutter-apk/app-release.apk "Eyejack-v6.3.0-Build74-ULTRA-FRESH.apk"

# 5. Uninstall old app
adb uninstall com.eyejack.app

# 6. Install fresh APK
adb install "Eyejack-v6.3.0-Build74-ULTRA-FRESH.apk"

# 7. Launch
adb shell am start -n com.eyejack.app/.MainActivity
```

---

## 🎯 What Videos Should Look Like

### Shop By Video Section:
```
┌────────────────────────────────────────┐
│ Shop By Video                (20px)    │
│                                        │
│ [🎬 Playing] [🎬 Playing] [🎬 Playing] │
│  Video 1      Video 2      Video 3    │
│ ←─── Scroll horizontally ───→         │
└────────────────────────────────────────┘
```

**Expected Behavior:**
- ✅ ALL videos playing at once
- ✅ All videos looping
- ✅ All videos muted
- ✅ Scroll horizontally to see all
- ✅ 250px width x 400px height each

---

## 🐛 Common Issues & Fixes

### Issue: Black rectangles instead of videos
**Cause:** Videos still initializing
**Fix:** Wait 5-10 seconds for all videos to initialize

### Issue: Videos show briefly then disappear
**Cause:** Video controllers being disposed incorrectly
**Fix:** Fresh install with cache clear

### Issue: Only first video plays
**Cause:** Old cached version of app
**Fix:** Run `./FRESH_INSTALL_BUILD74.sh`

### Issue: Videos freeze/stutter
**Cause:** Low device memory or poor connection
**Fix:** 
- Close other apps
- Check internet speed
- Restart device

---

## 📊 Video URLs (From Backend)

The videos should be loading from:
```
https://eyejack.in/cdn/shop/videos/...
```

### Check if backend is serving videos:
```bash
curl -I "https://eyejack.in/cdn/shop/videos/c/vp/..."
```

Should return `200 OK`

---

## 🔧 Advanced Debugging

### Full logcat for video errors:
```bash
adb logcat | grep -E "(Video|Chewie|VideoPlayer|🎥|❌)"
```

### Check video controller state:
```bash
adb logcat | grep "initialized"
```

### Monitor memory usage:
```bash
adb shell dumpsys meminfo com.eyejack.app
```

---

## 📱 Device Requirements

**Minimum:**
- Android 5.0+ (API 21+)
- 2GB RAM
- 500MB free storage
- Internet connection

**Recommended:**
- Android 8.0+ (API 26+)
- 4GB RAM
- 1GB free storage
- Fast internet (WiFi preferred)

---

## ✅ Testing Checklist

After fresh install, verify:

- [ ] App opens without crashes
- [ ] Splash video plays (with skip button after 5s)
- [ ] Home screen loads
- [ ] Scroll down to "Shop By Video" section
- [ ] See multiple video cards (250px x 400px)
- [ ] ALL videos are playing simultaneously
- [ ] Videos are looping
- [ ] Videos are muted
- [ ] Can scroll horizontally through videos
- [ ] Text says "Shop By Video" (20px font)
- [ ] Tapping video navigates to collection

---

## 🆘 Still Not Working?

### 1. Verify APK version:
```bash
adb shell dumpsys package com.eyejack.app | grep versionName
```
Should show: **6.3.0**

### 2. Check device date/time:
Incorrect date/time can cause SSL certificate errors

### 3. Try on different device:
Test on another device or emulator

### 4. Check logs for specific errors:
```bash
adb logcat > video_debug.log
```
Then search for "error" or "exception"

---

## 💡 Quick Fix Summary

**90% of video issues are fixed by:**

1. **Uninstall old app completely**
   ```bash
   adb uninstall com.eyejack.app
   ```

2. **Clear all cache**
   ```bash
   adb shell pm clear com.eyejack.app
   ```

3. **Install fresh APK**
   ```bash
   adb install -r "Eyejack-v6.3.0-Build74-SimultaneousVideos.apk"
   ```

**Or just run:**
```bash
./FRESH_INSTALL_BUILD74.sh
```

---

## 📞 Need More Help?

If videos still don't play after trying everything above:

1. Run this command and share output:
   ```bash
   adb logcat -d | grep -A 5 "🎥 Initializing" > video_logs.txt
   ```

2. Check `video_logs.txt` for initialization status

3. Verify all 4 videos show "✅ Video X initialized"

---

**Videos should work after fresh install!** 🚀

