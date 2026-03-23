class SubjectModel {
  final String id;
  final String name;
  final SubjectGrade? grade;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SubjectModel({
    required this.id,
    required this.name,
    this.grade,
    this.createdAt,
    this.updatedAt,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      grade: json['grade'] != null
          ? SubjectGrade.fromJson(json['grade'] as Map<String, dynamic>)
          : null,
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
      if (grade != null) 'grade': grade!.toJson(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  // Helper method to get display name
  String get displayName => name;

  // Get icon for subject based on name
  String getIconName() {
    final nameLower = name.toLowerCase();
    if (nameLower.contains('math')) {
      return 'calculate';
    } else if (nameLower.contains('physics') || nameLower.contains('science')) {
      return 'science';
    } else if (nameLower.contains('chemistry')) {
      return 'science';
    } else if (nameLower.contains('biology')) {
      return 'biotech';
    } else if (nameLower.contains('english')) {
      return 'menu_book';
    } else if (nameLower.contains('social')) {
      return 'public';
    } else if (nameLower.contains('computer')) {
      return 'computer';
    } else if (nameLower.contains('hindi') || nameLower.contains('language')) {
      return 'translate';
    } else if (nameLower.contains('sanskrit')) {
      return 'auto_stories';
    } else if (nameLower.contains('environment')) {
      return 'eco';
    } else {
      return 'book';
    }
  }

  // Get color for subject based on name
  String getColorHex() {
    final nameLower = name.toLowerCase();
    if (nameLower.contains('math')) {
      return '0xFF3B82F6'; // Blue
    } else if (nameLower.contains('physics')) {
      return '0xFF10B981'; // Green
    } else if (nameLower.contains('chemistry')) {
      return '0xFFF59E0B'; // Amber
    } else if (nameLower.contains('biology')) {
      return '0xFF84CC16'; // Lime
    } else if (nameLower.contains('english')) {
      return '0xFFEF4444'; // Red
    } else if (nameLower.contains('social')) {
      return '0xFFF59E0B'; // Amber
    } else if (nameLower.contains('computer')) {
      return '0xFF8B5CF6'; // Purple
    } else if (nameLower.contains('hindi')) {
      return '0xFFEC4899'; // Pink
    } else if (nameLower.contains('sanskrit')) {
      return '0xFF06B6D4'; // Cyan
    } else if (nameLower.contains('environment')) {
      return '0xFF84CC16'; // Lime
    } else if (nameLower.contains('science')) {
      return '0xFF10B981'; // Green
    } else {
      return '0xFF6B7280'; // Gray
    }
  }
}

class SubjectGrade {
  final String id;
  final String name;

  SubjectGrade({required this.id, required this.name});

  factory SubjectGrade.fromJson(Map<String, dynamic> json) {
    return SubjectGrade(id: json['_id'] ?? '', name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name};
  }
}
