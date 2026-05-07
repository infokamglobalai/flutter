class PackageModel {
  final String id;
  final String name;
  final List<String> types;
  final String description;
  final List<String> chapters;
  final double totalPrice;
  final int validityDays;
  final String? image;
  final bool isActive;
  final bool isCompetitiveExam;
  final int displayOrder;
  final List<String> grades;
  final PackageDiscount? discount;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  PackageModel({
    required this.id,
    required this.name,
    required this.types,
    required this.description,
    required this.chapters,
    required this.totalPrice,
    required this.validityDays,
    this.image,
    required this.isActive,
    this.isCompetitiveExam = false,
    this.displayOrder = 0,
    this.grades = const [],
    this.discount,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  static String _asString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Map && value.containsKey('_id')) return value['_id'].toString();
    if (value is Map && value.containsKey('id')) return value['id'].toString();
    return value.toString();
  }

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: _asString(json['_id']),
      name: _asString(json['name']),
      types: json['types'] != null
          ? (json['types'] as List<dynamic>).map((e) => _asString(e)).toList()
          : [],
      description: _asString(json['description']),
      chapters: json['chapters'] != null
          ? (json['chapters'] as List<dynamic>)
              .map((e) => _asString(e))
              .toList()
          : [],
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      validityDays: json['validityDays'] as int? ?? 0,
      image: json['image'] != null ? _asString(json['image']) : null,
      isActive: json['isActive'] as bool? ?? false,
      isCompetitiveExam: json['isCompetitiveExam'] as bool? ?? false,
      displayOrder: json['displayOrder'] as int? ?? 0,
      grades: json['grades'] != null
          ? (json['grades'] as List<dynamic>).map((e) => _asString(e)).toList()
          : [],
      discount: json['discount'] != null
          ? PackageDiscount.fromJson(json['discount'] as Map<String, dynamic>)
          : null,
      createdBy: _asString(json['createdBy']),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(_asString(json['createdAt']))
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(_asString(json['updatedAt']))
          : DateTime.now(),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'types': types,
      'description': description,
      'chapters': chapters,
      'totalPrice': totalPrice,
      'validityDays': validityDays,
      'image': image,
      'isActive': isActive,
      'isCompetitiveExam': isCompetitiveExam,
      'displayOrder': displayOrder,
      'grades': grades,
      'discount': discount?.toJson(),
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get imageUrl {
    if (image == null || image!.isEmpty) return '';
    // If it's already a full URL, return as is
    if (image!.startsWith('http')) return image!;
    // Otherwise, prepend the base URL
    return 'https://lms.eduaitutors.com$image';
  }
}

class PackageDiscount {
  final bool isActive;
  final String title;
  final String description;
  final double percentage;
  final List<String> freebies;

  PackageDiscount({
    required this.isActive,
    required this.title,
    required this.description,
    required this.percentage,
    required this.freebies,
  });

  factory PackageDiscount.fromJson(Map<String, dynamic> json) {
    return PackageDiscount(
      isActive: json['isActive'] as bool? ?? false,
      title: PackageModel._asString(json['title']),
      description: PackageModel._asString(json['description']),
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      freebies: json['freebies'] != null
          ? (json['freebies'] as List<dynamic>)
              .map((e) => PackageModel._asString(e))
              .toList()
          : [],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'isActive': isActive,
      'title': title,
      'description': description,
      'percentage': percentage,
      'freebies': freebies,
    };
  }
}
