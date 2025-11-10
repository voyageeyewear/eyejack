# 🧹 Clear Cache & Fresh Install - Build 73

## Problem: App showing old cached version

If you're not seeing the new features (Skip button, circular videos), you have a **cache issue**. Follow these steps for a **completely fresh install**.

---

## 🚀 Quick Method (Automated Script)

### Connect your device/emulator, then run:

```bash
cd "/Users/ssenterprises/Eyejack Native Application"
./FRESH_INSTALL_BUILD73.sh
```

This script will:
1. ✅ Uninstall old app completely
2. ✅ Clear all cached data
3. ✅ Kill any running instances
4. ✅ Install fresh APK
5. ✅ Launch the app

---

## 🛠️ Manual Method (Step by Step)

If the automated script doesn't work, do this manually:

### Step 1: Connect Device/Emulator
```bash
adb devices
```
Make sure your device shows up!

### Step 2: Completely Uninstall Old App
```bash
adb uninstall com.eyejack.app
```

### Step 3: Clear Device Cache
```bash
adb shell pm clear com.eyejack.app
```

### Step 4: Kill Running Instances
```bash
adb shell am force-stop com.eyejack.app
```

### Step 5: Install Fresh APK
```bash
adb install -r "Eyejack-v6.2.2-Build73-FRESH-CLEAN.apk"
```

### Step 6: Launch App
```bash
adb shell am start -n com.eyejack.app/.MainActivity
```

---

## ✅ What You Should See (New Features)

After fresh install, you should see:

### 1. ⏭️ Skip Button (Splash Screen)
- Video plays on launch
- **After 5 seconds**, skip button appears at top right
- White rounded button with "Skip →"
- Tap to skip video immediately

### 2. 🎥 New Arrivals Circle
- **Playing MP4 video** (not static image)
- Video loops continuously
- Muted playback
- Circular format

### 3. 🎥 BOGO Circle
- **Playing MP4 video** (not static image)
- Video loops continuously
- Muted playback
- "SALE LIVE" red badge on top

---

## 🔍 Debug / Verify Installation

### Check if new version is installed:
```bash
adb shell dumpsys package com.eyejack.app | grep versionName
```

### Watch debug logs for video initialization:
```bash
adb logcat | grep "🎥"
```

You should see logs like:
```
🎥 Category 2: name=New Arrivals, type=video, video=https://...
🎬 Initializing video for: new-arrivals
✅ Video initialized successfully for: new-arrivals
▶️ Video playing for: new-arrivals
```

### Watch logs for skip button:
```bash
adb logcat | grep "Skip"
```

---

## 🆘 Still Not Working?

### 1. Make sure you have the LATEST APK:
```bash
ls -lh "Eyejack-v6.2.2-Build73-FRESH-CLEAN.apk"
```
Check file date - it should be TODAY's date!

### 2. Clear Flutter build cache on your machine:
```bash
cd eyejack_flutter_app
flutter clean
flutter pub get
flutter build apk --release
```

### 3. Restart your device/emulator:
```bash
adb reboot
```
Wait for reboot, then install fresh APK.

### 4. Check device storage:
- Make sure device has enough space
- Videos need to download and cache

### 5. Check internet connection:
- Videos stream from eyejack.in
- Need active internet connection

---

## 📱 Testing Checklist

After fresh install, verify:

- [ ] Splash video plays immediately
- [ ] Skip button appears after 5 seconds (top right)
- [ ] Can tap skip button to skip video
- [ ] "New Arrivals" circle shows **playing video** (not static)
- [ ] "BOGO" circle shows **playing video** (not static)
- [ ] BOGO has red "SALE LIVE" badge
- [ ] Videos are muted
- [ ] Videos loop continuously
- [ ] All other circles show images (Sunglasses, Eyeglasses, View all)

---

## 🎯 Key Files

- **Fresh APK:** `Eyejack-v6.2.2-Build73-FRESH-CLEAN.apk`
- **Install Script:** `FRESH_INSTALL_BUILD73.sh`
- **Version:** 6.2.2
- **Build:** 73
- **Size:** 54.6 MB
- **Package:** com.eyejack.app

---

## 💡 Why This Happens

**Caching causes:**
1. Android keeps old app data
2. Flutter hot reload doesn't update everything
3. Video controllers get cached
4. APK overwrites don't clear all data

**Solution:** Complete uninstall + fresh install clears ALL cached data.

---

## 🚀 Ready to Install?

Run the automated script:
```bash
./FRESH_INSTALL_BUILD73.sh
```

Or follow manual steps above!

**Your new features are waiting!** 🎉

