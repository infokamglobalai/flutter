class Doubt {
  final String id;
  final String ticketNumber;
  final String userId;
  final String category;
  final String subject;
  final String? subjectId;
  final String? chapterId;
  final String chapter;
  final String question;
  final String description;
  final String status;
  final String priority;
  final User? user;
  final User? assignedTo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;
  final DateTime? closedAt;
  final List<DoubtResponse> responses;
  final Map<String, dynamic>? metadata;

  Doubt({
    required this.id,
    required this.ticketNumber,
    required this.userId,
    required this.category,
    required this.subject,
    this.subjectId,
    this.chapterId,
    required this.chapter,
    required this.question,
    required this.description,
    required this.status,
    required this.priority,
    this.user,
    this.assignedTo,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
    this.closedAt,
    this.responses = const [],
    this.metadata,
  });

  factory Doubt.fromJson(Map<String, dynamic> json) {
    return Doubt(
      id: json['_id'] ?? '',
      ticketNumber: json['ticketNumber'] ?? '',
      userId: json['userId'] is String ? json['userId'] : json['userId']?['_id'] ?? '',
      category: json['category'] ?? 'subjectRelated',
      subject: json['subject'] ?? '',
      subjectId: json['subjectId'],
      chapterId: json['chapterId'],
      chapter: json['description'] ?? '',
      question: json['subject'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'open',
      priority: json['priority'] ?? 'medium',
      user: json['userId'] is Map ? User.fromJson(json['userId']) : null,
      assignedTo: json['assignedTo'] != null ? User.fromJson(json['assignedTo']) : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt']) : null,
      closedAt: json['closedAt'] != null ? DateTime.parse(json['closedAt']) : null,
      responses: json['responses'] != null
          ? (json['responses'] as List).map((r) => DoubtResponse.fromJson(r)).toList()
          : [],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'ticketNumber': ticketNumber,
      'userId': userId,
      'category': category,
      'subject': subject,
      'subjectId': subjectId,
      'chapterId': chapterId,
      'description': description,
      'status': status,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'closedAt': closedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  bool get isPending => status == 'open' || status == 'in-progress';
  bool get isAnswered => status == 'resolved' || status == 'closed';
  
  String get mentorName => assignedTo?.fullName ?? 'Support Team';
  
  String get mentorResponse {
    if (responses.isEmpty) return '';
    final staffResponses = responses.where((r) => r.isStaffResponse).toList();
    return staffResponses.isNotEmpty ? staffResponses.last.message : '';
  }
  
  DateTime? get mentorTimestamp {
    if (responses.isEmpty) return null;
    final staffResponses = responses.where((r) => r.isStaffResponse).toList();
    return staffResponses.isNotEmpty ? staffResponses.last.createdAt : null;
  }
  
  int get repliesCount => responses.length;
}

class DoubtResponse {
  final String id;
  final String ticketId;
  final String userId;
  final User? user;
  final String message;
  final bool isStaffResponse;
  final bool isInternal;
  final List<String> attachments;
  final DateTime createdAt;
  final DateTime updatedAt;

  DoubtResponse({
    required this.id,
    required this.ticketId,
    required this.userId,
    this.user,
    required this.message,
    required this.isStaffResponse,
    required this.isInternal,
    this.attachments = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory DoubtResponse.fromJson(Map<String, dynamic> json) {
    return DoubtResponse(
      id: json['_id'] ?? '',
      ticketId: json['ticketId'] ?? '',
      userId: json['userId'] is String ? json['userId'] : json['userId']?['_id'] ?? '',
      user: json['userId'] is Map ? User.fromJson(json['userId']) : null,
      message: json['message'] ?? '',
      isStaffResponse: json['isStaffResponse'] ?? false,
      isInternal: json['isInternal'] ?? false,
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'])
          : [],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'ticketId': ticketId,
      'userId': userId,
      'message': message,
      'isStaffResponse': isStaffResponse,
      'isInternal': isInternal,
      'attachments': attachments,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class User {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String role;
  final bool isEmailVerified;

  User({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    required this.role,
    required this.isEmailVerified,
  });

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return firstName ?? lastName ?? email.split('@').first;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
      phone: json['phone'],
      role: json['role'] ?? 'student',
      isEmailVerified: json['isEmailVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'role': role,
      'isEmailVerified': isEmailVerified,
    };
  }
}
