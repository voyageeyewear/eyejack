class Section {
  final String id;
  final String type;
  final Map<String, dynamic> settings;

  Section({
    required this.id,
    required this.type,
    required this.settings,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      settings: json['settings'] ?? {},
    );
  }
}

class ThemeData {
  final List<Section> layout;
  final ShopInfo? shop;

  ThemeData({
    required this.layout,
    this.shop,
  });

  factory ThemeData.fromJson(Map<String, dynamic> json) {
    return ThemeData(
      layout: json['layout'] != null
          ? (json['layout'] as List).map((s) => Section.fromJson(s)).toList()
          : [],
      shop: json['shop'] != null ? ShopInfo.fromJson(json['shop']) : null,
    );
  }
}

class ShopInfo {
  final String name;
  final String? description;

  ShopInfo({
    required this.name,
    this.description,
  });

  factory ShopInfo.fromJson(Map<String, dynamic> json) {
    return ShopInfo(
      name: json['name'] ?? '',
      description: json['description'],
    );
  }
}

