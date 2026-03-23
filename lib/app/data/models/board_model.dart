class BoardModel {
  final String id;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BoardModel({
    required this.id,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  factory BoardModel.fromJson(Map<String, dynamic> json) {
    return BoardModel(
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

  // Helper method to get display name
  String get displayName => name;

  // Get icon for board
  String getIconName() {
    switch (name.toUpperCase()) {
      case 'CBSE':
        return 'school';
      case 'ICSE':
        return 'menu_book';
      case 'IGCSE':
      case 'IB':
        return 'public';
      case 'JEE':
      case 'NEET':
        return 'science';
      case 'STATE BOARD':
        return 'location_city';
      default:
        return 'more_horiz';
    }
  }

  // Get color for board
  String getColorHex() {
    switch (name.toUpperCase()) {
      case 'CBSE':
        return '0xFF3B82F6'; // Blue
      case 'ICSE':
        return '0xFF10B981'; // Green
      case 'IGCSE':
      case 'IB':
        return '0xFF8B5CF6'; // Purple
      case 'JEE':
        return '0xFFEF4444'; // Red
      case 'NEET':
        return '0xFF06B6D4'; // Cyan
      case 'STATE BOARD':
        return '0xFFF59E0B'; // Amber
      default:
        return '0xFF6B7280'; // Gray
    }
  }
}
