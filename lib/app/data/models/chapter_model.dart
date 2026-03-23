class ChapterModel {
  final String id;
  final String name;
  final String subjectId;
  final String subjectName;
  final List<BoardInfo> boards;
  final GradeInfo? grade;
  final double price;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ChapterModel({
    required this.id,
    required this.name,
    required this.subjectId,
    required this.subjectName,
    required this.boards,
    this.grade,
    required this.price,
    this.createdAt,
    this.updatedAt,
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    // Handle subject as object
    final subject = json['subject'];
    final subjectId = subject is Map ? subject['_id'] ?? '' : subject ?? '';
    final subjectName = subject is Map ? subject['name'] ?? '' : '';

    // Handle boards array
    final boardsList = json['boards'] as List?;
    List<BoardInfo> boardsInfo = [];
    if (boardsList != null) {
      boardsInfo = boardsList
          .map((board) => BoardInfo.fromJson(board as Map<String, dynamic>))
          .toList();
    }

    // Handle grade
    GradeInfo? gradeInfo;
    if (json['grade'] != null && json['grade'] is Map) {
      gradeInfo = GradeInfo.fromJson(json['grade'] as Map<String, dynamic>);
    }

    return ChapterModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      subjectId: subjectId,
      subjectName: subjectName,
      boards: boardsInfo,
      grade: gradeInfo,
      price: (json['price'] ?? 0).toDouble(),
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
      'subject': {'_id': subjectId, 'name': subjectName},
      'boards': boards.map((b) => b.toJson()).toList(),
      if (grade != null) 'grade': grade!.toJson(),
      'price': price,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  String get displayName => name;
}

class BoardInfo {
  final String id;
  final String name;

  BoardInfo({required this.id, required this.name});

  factory BoardInfo.fromJson(Map<String, dynamic> json) {
    return BoardInfo(id: json['_id'] ?? '', name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name};
  }
}

class GradeInfo {
  final String id;
  final String name;

  GradeInfo({required this.id, required this.name});

  factory GradeInfo.fromJson(Map<String, dynamic> json) {
    return GradeInfo(id: json['_id'] ?? '', name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name};
  }
}

class SubjectChapters {
  final String subject;
  final List<ChapterModel> chapters;

  SubjectChapters({required this.subject, required this.chapters});

  factory SubjectChapters.fromJson(Map<String, dynamic> json) {
    final chaptersList = json['chapters'] as List?;
    List<ChapterModel> chapters = [];
    if (chaptersList != null) {
      chapters = chaptersList
          .map(
            (chapter) => ChapterModel.fromJson(chapter as Map<String, dynamic>),
          )
          .toList();
    }

    return SubjectChapters(subject: json['subject'] ?? '', chapters: chapters);
  }
}
