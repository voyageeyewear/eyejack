# 📱 Install Eyejack App on Your Android Device

## ✅ APK Built Successfully!

**File:** `Eyejack-Video-App.apk` (48 MB)  
**Location:** `/Users/ssenterprises/Eyejack Native Application/Eyejack-Video-App.apk`

---

## 🚀 Installation Instructions

### **Option 1: Transfer via USB Cable**

1. **Connect your Android phone to your Mac** via USB cable
2. **Enable USB Debugging** on your phone:
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times to enable Developer Options
   - Go back to Settings → Developer Options
   - Enable "USB Debugging"
3. **Copy APK to your phone:**
   ```bash
   # Your phone should appear as a mounted drive
   # Copy the APK file to your phone's Downloads folder
   ```
4. **On your phone:**
   - Open Files app → Downloads
   - Tap on `Eyejack-Video-App.apk`
   - Tap "Install"
   - Tap "Allow" if prompted to install from unknown sources

### **Option 2: Transfer via Email/AirDrop**

1. **Email yourself the APK:**
   - Attach `Eyejack-Video-App.apk` to an email
   - Send it to yourself
   - Open email on your phone and download

2. **Or use AirDrop** (if your phone supports it):
   - Share `Eyejack-Video-App.apk` via AirDrop to your phone

### **Option 3: Install via ADB (Recommended for developers)**

1. **Connect phone via USB** with USB Debugging enabled
2. **Install APK directly:**
   ```bash
   adb install "/Users/ssenterprises/Eyejack Native Application/Eyejack-Video-App.apk"
   ```

---

## 🎬 What's Included in This Build

✅ **MP4 Video Support** - Slides 2 & 3 now play your Shopify MP4 videos  
✅ **Auto-play Videos** - Videos automatically start when slideshow advances  
✅ **Black Header** - Exact match to your website design  
✅ **All Sections** - Announcement bars, USP strip, categories, collections, offers  
✅ **Products & Collections** - Full Shopify store integration  
✅ **Search Functionality** - Product search included  

---

## 🔧 Backend Setup Required

**IMPORTANT:** Before using the app, make sure the Node.js backend is running:

```bash
cd "/Users/ssenterprises/Eyejack Native Application/shopify-middleware"
node server.js
```

The backend should be running on `http://localhost:3000`

**For Real Device:** Update the IP address in the app:
- Find your Mac's local IP: `ifconfig | grep "inet " | grep -v 127.0.0.1`
- Update `lib/config/api_config.dart` to use your Mac's IP instead of `10.0.2.2`

---

## ✅ Test Videos on Real Device

Once installed on your phone:
1. **Open the Eyejack app**
2. **Scroll to the slideshow section**
3. **Swipe to slide 2** - MP4 video should auto-play! 🎬
4. **Swipe to slide 3** - Another MP4 video should auto-play! 🎬

**The videos will play automatically** - no tap needed!

---

## 📞 Troubleshooting

### Videos not playing?
- ✅ Make sure backend is running
- ✅ Check phone has internet connection
- ✅ Ensure your Mac's firewall allows port 3000

### App crashes?
- Check the logs: `adb logcat | grep eyejack`

### Can't install APK?
- Enable "Install from Unknown Sources" in Android settings

---

**The APK is ready to install! Transfer it to your phone and test those MP4 videos! 🚀**

