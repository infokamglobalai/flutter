class WorksheetModel {
  final String id;
  final String title;
  final GradeInfo grade;
  final BoardInfo board;
  final SubjectInfo subject;
  final ChapterInfo chapter;
  final String filePath;
  final String fileName;
  final int fileSize;
  final String mimeType;
  final int academicYear;
  final bool isActive;
  final CreatedByInfo createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  WorksheetModel({
    required this.id,
    required this.title,
    required this.grade,
    required this.board,
    required this.subject,
    required this.chapter,
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    required this.mimeType,
    required this.academicYear,
    required this.isActive,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WorksheetModel.fromJson(Map<String, dynamic> json) {
    return WorksheetModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      grade: GradeInfo.fromJson(json['grade'] ?? {}),
      board: BoardInfo.fromJson(json['board'] ?? {}),
      subject: SubjectInfo.fromJson(json['subject'] ?? {}),
      chapter: ChapterInfo.fromJson(json['chapter'] ?? {}),
      filePath: json['filePath'] ?? '',
      fileName: json['fileName'] ?? '',
      fileSize: json['fileSize'] ?? 0,
      mimeType: json['mimeType'] ?? '',
      academicYear: json['academicYear'] ?? 0,
      isActive: json['isActive'] ?? false,
      createdBy: CreatedByInfo.fromJson(json['createdBy'] ?? {}),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'grade': grade.toJson(),
      'board': board.toJson(),
      'subject': subject.toJson(),
      'chapter': chapter.toJson(),
      'filePath': filePath,
      'fileName': fileName,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'academicYear': academicYear,
      'isActive': isActive,
      'createdBy': createdBy.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get formattedFileSize {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
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

class SubjectInfo {
  final String id;
  final String name;

  SubjectInfo({required this.id, required this.name});

  factory SubjectInfo.fromJson(Map<String, dynamic> json) {
    return SubjectInfo(id: json['_id'] ?? '', name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name};
  }
}

class ChapterInfo {
  final String id;
  final String name;

  ChapterInfo({required this.id, required this.name});

  factory ChapterInfo.fromJson(Map<String, dynamic> json) {
    return ChapterInfo(id: json['_id'] ?? '', name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name};
  }
}

class CreatedByInfo {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String fullName;

  CreatedByInfo({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
  });

  factory CreatedByInfo.fromJson(Map<String, dynamic> json) {
    return CreatedByInfo(
      id: json['_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      fullName: json['fullName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
    };
  }
}

class WorksheetPagination {
  final int page;
  final int limit;
  final int total;
  final int pages;

  WorksheetPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  factory WorksheetPagination.fromJson(Map<String, dynamic> json) {
    return WorksheetPagination(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      total: json['total'] ?? 0,
      pages: json['pages'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {'page': page, 'limit': limit, 'total': total, 'pages': pages};
  }
}

class WorksheetResponse {
  final bool success;
  final List<WorksheetModel> data;
  final WorksheetPagination pagination;

  WorksheetResponse({
    required this.success,
    required this.data,
    required this.pagination,
  });

  factory WorksheetResponse.fromJson(Map<String, dynamic> json) {
    return WorksheetResponse(
      success: json['success'] ?? false,
      data:
          (json['data'] as List?)
              ?.map((item) => WorksheetModel.fromJson(item))
              .toList() ??
          [],
      pagination: WorksheetPagination.fromJson(json['pagination'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((item) => item.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}
