# EyeJack Native Application

A complete Flutter-based e-commerce mobile application for EyeJack eyewear store, integrated with Shopify Storefront API and featuring a sophisticated lens customization wizard.

## 🎯 Project Overview

EyeJack Native Application is a full-featured mobile e-commerce app that replicates the functionality of the live EyeJack Shopify store (www.eyejack.in) with enhanced mobile-first user experience. The app includes real-time product synchronization, custom lens selection wizard, cart management, and seamless checkout integration.

### Key Features

- ✅ **Shopify Integration**: Full integration with Shopify Storefront API v2025-01
- ✅ **Dynamic Home Screen**: Real-time product collections, banners, and promotional content
- ✅ **Hero Slider**: Image and video carousel with optimized memory management
- ✅ **Product Details**: Complete product information with variant selection
- ✅ **4-Step Lens Selector**: Intuitive lens customization wizard
  - Step 1: Lens Type (Single Vision / Progressive / Computer / Zero Power)
  - Step 2: Power Type (Anti-glare / Blue Block / Colour Lenses)
  - Step 3: Lens Selection (Filtered by power type)
  - Step 4: Optional Prescription Entry
- ✅ **Smart Cart Management**: Add multiple items (lens + frame) in single transaction
- ✅ **Cart Drawer**: Full-featured cart with item management
- ✅ **Checkout Integration**: Seamless Gokwik checkout integration

## 📱 Tech Stack

### Frontend (Mobile App)
- **Framework**: Flutter 3.x
- **Language**: Dart
- **State Management**: Provider pattern
- **Key Packages**:
  - `http`: API communication
  - `provider`: State management
  - `cached_network_image`: Image caching
  - `flutter_carousel_widget`: Carousel/slider
  - `video_player` + `chewie`: Video playback
  - `url_launcher`: External links

### Backend (Middleware)
- **Runtime**: Node.js
- **Framework**: Express.js
- **API Integration**: Shopify Storefront API (GraphQL)
- **Key Libraries**:
  - `axios`: HTTP client
  - `dotenv`: Environment management
  - `cors`: Cross-origin resource sharing

## 🏗️ Architecture

```
┌─────────────────────────────────────────┐
│         Flutter Mobile App              │
│  ┌───────────────────────────────────┐  │
│  │  UI Layer (Widgets)               │  │
│  │  - Home Screen                    │  │
│  │  - Product Details                │  │
│  │  - Lens Selector (4 steps)        │  │
│  │  - Cart Drawer                    │  │
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │  Business Logic (Providers)       │  │
│  │  - ShopProvider                   │  │
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │  Data Layer (API Service)         │  │
│  │  - API calls to middleware        │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
                   ▼
         HTTP (JSON) - REST API
                   ▼
┌─────────────────────────────────────────┐
│      Node.js Middleware (Express)       │
│  ┌───────────────────────────────────┐  │
│  │  Routes                           │  │
│  │  - /api/shopify/*                 │  │
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │  Controllers                      │  │
│  │  - shopifyController.js           │  │
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │  Services                         │  │
│  │  - shopifyService.js              │  │
│  │  - Lens categorization            │  │
│  │  - Cart management                │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
                   ▼
         GraphQL (Shopify Storefront API)
                   ▼
┌─────────────────────────────────────────┐
│       Shopify Store Backend             │
│       (eyejack1907.myshopify.com)       │
└─────────────────────────────────────────┘
```

## 📂 Project Structure

