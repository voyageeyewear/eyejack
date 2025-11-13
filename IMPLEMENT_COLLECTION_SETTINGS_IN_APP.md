# How to Implement Collection Settings in Your Flutter App

**Status**: ✅ Provider Created & Registered  
**Next**: Apply Settings to UI Elements

---

## ✅ What's Already Done

1. ✅ **Provider Created**: `CollectionSettingsProvider`
2. ✅ **Provider Registered**: Added to `main.dart`
3. ✅ **Auto-loads**: Settings fetch automatically on app start

---

## 🎯 How to Use in Collection Screen

### Step 1: Access Settings in Your Widget

At the top of your `_CollectionScreenState` class `build` method, add:

```dart
@override
Widget build(BuildContext context) {
  // Get settings from provider
  final settingsProvider = Provider.of<CollectionSettingsProvider>(context);
  final settings = settingsProvider.settings;
  
  // Your existing build code...
}
```

### Step 2: Apply Settings to Product Cards

Find where you build product cards (likely in a `GridView` or `ListView`), and apply settings:

#### Product Title
**Find this:**
```dart
Text(
  product.title,
  style: TextStyle(fontSize: 16),
)
```

**Replace with:**
```dart
Text(
  product.title,
  style: TextStyle(
    fontSize: settings.titleFontSize.toDouble(),
    color: Color(CollectionPageSettings.hexToColor(settings.titleColor)),
    fontFamily: settings.titleFontFamily,
  ),
)
```

#### Price
**Find this:**
```dart
Text(
  '₹${product.price}',
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
)
```

**Replace with:**
```dart
Text(
  '₹${product.price}',
  style: TextStyle(
    fontSize: settings.priceFontSize.toDouble(),
    color: Color(CollectionPageSettings.hexToColor(settings.priceColor)),
    fontWeight: FontWeight.bold,
  ),
)
```

#### Original Price (with visibility toggle)
**Find this:**
```dart
Text(
  '₹${product.compareAtPrice}',
  style: TextStyle(
    decoration: TextDecoration.lineThrough,
    color: Colors.grey,
  ),
)
```

**Replace with:**
```dart
if (settings.showOriginalPrice && product.compareAtPrice != null)
  Text(
    '₹${product.compareAtPrice}',
    style: TextStyle(
      decoration: TextDecoration.lineThrough,
      fontSize: (settings.priceFontSize - 2).toDouble(),
      color: Color(CollectionPageSettings.hexToColor(settings.originalPriceColor)),
    ),
  )
```

#### EMI Badge (with visibility toggle)
**Find EMI badge code or add this:**
```dart
if (settings.showEMI)
  Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Color(CollectionPageSettings.hexToColor(settings.emiBadgeColor)),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      'EMI Available',
      style: TextStyle(
        fontSize: settings.emiFontSize.toDouble(),
        color: Color(CollectionPageSettings.hexToColor(settings.emiTextColor)),
        fontWeight: FontWeight.w500,
      ),
    ),
  )
```

#### Stock Badge (with visibility toggle)
```dart
if (settings.showInStock)
  Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Color(CollectionPageSettings.hexToColor(
        product.availableForSale 
          ? settings.inStockBadgeColor 
          : settings.outOfStockBadgeColor
      )),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      product.availableForSale ? 'In Stock' : 'Out of Stock',
      style: TextStyle(
        fontSize: 11,
        color: Color(CollectionPageSettings.hexToColor(
          product.availableForSale 
            ? settings.inStockTextColor 
            : settings.outOfStockTextColor
        )),
        fontWeight: FontWeight.w500,
      ),
    ),
  )
```

#### Discount Badge (with visibility toggle)
```dart
if (settings.showDiscountBadge && product.compareAtPrice != null)
  Positioned(
    top: 8,
    right: 8,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Color(CollectionPageSettings.hexToColor(settings.discountBadgeColor)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '${calculateDiscount(product)}% OFF',
        style: TextStyle(
          fontSize: 12,
          color: Color(CollectionPageSettings.hexToColor(settings.discountTextColor)),
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  )
```

### Step 3: Apply Settings to Buttons

#### Add to Cart Button
**Find this:**
```dart
ElevatedButton(
  onPressed: () => _addToCart(product),
  child: Text('Add to Cart'),
)
```

