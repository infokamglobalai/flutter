class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final DateTime? readAt;
  final String priority;
  final NotificationMetadata? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    this.readAt,
    required this.priority,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? json['id'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      isRead: json['isRead'] ?? false,
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      priority: json['priority'] ?? 'medium',
      metadata: json['metadata'] != null
          ? NotificationMetadata.fromJson(json['metadata'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
      'priority': priority,
      'metadata': metadata?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  NotificationModel copyWith({
    String? id,
    String? type,
    String? title,
    String? message,
    bool? isRead,
    DateTime? readAt,
    String? priority,
    NotificationMetadata? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      priority: priority ?? this.priority,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class NotificationMetadata {
  final String? action;
  final String? actionUrl;
  final String? resourceId;
  final String? resourceType;
  final String? imageUrl;
  final String? audioUrl;

  NotificationMetadata({
    this.action,
    this.actionUrl,
    this.resourceId,
    this.resourceType,
    this.imageUrl,
    this.audioUrl,
  });

  factory NotificationMetadata.fromJson(Map<String, dynamic> json) {
    return NotificationMetadata(
      action: json['action'],
      actionUrl: json['actionUrl'],
      resourceId: json['resourceId'],
      resourceType: json['resourceType'],
      imageUrl: json['imageUrl'],
      audioUrl: json['audioUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'actionUrl': actionUrl,
      'resourceId': resourceId,
      'resourceType': resourceType,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
    };
  }
}
