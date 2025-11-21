# EyeJack Native Application

A complete Flutter-based e-commerce mobile application for EyeJack eyewear store with **PostgreSQL-powered dynamic content management** and a **professional admin dashboard** for real-time app content updates without requiring app rebuilds.

## 🎯 Project Overview

EyeJack Native Application is a full-featured mobile e-commerce app that replicates the functionality of the live EyeJack Shopify store (www.eyejack.in) with enhanced mobile-first user experience. The app now features a **PostgreSQL backend** and an **elegant admin dashboard** that allows content management without code changes or app rebuilds.

## 🎉 Milestones Achieved

### ✅ Milestone 2: iOS App Store Submission (January 2025)
- 🍎 **iOS App Store Ready**: Complete iOS build configured for App Store submission
- 📱 **Cross-Platform Support**: Full Flutter app now supports both Android and iOS
- 🔧 **Xcode Integration**: Properly configured for release builds and archiving
- 📦 **Archive Ready**: App can be archived, validated, and uploaded to App Store Connect
- 🛒 **GoKwik Checkout**: Integrated across all screens (Home, Collection, Product Detail)
- ✨ **Production Ready**: v12.24.0 (Build 156) ready for iOS App Store submission

### ✅ Milestone 1: Android Production Release
- ✅ **Android APK**: Multiple production releases on Google Play Store
- ✅ **GoKwik Integration**: Complete checkout flow implemented
- ✅ **Admin Dashboard**: Real-time content management system
- ✅ **PostgreSQL Backend**: Dynamic content management without app rebuilds

## 📦 Latest Release

**Version:** 12.24.0 (Build 156) - **GoKwik Checkout SDK Integration + iOS App Store Ready**  
**Release Date:** January 2025  
**Android APK:** `Eyejack-v12.24.0-Build156-ALL-SCREENS-CHECKOUT.apk`  
**iOS Status:** ✅ Ready for App Store submission

### 🏷️ What's New in v12.24.0 - **GoKwik Checkout SDK Integration + iOS App Store Ready**
- 🛒 **GoKwik SDK Integration**: Full integration with Kwikpass Shopify Plus + Non Plus Flutter SDK
- 📱 **All-Screen Checkout**: GoKwik checkout now works from Home, Collection, and Product Detail screens
- 🔧 **SDK Widget Implementation**: Replaced custom WebView with SDK's official `KPCheckout` widget
- 🎯 **Backend API Integration**: Uses `createGokwikCheckout()` API for proper checkout URL generation
- 📊 **Version Display**: Added version number (v12.24.0 (156)) in app header for cache tracking
- ✅ **Proper Context Handling**: Fixed navigation issues with parent context/navigator management
- 🔄 **Unified Checkout Flow**: All cart icons now use the same GoKwik checkout implementation
- 🎨 **Event Handling**: Proper event callbacks for checkout success, errors, and modal close
- 🍎 **iOS App Store Ready**: 
  - ✅ iOS project configured for release builds
  - ✅ Xcode integration completed
  - ✅ Archive and validation ready
  - ✅ App Store Connect submission prepared
  - 🎯 **Milestone 2 Achieved**: iOS App Store submission capability

### Previous v12.22.2 Features - **Collection Pagination + Swatch Navigation**
- 🎨 **Matrix & Aviator Swatches**: Color swatches parse product titles and instantly navigate to the matching SKU without loaders
- 🧭 **Instant Variant Navigation**: Tapping a swatch triggers `Navigator.pushReplacement` so the selected product opens immediately
- 🖼️ **Image Debugging**: Added gallery + thumbnail logging to verify all product images render
- 📃 **Collection Pagination**: Collections now fetch 50 products at a time with a **Load More Products** button
- 🔁 **Backend Pagination API**: Node middleware now accepts `limit` + `offset`, returns `hasMore`, and logs page diagnostics
- 🧹 **Nuclear Cache Scripts**: Added repeatable scripts for full emulator reboot, uninstall, and reinstall to fight caching

### Previous v8.0.1 Features (Admin Dashboard)
- 🎉 **Admin Dashboard**: Professional web-based dashboard for content management
- 🗄️ **PostgreSQL Integration**: All app content stored in production database
- ⚡ **Real-Time Updates**: Change app content instantly without rebuilds
- 🎨 **Theme Management**: Edit colors, styles, and settings through UI
- 📊 **Section Management**: Add, edit, delete, and reorder app sections

