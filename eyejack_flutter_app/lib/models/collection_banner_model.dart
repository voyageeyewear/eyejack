class CollectionBanner {
  final int id;
  final String collectionHandle;
  final String bannerPosition;
  final String bannerType;
  final String bannerUrl;
  final String? clickUrl;
  final String? title;
  final String? subtitle;
  final bool isActive;
  final int displayOrder;

  CollectionBanner({
    required this.id,
    required this.collectionHandle,
    required this.bannerPosition,
    required this.bannerType,
    required this.bannerUrl,
    this.clickUrl,
    this.title,
    this.subtitle,
    required this.isActive,
    required this.displayOrder,
  });

  factory CollectionBanner.fromJson(Map<String, dynamic> json) {
    return CollectionBanner(
      id: json['id'],
      collectionHandle: json['collection_handle'],
      bannerPosition: json['banner_position'],
      bannerType: json['banner_type'],
      bannerUrl: json['banner_url'],
      clickUrl: json['click_url'],
      title: json['title'],
      subtitle: json['subtitle'],
      isActive: json['is_active'] ?? true,
      displayOrder: json['display_order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'collection_handle': collectionHandle,
      'banner_position': bannerPosition,
      'banner_type': bannerType,
      'banner_url': bannerUrl,
      'click_url': clickUrl,
      'title': title,
      'subtitle': subtitle,
      'is_active': isActive,
      'display_order': displayOrder,
    };
  }
}

