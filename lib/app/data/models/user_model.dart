class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final String role;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    required this.role,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle both API formats: id/_id, name/firstName+lastName, created_at/createdAt
    final String firstName = json['firstName'] ?? json['first_name'] ?? '';
    final String lastName = json['lastName'] ?? json['last_name'] ?? '';
    final String fullName = firstName.isNotEmpty || lastName.isNotEmpty
        ? '$firstName $lastName'.trim()
        : json['name'] ?? '';

    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: fullName,
      email: json['email'] ?? '',
      phone: json['phone'],
      avatar: (json['avatar'] ?? json['profilePicture'] ?? json['profile_picture'])
          ?.toString(),
      role: json['role'] ?? 'student',
      createdAt: DateTime.parse(
        json['createdAt'] ??
            json['created_at'] ??
            DateTime.now().toIso8601String(),
      ),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatar,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
