class VideoContentModel {
  final String id;
  final String chapterId;
  final String title;
  final String description;
  final String videoUrl;
  final String? thumbnail;
  final int duration; // in seconds
  final String quality;
  final bool isActive;
  final int order;

  VideoContentModel({
    required this.id,
    required this.chapterId,
    required this.title,
    required this.description,
    required this.videoUrl,
    this.thumbnail,
    required this.duration,
    required this.quality,
    required this.isActive,
    required this.order,
  });

  factory VideoContentModel.fromJson(Map<String, dynamic> json) {
    return VideoContentModel(
      id: json['id'] ?? '',
      chapterId: json['chapter_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      videoUrl: json['video_url'] ?? '',
      thumbnail: json['thumbnail'],
      duration: json['duration'] ?? 0,
      quality: json['quality'] ?? '720p',
      isActive: json['is_active'] ?? true,
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chapter_id': chapterId,
      'title': title,
      'description': description,
      'video_url': videoUrl,
      'thumbnail': thumbnail,
      'duration': duration,
      'quality': quality,
      'is_active': isActive,
      'order': order,
    };
  }
}

class DocumentContentModel {
  final String id;
  final String chapterId;
  final String title;
  final String description;
  final String documentUrl;
  final String type; // pdf, doc, ppt
  final int pageCount;
  final bool isActive;
  final int order;

  DocumentContentModel({
    required this.id,
    required this.chapterId,
    required this.title,
    required this.description,
    required this.documentUrl,
    required this.type,
    required this.pageCount,
    required this.isActive,
    required this.order,
  });

  factory DocumentContentModel.fromJson(Map<String, dynamic> json) {
    return DocumentContentModel(
      id: json['id'] ?? '',
      chapterId: json['chapter_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      documentUrl: json['document_url'] ?? '',
      type: json['type'] ?? 'pdf',
      pageCount: json['page_count'] ?? 0,
      isActive: json['is_active'] ?? true,
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chapter_id': chapterId,
      'title': title,
      'description': description,
      'document_url': documentUrl,
      'type': type,
      'page_count': pageCount,
      'is_active': isActive,
      'order': order,
    };
  }
}

class PollModel {
  final String id;
  final String chapterId;
  final String question;
  final List<PollOptionModel> options;
  final bool isActive;
  final DateTime? expiresAt;
  final String? userResponse;

  PollModel({
    required this.id,
    required this.chapterId,
    required this.question,
    required this.options,
    required this.isActive,
    this.expiresAt,
    this.userResponse,
  });

  factory PollModel.fromJson(Map<String, dynamic> json) {
    return PollModel(
      id: json['id'] ?? '',
      chapterId: json['chapter_id'] ?? '',
      question: json['question'] ?? '',
      options:
          (json['options'] as List?)
              ?.map((o) => PollOptionModel.fromJson(o))
              .toList() ??
          [],
      isActive: json['is_active'] ?? true,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
      userResponse: json['user_response'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chapter_id': chapterId,
      'question': question,
      'options': options.map((o) => o.toJson()).toList(),
      'is_active': isActive,
      'expires_at': expiresAt?.toIso8601String(),
      'user_response': userResponse,
    };
  }

  bool get hasExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());
  bool get hasResponded => userResponse != null;
}

class PollOptionModel {
  final String id;
  final String text;
  final int voteCount;
  final double votePercentage;

  PollOptionModel({
    required this.id,
    required this.text,
    required this.voteCount,
    required this.votePercentage,
  });

  factory PollOptionModel.fromJson(Map<String, dynamic> json) {
    return PollOptionModel(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      voteCount: json['vote_count'] ?? 0,
      votePercentage: (json['vote_percentage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'vote_count': voteCount,
      'vote_percentage': votePercentage,
    };
  }
}