**Replace with:**
```dart
ElevatedButton(
  onPressed: () => _addToCart(product),
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(CollectionPageSettings.hexToColor(settings.addToCartButtonColor)),
    foregroundColor: Color(CollectionPageSettings.hexToColor(settings.addToCartTextColor)),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(settings.buttonBorderRadius.toDouble()),
    ),
  ),
  child: Text(
    'Add to Cart',
    style: TextStyle(
      fontSize: settings.buttonFontSize.toDouble(),
    ),
  ),
)
```

#### Select Lens Button
**Find this:**
```dart
ElevatedButton(
  onPressed: () => _showLensSelector(product),
  child: Text('Select Lens'),
)
```

**Replace with:**
```dart
ElevatedButton(
  onPressed: () => _showLensSelector(product),
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(CollectionPageSettings.hexToColor(settings.selectLensButtonColor)),
    foregroundColor: Color(CollectionPageSettings.hexToColor(settings.selectLensTextColor)),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(settings.buttonBorderRadius.toDouble()),
    ),
  ),
  child: Text(
    'Select Lens',
    style: TextStyle(
      fontSize: settings.buttonFontSize.toDouble(),
    ),
  ),
)
```

### Step 4: Apply Settings to Product Cards

**Find your Card widget:**
```dart
Card(
  child: Column(
    children: [
      // Product content
    ],
  ),
)
```

**Replace with:**
```dart
Card(
  color: Color(CollectionPageSettings.hexToColor(settings.cardBackgroundColor)),
  elevation: settings.cardElevation.toDouble(),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(settings.cardBorderRadius.toDouble()),
    side: BorderSide(
      color: Color(CollectionPageSettings.hexToColor(settings.cardBorderColor)),
      width: 1,
    ),
  ),
  child: Padding(
    padding: EdgeInsets.all(settings.cardPadding.toDouble()),
    child: Column(
      children: [
        // Product content
      ],
    ),
  ),
)
```

### Step 5: Apply Spacing Between Items

**In your GridView:**
```dart
GridView.builder(
  padding: EdgeInsets.all(settings.itemSpacing.toDouble()),
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: settings.itemSpacing.toDouble(),
    mainAxisSpacing: settings.itemSpacing.toDouble(),
    childAspectRatio: 0.7,
  ),
  // ...
)
```

### Step 6: Ratings (with visibility toggle)

**If you have ratings:**
```dart
if (settings.showRatings && product.rating != null)
  Row(
    children: List.generate(5, (index) {
      return Icon(
        index < product.rating! ? Icons.star : Icons.star_border,
        size: 16,
        color: Color(CollectionPageSettings.hexToColor(settings.ratingStarColor)),
      );
    }),
  )
```

---

## 🔄 Pull to Refresh Settings

Add a refresh mechanism so users can reload settings without restarting the app:

```dart
RefreshIndicator(
  onRefresh: () async {
    final settingsProvider = Provider.of<CollectionSettingsProvider>(context, listen: false);
    await settingsProvider.refresh();
    await _loadProducts(); // Reload your products too
  },
  child: // Your existing ListView/GridView
)
```

---

## 🎨 Complete Example: Product Card

Here's a complete product card example with all settings applied:

