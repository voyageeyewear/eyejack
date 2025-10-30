class Product {
  final String id;
  final String title;
  final String description;
  final String? descriptionHtml;
  final String handle;
  final String? vendor;
  final String? productType;
  final List<String> tags;
  final bool availableForSale;
  final List<ProductImage> images;
  final PriceRange priceRange;
  final List<ProductVariant> variants;

  Product({
    required this.id,
    required this.title,
    required this.description,
    this.descriptionHtml,
    required this.handle,
    this.vendor,
    this.productType,
    required this.tags,
    required this.availableForSale,
    required this.images,
    required this.priceRange,
    required this.variants,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      descriptionHtml: json['descriptionHtml'],
      handle: json['handle'] ?? '',
      vendor: json['vendor'],
      productType: json['productType'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      availableForSale: json['availableForSale'] ?? true,
      images: json['images'] != null
          ? (json['images'] as List)
              .map((img) => ProductImage.fromJson(img))
              .toList()
          : [],
      priceRange: PriceRange.fromJson(json['priceRange'] ?? {}),
      variants: json['variants'] != null
          ? (json['variants'] as List)
              .map((v) => ProductVariant.fromJson(v))
              .toList()
          : [],
    );
  }
}

class ProductImage {
  final String src;
  final String? altText;

  ProductImage({
    required this.src,
    this.altText,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      src: json['src'] ?? '',
      altText: json['altText'],
    );
  }
}

class PriceRange {
  final Price minVariantPrice;
  final Price? maxVariantPrice;

  PriceRange({
    required this.minVariantPrice,
    this.maxVariantPrice,
  });

  factory PriceRange.fromJson(Map<String, dynamic> json) {
    return PriceRange(
      minVariantPrice: json['minVariantPrice'] != null
          ? Price.fromJson(json['minVariantPrice'])
          : Price(amount: '0', currencyCode: 'USD'),
      maxVariantPrice: json['maxVariantPrice'] != null
          ? Price.fromJson(json['maxVariantPrice'])
          : null,
    );
  }
}

class Price {
  final String amount;
  final String currencyCode;

  Price({
    required this.amount,
    required this.currencyCode,
  });

  factory Price.fromJson(Map<String, dynamic> json) {
    return Price(
      amount: json['amount']?.toString() ?? '0',
      currencyCode: json['currencyCode'] ?? 'USD',
    );
  }

  String get formatted {
    final double value = double.tryParse(amount) ?? 0;
    // Use rupee symbol for INR, no decimals for Indian currency
    if (currencyCode == 'INR') {
      return '₹${value.toStringAsFixed(0)}';
    }
    return '\$${value.toStringAsFixed(2)}';
  }
}

class ProductVariant {
  final String id;
  final String title;
  final bool availableForSale;
  final Price price;
  final Price? compareAtPrice;

  ProductVariant({
    required this.id,
    required this.title,
    required this.availableForSale,
    required this.price,
    this.compareAtPrice,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      availableForSale: json['availableForSale'] ?? true,
      price: Price.fromJson(json['price'] ?? {}),
      compareAtPrice: json['compareAtPrice'] != null
          ? Price.fromJson(json['compareAtPrice'])
          : null,
    );
  }
}