```
Eyejack Native Application/
├── eyejack_flutter_app/           # Flutter mobile application
│   ├── lib/
│   │   ├── config/
│   │   │   └── api_config.dart    # API endpoints configuration
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
│   │   │   └── search_screen.dart
│   │   ├── services/
│   │   │   └── api_service.dart   # API calls to middleware
│   │   ├── widgets/
│   │   │   ├── hero_slider_widget.dart    # Image/video carousel
│   │   │   ├── lens_selector_drawer.dart  # 4-step lens wizard
│   │   │   ├── sticky_cart_widget.dart    # Fixed cart button
│   │   │   ├── cart_drawer.dart           # Shopping cart UI
│   │   │   ├── section_renderer.dart      # Dynamic sections
│   │   │   └── [15 other widgets]
│   │   └── main.dart              # App entry point
│   ├── android/                   # Android build config
│   ├── ios/                       # iOS build config
│   └── pubspec.yaml               # Flutter dependencies
│
├── shopify-middleware/            # Node.js backend
│   ├── controllers/
│   │   └── shopifyController.js   # Request handlers
│   ├── routes/
│   │   └── shopify.js             # API routes
│   ├── services/
│   │   └── shopifyService.js      # Shopify API logic
│   ├── server.js                  # Express server
│   └── package.json               # Node dependencies
│
├── README.md                      # This file
└── [APK files]                    # Built Android packages
```

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** >= 3.0.0
- **Dart SDK** >= 3.0.0
- **Node.js** >= 18.x
- **npm** or **yarn**
- Android Studio (for Android) or Xcode (for iOS)
- Git

### 1. Clone Repository

```bash
git clone <repository-url>
cd "Eyejack Native Application"
```

### 2. Setup Middleware (Node.js Backend)

```bash
cd shopify-middleware
npm install
```

Create `.env` file in `shopify-middleware/`:

```env
SHOPIFY_STORE_URL=eyefrejacrwfk1907.myshopify.com
SHOPIFY_STOREFRONT_TOKEN=003ddg2c08rg9ead4ar22dfbfaa0ffcbbdfgfrgadcc97fr44rgg43cgh
SHOPIFY_API_VERSION=2025-01
PORT=3000
```

Start the middleware:

```bash
node server.js
```

The server will run on `http://localhost:3000` (or `http://0.0.0.0:3000`)

### 3. Setup Flutter App

```bash
cd eyejack_flutter_app
flutter pub get
```

#### Configure API Endpoint

For **local development** on Android emulator, edit `lib/config/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:3000';
}
```

For **physical device** or **production**, use your server IP:

```dart
class ApiConfig {
  static const String baseUrl = 'http://YOUR_SERVER_IP:3000';
}
```

### 4. Run the App

#### On Emulator/Simulator

```bash
flutter run
```

#### Build APK for Android

```bash
flutter build apk --release
```

APK location: `build/app/outputs/flutter-apk/app-release.apk`

#### Install APK on Device

```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

## 🔧 Configuration

### Android Permissions

Required permissions in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
<application
    android:usesCleartextTraffic="true"
    ...>
```

### API Endpoints

All API routes are prefixed with `/api/shopify/`:

#### Product & Collection Routes
- `GET /api/shopify/products` - Get all products
- `GET /api/shopify/products/:id` - Get product by ID
- `GET /api/shopify/collections` - Get all collections
- `GET /api/shopify/collections/:handle` - Get collection by handle
- `GET /api/shopify/home-data` - Get home screen data

#### Lens Routes
- `GET /api/shopify/lens-options` - Get categorized lens products
  - Returns: `{ antiGlareLenses, blueBlockLenses, colourLenses, allLenses }`

#### Cart Routes
- `POST /api/shopify/cart/add` - Add single item to cart
- `POST /api/shopify/cart/add-multiple` - Add multiple items (lens + frame)
- `POST /api/shopify/cart/update` - Update cart item quantity
- `POST /api/shopify/cart/remove` - Remove item from cart
- `GET /api/shopify/cart` - Get current cart
- `POST /api/shopify/cart/clear` - Clear cart

#### Checkout Routes
- `POST /api/shopify/checkout/create` - Create checkout session

### Lens Categorization Logic

The middleware automatically categorizes lens products based on keywords in product descriptions and titles:

- **Anti-glare lenses**: Contains "anti-glare", "anti glare", or "antiglare"
- **Blue Block lenses**: Contains "blue", "block", "blu ray", or "blue cut"
- **Colour Lenses**: Contains "color", "colour", "tint", "mirror", or "gradient"

## 🎨 Features in Detail

### 1. Hero Slider
- Supports both images and videos
- Optimized memory management (single video controller)
- Auto-play with pause on interaction
- Full-width responsive layout
- Smooth transitions

### 2. 4-Step Lens Selector

