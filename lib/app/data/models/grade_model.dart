class GradeModel {
  final String id;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  GradeModel({
    required this.id,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  factory GradeModel.fromJson(Map<String, dynamic> json) {
    return GradeModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  // Extract numeric grade from name if it's a standard grade
  int? get numericGrade {
    final match = RegExp(r'Grade (\d+)').firstMatch(name);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }

  // Check if it's a special grade (KG, NEET, etc.)
  bool get isSpecialGrade {
    return !name.startsWith('Grade');
  }

  // Get display text for grade
  String get displayName {
    if (isSpecialGrade) {
      return name;
    }
    return numericGrade?.toString() ?? name;
  }
}
