class MentorProfileModel {
  final String id;
  final String email;
  final String phone;
  final String role;
  final String firstName;
  final String lastName;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final bool isActive;
  final bool isSystemSuperAdmin;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLogin;
  final List<BoardItem> boards;
  final List<GradeItem> grades;
  final List<SubjectItem> subjects;
  final List<String> specialization;
  final int experience;
  final String? bio;
  final double rating;
  final bool isVerified;

  MentorProfileModel({
    required this.id,
    required this.email,
    required this.phone,
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    required this.isActive,
    required this.isSystemSuperAdmin,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.lastLogin,
    required this.boards,
    required this.grades,
    required this.subjects,
    required this.specialization,
    required this.experience,
    this.bio,
    required this.rating,
    required this.isVerified,
  });

  String get fullName => '$firstName $lastName';

  factory MentorProfileModel.fromJson(Map<String, dynamic> json) {
    return MentorProfileModel(
      id: json['_id'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      isEmailVerified: json['isEmailVerified'] ?? false,
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      isActive: json['isActive'] ?? false,
      isSystemSuperAdmin: json['isSystemSuperAdmin'] ?? false,
      metadata: json['metadata'] ?? {},
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'])
          : null,
      boards:
          (json['boards'] as List<dynamic>?)
              ?.map((e) => BoardItem.fromJson(e))
              .toList() ??
          [],
      grades:
          (json['grades'] as List<dynamic>?)
              ?.map((e) => GradeItem.fromJson(e))
              .toList() ??
          [],
      subjects:
          (json['subjects'] as List<dynamic>?)
              ?.map((e) => SubjectItem.fromJson(e))
              .toList() ??
          [],
      specialization:
          (json['specialization'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      experience: json['experience'] ?? 0,
      bio: json['bio'],
      rating: (json['rating'] ?? 0).toDouble(),
      isVerified: json['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'phone': phone,
      'role': role,
      'firstName': firstName,
      'lastName': lastName,
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'isActive': isActive,
      'isSystemSuperAdmin': isSystemSuperAdmin,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'boards': boards.map((e) => e.toJson()).toList(),
      'grades': grades.map((e) => e.toJson()).toList(),
      'subjects': subjects.map((e) => e.toJson()).toList(),
      'specialization': specialization,
      'experience': experience,
      'bio': bio,
      'rating': rating,
      'isVerified': isVerified,
    };
  }
}

class BoardItem {
  final String id;
  final String name;

  BoardItem({required this.id, required this.name});

  factory BoardItem.fromJson(Map<String, dynamic> json) {
    return BoardItem(id: json['_id'] ?? '', name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name};
  }
}

class GradeItem {
  final String id;
  final String name;

  GradeItem({required this.id, required this.name});

  factory GradeItem.fromJson(Map<String, dynamic> json) {
    return GradeItem(id: json['_id'] ?? '', name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name};
  }
}

class SubjectItem {
  final String id;
  final String name;

  SubjectItem({required this.id, required this.name});

  factory SubjectItem.fromJson(Map<String, dynamic> json) {
    return SubjectItem(id: json['_id'] ?? '', name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name};
  }
}
