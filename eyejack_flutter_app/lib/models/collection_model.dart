class Collection {
  final String id;
  final String title;
  final String? description;
  final String handle;
  final CollectionImage? image;

  Collection({
    required this.id,
    required this.title,
    this.description,
    required this.handle,
    this.image,
  });

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      handle: json['handle'] ?? '',
      image: json['image'] != null ? CollectionImage.fromJson(json['image']) : null,
    );
  }
}

class CollectionImage {
  final String src;
  final String? altText;

  CollectionImage({
    required this.src,
    this.altText,
  });

  factory CollectionImage.fromJson(Map<String, dynamic> json) {
    return CollectionImage(
      src: json['src'] ?? '',
      altText: json['altText'],
    );
  }
}

