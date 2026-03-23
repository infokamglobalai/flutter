class ChapterContentModel {
  final String id;
  final ChapterInfo chapter;
  final String title;
  final String videoType;
  final String videoUrl;
  final String uploadedVideoPath;
  final String overview;
  final List<ResourceInfo> resources;
  final int order;
  final String? packageType;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? assessment;

  ChapterContentModel({
    required this.id,
    required this.chapter,
    required this.title,
    required this.videoType,
    required this.videoUrl,
    required this.uploadedVideoPath,
    required this.overview,
    required this.resources,
    required this.order,
    this.packageType,
    required this.isActive,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.assessment,
  });

  factory ChapterContentModel.fromJson(Map<String, dynamic> json) {
    return ChapterContentModel(
      id: json['_id'] ?? '',
      chapter: ChapterInfo.fromJson(json['chapter'] ?? {}),
      title: json['title'] ?? '',
      videoType: json['videoType'] ?? 'youtube',
      videoUrl: json['videoUrl'] ?? '',
      uploadedVideoPath: json['uploadedVideoPath'] ?? '',
      overview: json['overview'] ?? '',
      resources:
          (json['resources'] as List<dynamic>?)
              ?.map((r) => ResourceInfo.fromJson(r))
              .toList() ??
          [],
      order: json['order'] ?? 0,
      packageType: json['packageType'],
      isActive: json['isActive'] ?? true,
      createdBy: json['createdBy'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      assessment: json['assessment'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'chapter': chapter.toJson(),
      'title': title,
      'videoType': videoType,
      'videoUrl': videoUrl,
      'uploadedVideoPath': uploadedVideoPath,
      'overview': overview,
      'resources': resources.map((r) => r.toJson()).toList(),
      'order': order,
      'packageType': packageType,
      'isActive': isActive,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'assessment': assessment,
      'updatedAt': updatedAt.toIso8601String(),
    };
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

class ResourceInfo {
  final String id;
  final String title;
  final String filePath;
  final String fileName;

  ResourceInfo({
    required this.id,
    required this.title,
    required this.filePath,
    required this.fileName,
  });

  factory ResourceInfo.fromJson(Map<String, dynamic> json) {
    return ResourceInfo(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      filePath: json['filePath'] ?? '',
      fileName: json['fileName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'filePath': filePath,
      'fileName': fileName,
    };
  }
}