### Previous v6.0.1 Features
- ✅ **BoAt-Style Product Page**: Modern two-button layout (Add To Cart + Select Lens)
- ✅ **Enhanced Price Display**: Price with discount badge and tax information
- ✅ **4 New Homepage Sections**: Feature highlights, statistics, video demo, FAQ
- ✅ **Real Lens Products**: Step 3 shows actual products from Shopify
- ✅ **Railway Deployment**: All backend updates deployed to production

## ✨ Key Features

### 🎨 Admin Dashboard & Content Management (NEW!)
- ✅ **Professional Dashboard**: React-based admin panel with elegant UI
- ✅ **PostgreSQL Backend**: All app content stored in production database
- ✅ **Real-Time Updates**: Change content instantly without app rebuilds
- ✅ **Sections Management**: 
  - View all 9 app sections (announcement bars, hero slider, categories, etc.)
  - Edit section settings with JSON editor
  - Toggle sections active/inactive
  - Delete or reorder sections
  - Create new sections
- ✅ **Theme Settings**: 
  - Edit colors with color picker
  - Modify text and numeric settings
  - Primary color, background, text colors
- ✅ **Live Preview**: See current app configuration with auto-refresh
- ✅ **Dashboard Statistics**: View section counts, active sections, and types
- ✅ **Local Admin Tool**: Secure, runs on your computer only
- ✅ **API-First Architecture**: RESTful admin API endpoints
- ✅ **Instant Deployment**: Changes appear in app on next launch

### 🏪 E-Commerce Functionality
- ✅ **Shopify Integration**: Full integration with Shopify Storefront API v2025-01
- ✅ **Tag-Based Content** (NEW!): Conditional display of product sections using Shopify tags
- ✅ **Dynamic Home Screen**: Real-time product collections, banners, and promotional content
- ✅ **Hero Slider**: Image and video carousel with smooth playback (BoxFit.contain for no cropping)
- ✅ **Product Details**: Complete product information with variant selection and breadcrumbs
- ✅ **Product Specifications**: Smart display based on 'spec' tag - shows only where relevant
- ✅ **In-App Navigation**: All collection/product links navigate within app (no external browser)
- ✅ **Search Functionality**: Product search with icon in header
- ✅ **Smart Cart Management**: Add multiple items (lens + frame) in single transaction
- ✅ **Cart Drawer**: Full-featured cart with item management
- ✅ **GoKwik Checkout Integration**: Full Kwikpass SDK integration with checkout on all screens (Home, Collection, Product Detail)
- ✅ **SDK-Based Checkout**: Uses official GoKwik `KPCheckout` widget with proper event handling
- ✅ **Backend Checkout API**: Integrated with `createGokwikCheckout()` endpoint for secure checkout URL generation

