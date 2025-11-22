class Review {
  final String id;
  final String name;
  final String text;
  final double? rating; // 1-5 stars, nullable
  final String? date;
  final List<String> photos;
  final bool isVerified;

  Review({
    required this.id,
    required this.name,
    required this.text,
    this.rating,
    this.date,
    this.photos = const [],
    this.isVerified = false,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Anonymous',
      text: json['text']?.toString() ?? '',
      rating: json['rating'] != null ? (json['rating'] is int ? json['rating'].toDouble() : json['rating'] as double) : null,
      date: json['date']?.toString(),
      photos: json['photos'] != null 
          ? List<String>.from(json['photos'].map((p) => p.toString()))
          : [],
      isVerified: json['isVerified'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'text': text,
      'rating': rating,
      'date': date,
      'photos': photos,
      'isVerified': isVerified,
    };
  }
}

class ProductReviews {
  final String productId;
  final String productTitle;
  final String productHandle;
  final int count;
  final double averageRating;
  final List<Review> reviews;

  ProductReviews({
    required this.productId,
    required this.productTitle,
    required this.productHandle,
    required this.count,
    required this.averageRating,
    required this.reviews,
  });

  factory ProductReviews.fromJson(Map<String, dynamic> json) {
    return ProductReviews(
      productId: json['productId']?.toString() ?? '',
      productTitle: json['productTitle']?.toString() ?? '',
      productHandle: json['productHandle']?.toString() ?? '',
      count: json['count'] is int ? json['count'] : (int.tryParse(json['count']?.toString() ?? '0') ?? 0),
      averageRating: json['averageRating'] is double 
          ? json['averageRating'] 
          : (double.tryParse(json['averageRating']?.toString() ?? '0') ?? 0.0),
      reviews: json['reviews'] != null
          ? (json['reviews'] as List).map((r) => Review.fromJson(r as Map<String, dynamic>)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productTitle': productTitle,
      'productHandle': productHandle,
      'count': count,
      'averageRating': averageRating,
      'reviews': reviews.map((r) => r.toJson()).toList(),
    };
  }
}

class ReviewCount {
  final int count;
  final double rating;

  ReviewCount({
    required this.count,
    required this.rating,
  });

  factory ReviewCount.fromJson(Map<String, dynamic> json) {
    return ReviewCount(
      count: json['count'] is int ? json['count'] : (int.tryParse(json['count']?.toString() ?? '0') ?? 0),
      rating: json['rating'] is double 
          ? json['rating'] 
          : (double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'rating': rating,
    };
  }
}