```dart
Widget _buildProductCard(Product product, CollectionPageSettings settings) {
  return Card(
    color: Color(CollectionPageSettings.hexToColor(settings.cardBackgroundColor)),
    elevation: settings.cardElevation.toDouble(),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(settings.cardBorderRadius.toDouble()),
      side: BorderSide(
        color: Color(CollectionPageSettings.hexToColor(settings.cardBorderColor)),
        width: 1,
      ),
    ),
    child: InkWell(
      onTap: () => _navigateToProduct(product),
      child: Padding(
        padding: EdgeInsets.all(settings.cardPadding.toDouble()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Discount Badge
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: product.image,
                  fit: BoxFit.cover,
                  height: 200,
                  width: double.infinity,
                ),
                // Discount Badge
                if (settings.showDiscountBadge && product.compareAtPrice != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(CollectionPageSettings.hexToColor(settings.discountBadgeColor)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${_calculateDiscount(product)}% OFF',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(CollectionPageSettings.hexToColor(settings.discountTextColor)),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            SizedBox(height: 8),
            
            // Title
            Text(
              product.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: settings.titleFontSize.toDouble(),
                color: Color(CollectionPageSettings.hexToColor(settings.titleColor)),
                fontFamily: settings.titleFontFamily,
              ),
            ),
            
            SizedBox(height: 4),
            
            // Ratings
            if (settings.showRatings && product.rating != null)
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < product.rating! ? Icons.star : Icons.star_border,
                    size: 14,
                    color: Color(CollectionPageSettings.hexToColor(settings.ratingStarColor)),
                  );
                }),
              ),
            
            SizedBox(height: 4),
            
            // Price Row
            Row(
              children: [
                Text(
                  '₹${product.price}',
                  style: TextStyle(
                    fontSize: settings.priceFontSize.toDouble(),
                    color: Color(CollectionPageSettings.hexToColor(settings.priceColor)),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (settings.showOriginalPrice && product.compareAtPrice != null) ...[
                  SizedBox(width: 8),
                  Text(
                    '₹${product.compareAtPrice}',
                    style: TextStyle(
                      decoration: TextDecoration.lineThrough,
                      fontSize: (settings.priceFontSize - 2).toDouble(),
                      color: Color(CollectionPageSettings.hexToColor(settings.originalPriceColor)),
                    ),
                  ),
                ],
              ],
            ),
            
            SizedBox(height: 8),
            
            // Badges Row
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // EMI Badge
                if (settings.showEMI)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(CollectionPageSettings.hexToColor(settings.emiBadgeColor)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'EMI',
                      style: TextStyle(
                        fontSize: settings.emiFontSize.toDouble(),
                        color: Color(CollectionPageSettings.hexToColor(settings.emiTextColor)),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                
                // Stock Badge
                if (settings.showInStock)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(CollectionPageSettings.hexToColor(
                        product.availableForSale 
                          ? settings.inStockBadgeColor 
                          : settings.outOfStockBadgeColor
                      )),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      product.availableForSale ? 'In Stock' : 'Out of Stock',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(CollectionPageSettings.hexToColor(
                          product.availableForSale 
                            ? settings.inStockTextColor 
                            : settings.outOfStockTextColor
                        )),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            
            SizedBox(height: 12),
            
            // Buttons Row
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _addToCart(product),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(CollectionPageSettings.hexToColor(settings.addToCartButtonColor)),
                      foregroundColor: Color(CollectionPageSettings.hexToColor(settings.addToCartTextColor)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(settings.buttonBorderRadius.toDouble()),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Add to Cart',
                      style: TextStyle(
                        fontSize: settings.buttonFontSize.toDouble(),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showLensSelector(product),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(CollectionPageSettings.hexToColor(settings.selectLensButtonColor)),
                      foregroundColor: Color(CollectionPageSettings.hexToColor(settings.selectLensTextColor)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(settings.buttonBorderRadius.toDouble()),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Select Lens',
                      style: TextStyle(
                        fontSize: settings.buttonFontSize.toDouble(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

// Helper function to calculate discount percentage
int _calculateDiscount(Product product) {
  if (product.compareAtPrice == null || product.compareAtPrice == 0) return 0;
  final discount = ((product.compareAtPrice! - product.price) / product.compareAtPrice!) * 100;
  return discount.round();
}
```

---

## 🧪 Testing Your Implementation

### 1. Hot Restart the App
```bash
# In your terminal where Flutter is running
r  # for hot restart
```

### 2. Navigate to Collection Screen
- Open app
- Go to any collection page

### 3. Test Settings Changes
1. **In Dashboard**: Change a color (e.g., make "Add to Cart" button red)
2. **Save Changes** in dashboard
3. **In App**: Pull down to refresh OR force close and reopen
4. **Verify**: Button should be red now!

---

## 🎯 Quick Test Checklist

Test each setting:
- [ ] Title color changes
- [ ] Price color changes
- [ ] Button colors change
- [ ] EMI badge hides when toggled off
- [ ] Stock badge hides when toggled off
- [ ] Discount badge hides when toggled off
- [ ] Card border radius changes
- [ ] Button border radius changes
- [ ] Spacing between items changes
- [ ] Font sizes change

---

## 🐛 Troubleshooting

### Changes Not Appearing?
1. **Force close** the app (don't just background it)
2. **Reopen** the app
3. Settings load automatically on app start

### Still Not Working?
Check console logs:
```
🔄 Loading collection settings...
✅ Collection settings loaded successfully
```

If you see errors, check your internet connection and Railway backend status.

---

## 📝 Summary

**What You Need to Do:**
1. ✅ Provider is already set up
2. 📝 Copy-paste code examples into your `collection_screen.dart`
3. 🔄 Hot restart the app
4. 🎨 Test changes in dashboard
5. ✅ See changes in app!

**The beauty of this system:**
- ✅ No app rebuild needed
- ✅ Just save in dashboard
- ✅ Pull to refresh in app
- ✅ Changes appear instantly!

Start with just applying button colors first, then gradually add the rest! 🚀

