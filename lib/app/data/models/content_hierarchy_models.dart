class BoardModel {
  final String id;
  final String name;
  final String description;
  final String? icon;
  final bool isActive;
  final int order;

  BoardModel({
    required this.id,
    required this.name,
    required this.description,
    this.icon,
    required this.isActive,
    required this.order,
  });

  factory BoardModel.fromJson(Map<String, dynamic> json) {
    return BoardModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'],
      isActive: json['is_active'] ?? true,
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'is_active': isActive,
      'order': order,
    };
  }
}

class GradeModel {
  final String id;
  final String boardId;
  final String name;
  final String description;
  final String? icon;
  final bool isActive;
  final int order;

  GradeModel({
    required this.id,
    required this.boardId,
    required this.name,
    required this.description,
    this.icon,
    required this.isActive,
    required this.order,
  });

  factory GradeModel.fromJson(Map<String, dynamic> json) {
    return GradeModel(
      id: json['id'] ?? '',
      boardId: json['board_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'],
      isActive: json['is_active'] ?? true,
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'board_id': boardId,
      'name': name,
      'description': description,
      'icon': icon,
      'is_active': isActive,
      'order': order,
    };
  }
}

class SubjectModel {
  final String id;
  final String gradeId;
  final String name;
  final String description;
  final String? icon;
  final String? color;
  final bool isActive;
  final int order;

  SubjectModel({
    required this.id,
    required this.gradeId,
    required this.name,
    required this.description,
    this.icon,
    this.color,
    required this.isActive,
    required this.order,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'] ?? '',
      gradeId: json['grade_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'],
      color: json['color'],
      isActive: json['is_active'] ?? true,
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'grade_id': gradeId,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'is_active': isActive,
      'order': order,
    };
  }
}

class ChapterModel {
  final String id;
  final String subjectId;
  final String name;
  final String description;
  final String? thumbnail;
  final int duration; // in minutes
  final bool isActive;
  final bool isFree;
  final int order;

  ChapterModel({
    required this.id,
    required this.subjectId,
    required this.name,
    required this.description,
    this.thumbnail,
    required this.duration,
    required this.isActive,
    required this.isFree,
    required this.order,
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      id: json['id'] ?? '',
      subjectId: json['subject_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      thumbnail: json['thumbnail'],
      duration: json['duration'] ?? 0,
      isActive: json['is_active'] ?? true,
      isFree: json['is_free'] ?? false,
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject_id': subjectId,
      'name': name,
      'description': description,
      'thumbnail': thumbnail,
      'duration': duration,
      'is_active': isActive,
      'is_free': isFree,
      'order': order,
    };
  }
}
