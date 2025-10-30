# Railway Environment Variables Setup

## 🚨 IMPORTANT: Update These Variables on Railway

Go to your Railway project: https://railway.app/

Then click on your **shopify-middleware** service → **Variables** tab

## Required Environment Variables:

```
SHOPIFY_STORE_DOMAIN=eyejack1907.myshopify.com
SHOPIFY_STOREFRONT_ACCESS_TOKEN=<your-storefront-token>
SHOPIFY_ADMIN_ACCESS_TOKEN=<your-admin-token>
SHOPIFY_API_VERSION=2025-01
PORT=3000
GOKWIK_MERCHANT_ID=<your-merchant-id>
GOKWIK_ENV=prod
NODE_ENV=production
```

## ⚠️ CRITICAL NOTES:

1. Variable names MUST match exactly:
   - `SHOPIFY_STORE_DOMAIN` (NOT `SHOPIFY_STORE_URL`)
   - `SHOPIFY_STOREFRONT_ACCESS_TOKEN` (NOT `SHOPIFY_STOREFRONT_TOKEN`)
   - `SHOPIFY_ADMIN_ACCESS_TOKEN` (required for cart operations)

2. After updating variables, click **"Deploy"** or wait for automatic redeploy

3. Test the deployment:
   ```bash
   curl https://motivated-intuition-production.up.railway.app/api/shopify/shop
   ```

## ✅ Expected Response:

```json
{
  "success": true,
  "data": {
    "name": "Eyejack Eyewear",
    "description": "...",
    "primaryDomain": {
      "url": "https://eyejack.in",
      "host": "eyejack.in"
    }
  }
}
```

## 📱 Flutter App Configuration:

The app is now configured to use:
```
https://motivated-intuition-production.up.railway.app
```

This will work on:
- ✅ Android Emulator
- ✅ iOS Simulator
- ✅ Real Android Devices
- ✅ Real iOS Devices

No localhost needed!

