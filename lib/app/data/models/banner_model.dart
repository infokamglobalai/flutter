class BannerModel {
  final String id;
  final String title;
  final String description;
  final String image;
  final bool isActive;
  final int order;
  final String linkType; // none | internal | external
  final String internalRoute;
  final Map<String, dynamic> internalParams;
  final String externalUrl;

  BannerModel({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.isActive,
    required this.order,
    required this.linkType,
    required this.internalRoute,
    required this.internalParams,
    required this.externalUrl,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> asMap(dynamic v) {
      if (v is Map<String, dynamic>) return v;
      if (v is Map) return Map<String, dynamic>.from(v);
      return <String, dynamic>{};
    }

    return BannerModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
      isActive: json['isActive'] == true,
      order: int.tryParse((json['order'] ?? 0).toString()) ?? 0,
      linkType: (json['linkType'] ?? 'none').toString(),
      internalRoute: (json['internalRoute'] ?? '').toString(),
      internalParams: asMap(json['internalParams']),
      externalUrl: (json['externalUrl'] ?? '').toString(),
    );
  }

  String get imageUrl {
    final raw = image.trim();
    if (raw.isEmpty) return '';
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    if (raw.startsWith('/uploads/')) return 'https://lms.eduaitutors.com$raw';
    if (raw.startsWith('/')) return 'https://lms.eduaitutors.com/uploads$raw';
    return 'https://lms.eduaitutors.com/uploads/$raw';
  }
}

