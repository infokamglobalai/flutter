class ChapterResourceModel {
  final String id;
  final ChapterInfo chapter;
  final String title;
  final String description;
  final String filePath;
  final String fileName;
  final int fileSize;
  final String mimeType;
  final bool isActive;
  final CreatedBy createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? packageType;

  ChapterResourceModel({
    required this.id,
    required this.chapter,
    required this.title,
    required this.description,
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    required this.mimeType,
    required this.isActive,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.packageType,
  });

  factory ChapterResourceModel.fromJson(Map<String, dynamic> json) {
    return ChapterResourceModel(
      id: json['_id'] ?? '',
      chapter: ChapterInfo.fromJson(json['chapter'] ?? {}),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      filePath: json['filePath'] ?? '',
      fileName: json['fileName'] ?? '',
      fileSize: json['fileSize'] ?? 0,
      mimeType: json['mimeType'] ?? '',
      isActive: json['isActive'] ?? true,
      createdBy: CreatedBy.fromJson(json['createdBy'] ?? {}),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      packageType: json['packageType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'chapter': chapter.toJson(),
      'title': title,
      'description': description,
      'filePath': filePath,
      'fileName': fileName,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'isActive': isActive,
      'createdBy': createdBy.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'packageType': packageType,
    };
  }

  String get fileUrl {
    if (filePath.startsWith('http')) return filePath;
    return 'https://lms.eduaitutors.com/$filePath';
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

class ChapterInfo {
  final String id;
  final String name;
  final String subject;
  final String grade;
  final List<String> boards;

  ChapterInfo({
    required this.id,
    required this.name,
    required this.subject,
    required this.grade,
    required this.boards,
  });

  factory ChapterInfo.fromJson(Map<String, dynamic> json) {
    return ChapterInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      subject: json['subject'] ?? '',
      grade: json['grade'] ?? '',
      boards:
          (json['boards'] as List<dynamic>?)
              ?.map((b) => b.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'subject': subject,
      'grade': grade,
      'boards': boards,
    };
  }
}

class CreatedBy {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String fullName;

  CreatedBy({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
  });

  factory CreatedBy.fromJson(Map<String, dynamic> json) {
    return CreatedBy(
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