**Step 1: Lens Type**
- With power / Single Vision
- Progressive
- Computer Glasses / Blue Cut
- Zero Power

**Step 2: Power Type**
- Anti-glare lenses (shows count badge)
- Blue Block Lenses (shows count badge)
- Colour Lenses (shows count badge)

**Step 3: Select Lens Package**
- Dynamically filtered based on selected power type
- Shows lens name, features, and price
- Real-time data from Shopify

**Step 4: Add Power (Optional)**
- Optional prescription entry fields
- SPH (Sphere), CYL (Cylinder), Axis, ADD values
- Separate fields for Right (OD) and Left (OS) eyes
- "Save and Continue" button auto-adds lens + frame to cart

### 3. Cart Management

**Features:**
- View all cart items with images
- Update quantities
- Remove items
- See total price (supports ₹ currency)
- Properties/attributes preserved (lens selection details)
- Quick checkout button

**API Flow:**
```
Add Lens + Frame → POST /api/shopify/cart/add-multiple
                   ├─ Item 1: Lens with properties
                   │   └─ 1. Lens Type
                   │   └─ 2. Power Type
                   │   └─ 3. Lens Name
                   │   └─ 4. Prescription Type
                   │   └─ Power values (if entered)
                   │   └─ Associated Frame ID
                   │
                   └─ Item 2: Frame (no properties)
```

### 4. Shopify Integration

**GraphQL Queries:**
- Product listings with variants
- Collection browsing
- Lens product filtering
- Cart operations (create, add, update, remove)
- Checkout creation

**Error Handling:**
- Shopify `userErrors` detection
- Proper variant ID validation
- Retry logic for network errors

## 🐛 Troubleshooting

### Common Issues

#### 1. "Connection refused" or 404 errors
- **Cause**: Middleware not running or wrong API endpoint
- **Fix**: 
  - Ensure middleware is running (`node server.js`)
  - For Android emulator, use `10.0.2.2` instead of `localhost`
  - Check `api_config.dart` has correct URL

#### 2. "Merchandise does not exist" error
- **Cause**: Invalid product variant ID
- **Fix**: Middleware now correctly extracts variant IDs from lens products

#### 3. Video playback issues / App crashes
- **Cause**: Multiple video controllers consuming memory
- **Fix**: Implemented in `hero_slider_widget.dart` - single controller pattern

#### 4. Lens products not showing
- **Cause**: Products missing `lens` tag in Shopify
- **Fix**: Add `lens` tag to all lens products in Shopify admin

#### 5. Cart items missing properties
- **Cause**: Properties not passed correctly
- **Fix**: Use `addMultipleToCart` endpoint with properties object

## 📊 Performance Optimizations

1. **Image Caching**: `cached_network_image` for all product images
2. **Lazy Loading**: Products load on-demand as user scrolls
3. **Memory Management**: Single video controller prevents OutOfMemoryError
4. **API Response Caching**: Middleware caches lens products in memory
5. **Minimal Rebuilds**: Provider pattern for efficient state updates

## 🔐 Security Notes

- Store credentials in `.env` file (never commit to Git)
- Use Storefront API token (read-only), not Admin API
- Validate all user inputs in middleware
- HTTPS recommended for production deployment

## 🚢 Deployment

### Deploy Middleware to Railway

1. Create Railway account at [railway.app](https://railway.app)
2. Connect GitHub repository
3. Add environment variables in Railway dashboard
4. Deploy automatically on push

### Update Flutter App for Production

```dart
// lib/config/api_config.dart
class ApiConfig {
  static const String baseUrl = 'https://your-railway-app.railway.app';
}
```

## 📱 App Releases

### Version History

- **v1.0.0** - Initial release with 4-step lens selector
  - Full Shopify integration
  - Product browsing and details
  - Lens customization wizard
  - Cart management
  - Checkout integration

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## 📄 License

This project is proprietary and confidential.

## 📞 Support

For issues or questions, contact the development team.

## 🙏 Acknowledgments

- Flutter team for excellent framework
- Shopify for comprehensive API
- Material Design for UI guidelines

---

**Built with ❤️ for EyeJack**

**Last Updated**: October 29, 2025

