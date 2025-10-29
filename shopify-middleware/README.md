# Shopify Middleware API

Backend API service that connects your Flutter mobile app to your Shopify store.

## Features

- ✅ Fetch theme sections and homepage layout
- ✅ Get products, collections, and shop info
- ✅ Search functionality
- ✅ Storefront API integration
- ✅ CORS enabled for mobile app access

## Setup

### 1. Install Dependencies

```bash
npm install
```

### 2. Configure Environment

The `.env` file is already configured with your store credentials:
- Store: eyejack1907.myshopify.com
- All API tokens are set up

### 3. Run the Server

**Development mode (with auto-reload):**
```bash
npm run dev
```

**Production mode:**
```bash
npm start
```

The API will run on `http://localhost:3000`

## API Endpoints

### Health Check
```
GET /health
```

### Theme Sections
```
GET /api/shopify/theme-sections
```
Returns homepage layout with sections (hero, collections, products, etc.)

### Products
```
GET /api/shopify/products?limit=50
GET /api/shopify/products/:id
GET /api/shopify/products/collection/:handle
```

### Collections
```
GET /api/shopify/collections
GET /api/shopify/collections/:handle
```

### Shop Info
```
GET /api/shopify/shop
```

### Search
```
GET /api/shopify/search?q=sunglasses
```

## Testing

Test the API:
```bash
curl http://localhost:3000/health
curl http://localhost:3000/api/shopify/products
curl http://localhost:3000/api/shopify/collections
```

## Deploy to Production

You can deploy this to:
- **Render** (recommended - free tier available)
- **Railway**
- **Heroku**
- **AWS/GCP/Azure**

Make sure to update your Flutter app's API URL after deployment.