### 🎨 UI/UX Features
- ✅ **BoAt-Style Product Page**: Modern sticky cart with two buttons side by side
- ✅ **Price Display**: Large price with discount badge and "Inclusive of all taxes"
- ✅ **Dual Action Buttons**: "Add To Cart" (black) + "Select Lens" (green)
- ✅ **Modern Product Page**: FireLens-inspired design with clean layouts
- ✅ **Homepage Sections**: 4 beautiful sections at bottom (Features, Stats, Video, FAQ)
- ✅ **Centered Logo**: Eyejack logo centered in header
- ✅ **Announcement Bars**: Unified blue color (#52b1e2) with smaller height (32px)
- ✅ **Moving USP Strip**: Scrolling trust badges (COD, Easy EMI, Easy Return, Support)
- ✅ **Gender Categories**: Image-based category cards for Men/Women/Sale/Unisex
- ✅ **Frame Measurements**: Auto-extracted from product descriptions (lens/bridge/temple)
- ✅ **Collapsible Product Description**: Better mobile readability
- ✅ **Clickable Breadcrumbs**: Navigate back through categories
- ✅ **Enhanced Image Gallery**: Image counter overlay with green-highlighted thumbnails

### 👓 Lens Customization
- ✅ **4-Step Lens Selector**: Intuitive lens customization wizard with modern UI
  - Step 1: Lens Type (Single Vision / Zero Power / Frame Only)
  - Step 2: Power Type (Anti-glare / Blue Block / Colour Lenses)
  - Step 3: **Real Lens Products** from Shopify (filtered by type, same as www.eyejack.in)
  - Step 4: Prescription Entry (Upload / Manual / Email Later)
- ✅ **Enhanced Step Indicators**: Circular badges with connecting lines and active shadows
- ✅ **Modern Header**: Large title, step counter, styled close button
- ✅ **Smart Categorization**: Automatic lens categorization by type
- ✅ **Cart Properties**: Prescription and lens info attached to cart items
- ✅ **Real Product Data**: Fetches actual lens products from Shopify API

### 🚀 Performance & Optimization
- ✅ **Cache-Busting**: Timestamp-based API requests for fresh data
- ✅ **Image Caching**: CachedNetworkImage for all product images
- ✅ **Memory Management**: Single video controller prevents crashes
- ✅ **Debug Logging**: Comprehensive logging for troubleshooting
- ✅ **Error Handling**: User-friendly error messages with retry options

## 📱 Tech Stack

### Frontend (Mobile App)
- **Framework**: Flutter 3.35.2 (Cross-platform: Android + iOS)
- **Language**: Dart 3.9.0
- **Platforms**: 
  - ✅ **Android**: Production-ready APKs
  - ✅ **iOS**: App Store submission ready
- **State Management**: Provider pattern
- **Key Packages**:
  - `http`: API communication
  - `provider`: State management
  - `cached_network_image`: Image caching and loading
  - `flutter_carousel_widget`: Carousel/slider functionality
  - `video_player` + `chewie`: Video playback
  - `gokwik: ^1.0.9`: GoKwik Kwikpass SDK for checkout integration
  - `webview_flutter`: WebView support for checkout
  - `url_launcher`: External links (Instagram, etc.)

### Backend (Middleware)
- **Runtime**: Node.js 18.x
- **Framework**: Express.js
- **Database**: PostgreSQL (Railway)
- **ORM**: Sequelize
- **API Integration**: Shopify Storefront API (GraphQL)
- **Deployment**: Railway (Production)
- **Key Libraries**:
  - `axios`: HTTP client
  - `sequelize`: Database ORM
  - `pg`: PostgreSQL driver
  - `dotenv`: Environment management
  - `cors`: Cross-origin resource sharing

### 🎨 Admin Dashboard (NEW!)
- **Framework**: React 18 + TypeScript
- **Build Tool**: Vite
- **Styling**: Tailwind CSS v4
- **State Management**: React Query (@tanstack/react-query)
- **Routing**: React Router v6
- **Icons**: Lucide React
- **Deployment**: Runs locally for security
- **Key Features**:
  - Dashboard overview with statistics
  - Sections management (CRUD operations)
  - Theme settings editor
  - Live preview of changes
  - Real-time updates to PostgreSQL

### Infrastructure
- **Production Backend**: https://motivated-intuition-production.up.railway.app
- **Database**: PostgreSQL on Railway (crossover.proxy.rlwy.net:31441)
- **Admin Dashboard**: Local (http://localhost:5173)
- **Shopify Store**: eyejack1907.myshopify.com (www.eyejack.in)
- **CDN**: Shopify CDN for all images
- **API Version**: 2025-01

## 🏗️ Architecture

```
┌─────────────────────────────────────────┐
│      Admin Dashboard (Local)            │
│      React + TypeScript + Vite          │
│  ┌───────────────────────────────────┐  │
│  │  Pages                            │  │
│  │  - Dashboard (stats)              │  │
│  │  - Sections (CRUD)                │  │
│  │  - Theme Settings                 │  │
│  │  - Live Preview                   │  │
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │  API Client (Axios + React Query) │  │
│  │  - Real-time updates              │  │
│  │  - Optimistic UI                  │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
                  ▼
        HTTPS - Admin API Calls
                  ▼
┌─────────────────────────────────────────┐
│         Flutter Mobile App              │
│  ┌───────────────────────────────────┐  │
│  │  UI Layer (Screens & Widgets)     │  │
│  │  - Home Screen (sections)         │  │
│  │  - Product Details (breadcrumbs)  │  │
│  │  - Collection Screen              │  │
│  │  - Lens Selector (4 steps)        │  │
│  │  - Cart Drawer                    │  │
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │  Business Logic (Providers)       │  │
│  │  - ShopProvider                   │  │
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │  Data Layer (API Service)         │  │
│  │  - Cache-busting timestamps       │  │
│  │  - API calls to Railway           │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
                  ▼
        HTTP (JSON) - REST API
                  ▼
┌─────────────────────────────────────────┐
│      Railway Cloud (Production)         │
│      Node.js Middleware (Express)       │
│  ┌───────────────────────────────────┐  │
│  │  Routes                           │  │
│  │  - /api/shopify/* (Mobile App)    │  │
│  │  - /api/admin/* (Dashboard)       │  │
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │  Controllers                      │  │
│  │  - shopifyController.js           │  │
│  │  - adminController.js (NEW!)      │  │
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │  Database Layer (Sequelize ORM)  │  │
│  │  - AppSection model               │  │
│  │  - AppTheme model                 │  │
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │  Services                         │  │
│  │  - shopifyService.js              │  │
│  │  - Theme sections builder         │  │
│  │  - Lens categorization            │  │
│  │  - Cart management                │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
         ▼                        ▼
         │                        │
         │                  PostgreSQL
         │                  Database
         │                  (Railway)
         │                 ┌──────────┐
         │                 │ Tables:  │
         │                 │ app_     │
         │                 │ sections │
         │                 │ app_     │
         │                 │ theme    │
         │                 └──────────┘
         │
        GraphQL (Shopify Storefront API)
         ▼
┌─────────────────────────────────────────┐
│       Shopify Store Backend             │
│       (eyejack1907.myshopify.com)       │
│       www.eyejack.in (Live Store)       │
└─────────────────────────────────────────┘
```

### Data Flow

**Admin Updates Content:**
```
Admin Dashboard → Railway API → PostgreSQL → Flutter App (on refresh)
```

**User Views Product:**
```
Flutter App → Railway API → Shopify API → Products → User
```

**Content Management:**
```
1. Admin edits section in dashboard
2. Changes saved to PostgreSQL
3. Flutter app fetches updated data on next launch
4. No app rebuild required!
```

## 📂 Project Structure

```
Eyejack Native Application/
├── eyejack_flutter_app/           # Flutter mobile application
│   ├── lib/
│   │   ├── config/
│   │   │   └── api_config.dart    # Railway production URL
│   │   ├── models/
│   │   │   ├── product_model.dart # Product data models
│   │   │   ├── collection_model.dart
│   │   │   └── section_model.dart
│   │   ├── providers/
│   │   │   └── shop_provider.dart # State management
│   │   ├── screens/
│   │   │   ├── home_screen.dart   # Main home screen
│   │   │   ├── product_detail_screen.dart # Product page
│   │   │   ├── collection_screen.dart
│   │   │   ├── search_screen.dart
│   │   │   └── kp_checkout_screen.dart # GoKwik checkout screen
│   │   ├── services/
│   │   │   ├── api_service.dart   # API calls (cache-busting)
│   │   │   └── gokwik_service.dart
│   │   ├── widgets/
│   │   │   ├── hero_slider_widget.dart    # Video/image carousel
│   │   │   ├── announcement_bars_widget.dart
│   │   │   ├── gender_categories_widget.dart
│   │   │   ├── lens_selector_drawer.dart  # 4-step wizard
│   │   │   ├── sticky_cart_widget.dart
│   │   │   ├── cart_drawer.dart
│   │   │   └── [15+ other widgets]
│   │   └── main.dart              # App entry point
│   ├── android/                   # Android build config
│   └── pubspec.yaml               # Flutter dependencies
│
├── shopify-middleware/            # Node.js backend
│   ├── config/
│   │   └── database.js            # PostgreSQL config (Sequelize)
│   ├── models/
│   │   ├── AppSection.js          # Section data model
│   │   ├── AppTheme.js            # Theme settings model
│   │   └── index.js               # Model exports
│   ├── controllers/
│   │   ├── shopifyController.js   # Mobile app API
│   │   └── adminController.js     # Dashboard API (NEW!)
│   ├── routes/
│   │   ├── shopify.js             # Mobile API routes
│   │   └── admin.js               # Dashboard API routes (NEW!)
│   ├── services/
│   │   └── shopifyService.js      # Shopify API logic
│   ├── scripts/
│   │   └── seedDatabase.js        # Database seeding script
│   ├── server.js                  # Express server
│   ├── package.json               # Node dependencies
│   └── .env                       # Environment variables
│
├── admin-dashboard/               # Admin Dashboard (NEW!)
│   ├── src/
│   │   ├── components/
│   │   │   ├── ui/                # Reusable UI components
│   │   │   │   ├── Button.tsx
│   │   │   │   ├── Card.tsx
│   │   │   │   ├── Input.tsx
│   │   │   │   └── Label.tsx
│   │   │   └── Layout.tsx         # Main layout with sidebar
│   │   ├── pages/
│   │   │   ├── Dashboard.tsx      # Stats overview
│   │   │   ├── Sections.tsx       # Sections CRUD
│   │   │   ├── ThemeSettings.tsx  # Theme editor
│   │   │   └── Preview.tsx        # Live preview
│   │   ├── lib/
│   │   │   ├── api.ts             # API client (Axios)
│   │   │   └── utils.ts           # Helper functions
│   │   ├── App.tsx                # Router setup
│   │   ├── main.tsx               # Entry point
│   │   └── index.css              # Tailwind styles
│   ├── package.json               # React dependencies
│   ├── .env                       # API URL config
│   ├── vite.config.ts             # Vite configuration
│   ├── tailwind.config.js         # Tailwind config
│   ├── README.md                  # Dashboard docs
│   └── HOW_TO_USE.md              # Usage guide
│
├── DASHBOARD_COMPLETE.md          # Dashboard documentation
├── DASHBOARD_QUICK_START.md       # Quick start guide
├── POSTGRESQL_INTEGRATION_SUCCESS.md  # PostgreSQL setup
├── BUILD32_FINAL.md               # Build documentation
├── README.md                      # This file
└── [APK files]                    # Built Android packages
```

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** >= 3.9.0
- **Dart SDK** >= 3.9.0
- **Node.js** >= 18.x
- **npm** or **yarn**
- Android Studio (for Android) or Xcode (for iOS)
- Git

### 1. Clone Repository

```bash
git clone https://github.com/voyageeyewear/eyejack.git
cd "Eyejack Native Application"
```

### 2. Setup Middleware (Node.js Backend)

#### For Local Development:

```bash
cd shopify-middleware
npm install
```

Create `.env` file:

```env
SHOPIFY_STORE_DOMAIN=eyejack1907.myshopify.com
SHOPIFY_ADMIN_ACCESS_TOKEN=shpat_xxxxxxxxxxxxxxxxxxxxx
SHOPIFY_STOREFRONT_ACCESS_TOKEN=xxxxxxxxxxxxxxxxxxxxxxx
SHOPIFY_API_VERSION=2025-01
PORT=3000
```

Start the server:

```bash
npm start
# Server runs on http://localhost:3000
```

#### For Production (Railway):

Backend is already deployed at:
```
https://motivated-intuition-production.up.railway.app
```

Auto-deploys on `git push` to `main` branch.

### 3. Setup Admin Dashboard (Content Management)

The admin dashboard allows you to manage app content without code changes!

#### Installation

```bash
cd admin-dashboard
npm install
```

#### Configuration

The `.env` file should already exist with:

```env
VITE_API_BASE_URL=https://motivated-intuition-production.up.railway.app
```

If not, create it with the above content.

#### Run the Dashboard

```bash
npm run dev
```

Dashboard will be available at: **http://localhost:5173**

#### Using the Dashboard

1. **Dashboard Page** - View statistics and quick actions
2. **Sections Page** - Manage all app sections:
   - Edit section settings (JSON editor)
   - Toggle active/inactive
   - Delete sections
3. **Theme Settings** - Edit colors and styles:
   - Primary color
   - Background color
   - Text color
4. **Preview** - See current app configuration

#### Making Changes

**Example: Change Announcement Bar**
1. Go to Sections page
2. Click edit on "announcement-bars"
3. Modify the text or colors in JSON
4. Click "Save Changes"
5. Close and reopen Flutter app to see changes!

**Example: Change Primary Color**
1. Go to Theme Settings
2. Click color picker next to "Primary Color"
3. Choose new color
4. Click "Save"
5. Done!

> **Important**: The dashboard connects to your **production database** on Railway. All changes are real and will affect the live app!

📚 **For detailed documentation:**
- See `DASHBOARD_QUICK_START.md` for quick start guide
- See `admin-dashboard/HOW_TO_USE.md` for daily usage
- See `DASHBOARD_COMPLETE.md` for technical details

### 4. Setup Flutter App

```bash
cd eyejack_flutter_app
flutter pub get
```

#### Configure API Endpoint

The app is pre-configured for production (Railway):

```dart
// lib/config/api_config.dart
class ApiConfig {
  static const String baseUrl = 'https://motivated-intuition-production.up.railway.app';
}
```

For local development, change to:

```dart
static const String baseUrl = 'http://10.0.2.2:3000'; // Android emulator
// or
static const String baseUrl = 'http://YOUR_LOCAL_IP:3000'; // Physical device
```

### 5. Run the App

#### On Emulator/Simulator

```bash
flutter run
```

#### Build APK for Android

```bash
flutter clean
flutter pub get
flutter build apk --release
```

APK location: `build/app/outputs/flutter-apk/app-release.apk`

#### Install APK on Device

```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

## 🎨 Homepage Sections (In Order)

The app displays sections in this specific order:

1. **Announcement Bars** - Blue promotional banners (#52b1e2)
2. **Header** - Centered logo, menu, search, cart icons
3. **Moving USP Strip** - Scrolling trust badges
4. **Hero Slider** - Videos and images (full width, no cropping)
5. **Category Grid** - 4 quick category boxes
6. **Eyeglasses Section** - Gender categories with CDN images:
   - Men: `https://eyejack.in/cdn/shop/files/im-01.jpg`
   - Women: `https://eyejack.in/cdn/shop/files/im-02.jpg`
   - Sale: `https://eyejack.in/cdn/shop/files/wolf.webp`
   - Unisex: `https://eyejack.in/cdn/shop/files/View_all_New_Launch_Unisex_icon-03.png`
7. **Sunglasses Section** - Gender categories with CDN images:
   - Men: `https://eyejack.in/cdn/shop/files/2502PCL1474-men_3.jpg`
   - Women: `https://eyejack.in/cdn/shop/files/2502PCL1474-women_2.jpg`
   - Sale: `https://eyejack.in/cdn/shop/files/im-07.jpg`
   - Unisex: `https://eyejack.in/cdn/shop/files/View_all_New_Launch_Unisex_icon-03.png`
8. **Diwali Collection** - Featured products
9. **Exclusive Eyewear** - Collection cards
10. **Offers Section** - Promotional offers
11. **Trust Badges** - Footer trust indicators

## 🔧 Configuration

### Android Permissions

Required in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
<application
    android:label="Eyejack"
    android:usesCleartextTraffic="true"
    ...>
```

### API Endpoints

All routes prefixed with `/api/shopify/`:

#### Core Routes
- `GET /api/shopify/theme-sections` - Homepage layout
- `GET /api/shopify/products?limit=50` - All products
- `GET /api/shopify/products/:id` - Single product
- `GET /api/shopify/products/collection/:handle` - Collection products
- `GET /api/shopify/collections` - All collections
- `GET /api/shopify/shop` - Shop info
- `GET /api/shopify/search?q=query` - Product search

#### Lens Routes
- `GET /api/shopify/lens-options` - Categorized lenses
  - Returns: `{ antiGlareLenses, blueBlockLenses, colourLenses, allLenses }`

#### Cart Routes
- `POST /api/shopify/cart/add` - Add single item
- `POST /api/shopify/cart/add-multiple` - Add lens + frame
- `POST /api/shopify/cart/update` - Update quantity
- `POST /api/shopify/cart/remove` - Remove item
- `GET /api/shopify/cart` - Get cart
- `POST /api/shopify/cart/clear` - Clear cart

#### Checkout Routes
- `POST /api/shopify/checkout/create` - Create Shopify checkout
- `POST /api/shopify/checkout/gokwik` - Create GoKwik checkout (returns checkoutUrl, cartId, merchantId)

### Lens Categorization

Automatic categorization by keywords:

- **Anti-glare**: "anti-glare", "anti glare", "antiglare"
- **Blue Block**: "blue", "block", "blu ray", "blue cut"
- **Colour Lenses**: "color", "colour", "tint", "mirror", "gradient"

### Tag-Based Content Management (NEW!)

**How it works:**
Products can conditionally show/hide sections based on Shopify product tags. Currently implemented for Product Specifications section.

**Usage:**

1. **To Show Specifications**:
   - Go to Shopify Admin → Products
   - Select a product
   - Add tag: `spec` (lowercase recommended)
   - Save product
   - Product Specifications section automatically appears in app

2. **To Hide Specifications**:
   - Simply don't add the 'spec' tag
   - Or remove existing 'spec' tag from product
   - Section will be hidden automatically

3. **Case-Insensitive**:
   - Works with: `spec`, `Spec`, `SPEC`, `sPeC`
   - All variations are recognized

4. **Real-Time**:
   - Changes reflect immediately when app fetches fresh data
   - No app rebuild or code changes needed
   - Pure Shopify tag management

**Benefits:**
- ✅ **No Code Required**: Manage content visibility through Shopify admin
- ✅ **Instant Updates**: Changes appear without app rebuilds
- ✅ **Selective Display**: Show specifications only where relevant
- ✅ **Cleaner UX**: Avoid information overload on simple products
- ✅ **Scalable**: Easy to extend to other sections in future

## 📊 Features in Detail

### 1. Hero Slider
- Supports images and MP4 videos
- BoxFit.contain (no cropping)
- In-app navigation for slide links
- Single video controller (memory optimized)
- Auto-play with pause on interaction

### 2. Gender Categories
- Image-based cards with CachedNetworkImage
- Specific CDN URLs from Shopify
- In-app navigation to collections
- Error handling with fallback UI
- Debug logging for troubleshooting

### 3. Product Details
- Breadcrumbs (Home > Category > Product)
- Clickable breadcrumbs for navigation
- Frame measurements extraction (regex)
- Collapsible description (Read more/less)
- Image gallery (BoxFit.contain, no cropping)
- Smaller product title (18px)
- Reduced image margins
- **Tag-Based Specifications**: Product Specifications section only appears on products with 'spec' tag
- **Smart Content Management**: Add/remove 'spec' tag in Shopify to show/hide specifications
- **Case-Insensitive Tags**: Works with 'spec', 'Spec', or 'SPEC'

### 4. 4-Step Lens Selector

**Step 1: Lens Type**
- With power / Single Vision
- Progressive
- Computer Glasses / Blue Cut
- Zero Power

**Step 2: Power Type**
- Anti-glare lenses (shows count)
- Blue Block Lenses (shows count)
- Colour Lenses (shows count)

**Step 3: Select Lens**
- Filtered by power type
- Shows features and pricing
- Real-time Shopify data

**Step 4: Add Power (Optional)**
- SPH, CYL, Axis, ADD fields
- Right (OD) and Left (OS) eyes
- Auto-adds lens + frame to cart

### 5. Cart Management
- Image thumbnails for all items
- Quantity adjustment
- Remove items
- Cart properties preserved
- Total price display
- **GoKwik Checkout Integration**:
  - Works from Home, Collection, and Product Detail screens
  - Uses official GoKwik Kwikpass SDK (`KPCheckout` widget)
  - Backend API integration for secure checkout URL generation
  - Proper event handling (success, error, modal close)
  - Version display in header for cache tracking

## 🐛 Troubleshooting

### Emulator Shows "Error Loading Store" (DNS Issue)
**Issue**: Android emulator can't resolve Railway domain (motivated-intuition-production.up.railway.app)  
**Solution**: Restart emulator with Google DNS servers
```bash
# Kill current emulator
adb emu kill

# Start emulator with DNS fix (replace AVD_NAME with your emulator name)
/Users/ssenterprises/Library/Android/sdk/emulator/emulator -avd AVD_NAME -dns-server 8.8.8.8,8.8.4.4 -no-snapshot &

# Wait for boot, then install APK
adb wait-for-device
adb install -r Eyejack-v12.8.3-Build136-TAG-BASED-SPECS-FINAL.apk
adb shell am start -n com.eyejack.app/.MainActivity
```

**Alternative**: Use `adb root` then set DNS manually
```bash
adb root
adb shell setprop net.dns1 8.8.8.8
adb shell setprop net.dns2 8.8.4.4
```

### App Shows Old Data
**Solution**: Pull down to refresh or clear app data (Settings → Apps → Eyejack → Clear Data)

### Images Not Loading
**Solution**: 
1. Check internet connection
2. Verify Railway backend is running (https://motivated-intuition-production.up.railway.app/health)
3. Pull to refresh
4. If using emulator, check DNS settings (see above)

### Backend Not Responding
**Solution**:
1. Check Railway deployment status
2. Test API health: `curl https://motivated-intuition-production.up.railway.app/health`
3. Expected response: `{"status":"OK","message":"Shopify Middleware API is running"...}`
4. If server is down, redeploy: `git push origin main` (auto-deploys to Railway)

### Videos Cropping
**Fixed**: All videos use BoxFit.contain (no cropping)

### Announcement Colors Changing
**Fixed**: All bars use #52b1e2 in backend

### Gender Category Images Not Showing
**Fixed**: Using specific CDN URLs from eyejack.in

## 🚢 Deployment

### Railway (Production Backend)

Already deployed at: `https://motivated-intuition-production.up.railway.app`

**Auto-deploy on Git push:**
```bash
git add .
git commit -m "Update"
git push origin main
```

Railway detects changes and deploys automatically (60-90 seconds).

**Environment Variables (set in Railway dashboard):**
- `SHOPIFY_STORE_DOMAIN`
- `SHOPIFY_ADMIN_ACCESS_TOKEN`
- `SHOPIFY_STOREFRONT_ACCESS_TOKEN`
- `SHOPIFY_API_VERSION`
- `PORT`

### APK Distribution

**Latest APK**: `Eyejack-v12.22.2-Build154-Pagination.apk`

Build new version:
```bash
# Update version in pubspec.yaml
version: 3.0.0+33  # Increment build number

# Build
flutter clean
flutter pub get
flutter build apk --release

# Copy APK
cp build/app/outputs/flutter-apk/app-release.apk Eyejack-v3.0.0-Build33.apk
```

## 📱 App Releases

### Latest Version: v12.22.2 Build 154 (November 14, 2025)

**🔥 Pagination + Swatches Update:**
- ✅ **Color Swatches**: Matrix + Classic Aviator swatches parse titles, display hardcoded palette, and open the correct product instantly
- ✅ **Instant Navigation**: Removed loading spinners so tapping a swatch immediately navigates via `Navigator.pushReplacement`
- ✅ **Image Gallery Debugging**: Added logging to confirm every image/thumbnail is fetched and rendered
- ✅ **Collection Pagination**: Collection pages now fetch in batches of 50 with a persistent **Load More Products** button
- ✅ **Backend Pagination Support**: Middleware now respects `limit`/`offset`, returns `hasMore`, and logs page stats for debugging
- ✅ **Nuclear Refresh Scripts**: Added `NUCLEAR_EMULATOR_REFRESH.sh` plus install guides for clean testing

### Version v6.0.1 Build 61 (November 5, 2024)

**🎉 BoAt-Style UI Update:**
- ✅ **Modern Sticky Cart**: Two buttons side by side (Add To Cart + Select Lens)
- ✅ **Enhanced Price Display**: Large price with discount badge and tax info
- ✅ **BoAt-Style Layout**: Exactly matches reference image design
- ✅ **Smart Button Logic**: Disabled "Add To Cart" for products requiring lens selection
- ✅ **4 New Homepage Sections**: Features, Statistics, Video Demo, FAQ (at bottom)
- ✅ **Railway Deployment**: Backend updated and deployed to production

### Version v6.0.0 Build 60 (November 5, 2024)

**🎨 Complete FireLens-Style Redesign:**
- ✅ **Product Page Redesign**: Modern white header, review stars, variant selector
- ✅ **Enhanced Image Gallery**: Counter overlay, green-highlighted thumbnails
- ✅ **Prescription Upload Section**: Three prominent options (Upload/Manual/Email)
- ✅ **Product Features Widget**: Icon-based feature cards with descriptions
- ✅ **Specifications Accordion**: Expandable sections for Frame/Lens/Dimensions
- ✅ **Product Videos Section**: Video player support (when available)
- ✅ **FAQ Section**: Collapsible product-specific FAQs
- ✅ **Lens Selector UI**: Enhanced with modern step indicators and shadows
- ✅ **10 New Widgets**: Modular, reusable UI components
- ✅ **2,500+ Lines**: Major code additions for premium experience

**Previous Versions:**
- v5.1.1 Build 53 - Collection page button spacing fix
- v5.1.0 Build 52 - Collection page responsiveness improvements
- v5.0.1 Build 51 - Version bump for cache clearing
- v5.0.0 Build 50 - Collection page redesign with sorting/filtering
- v4.0.0 Build 40-41 - Major UI updates
- v3.0.0 Build 30-36 - Gender categories and cache fixes
- v2.0.0 Build 20-22 - Collection integrations
- v1.0.0 Build 1-9 - Initial releases

## 🔐 Security

- ✅ Store credentials in `.env` (never commit)
- ✅ Storefront API token (read-only)
- ✅ Input validation in middleware
- ✅ HTTPS in production (Railway)
- ✅ CORS configuration

## 🤝 Contributing

1. Fork repository
2. Create feature branch (`git checkout -b feature/Feature`)
3. Commit changes (`git commit -m 'Add Feature'`)
4. Push to branch (`git push origin feature/Feature`)
5. Open Pull Request

## 📄 License

This project is proprietary and confidential.

## 📞 Support

For issues or questions:
- Check `BUILD32_FINAL.md` for latest documentation
- Review troubleshooting section above
- Contact development team

## 🙏 Acknowledgments

- Flutter team for excellent framework
- Shopify for comprehensive Storefront API
- Railway for reliable cloud hosting
- Material Design for UI guidelines

---

**Built with ❤️ for EyeJack**

**Production URL**: https://motivated-intuition-production.up.railway.app  
**Live Store**: www.eyejack.in  
**Latest Android APK**: Eyejack-v12.24.0-Build156-ALL-SCREENS-CHECKOUT.apk  
**iOS Status**: ✅ Ready for App Store submission (v12.24.0 Build 156)  
**Last Updated**: January 2025  
**Current Version**: 12.24.0 (Build 156) - GoKwik Checkout + iOS App Store Ready  
**Milestone 2**: ✅ Achieved - iOS App Store submission ready

### 🎯 Quick Links
- [BoAt-Style Update Summary](BOAT_STYLE_UPDATE.md)
- [FireLens Redesign Details](FIRELENS_REDESIGN_COMPLETE.md)
- [Installation Guide](APK_INSTALL_INSTRUCTIONS.md)
