class StudentProfileModel {
  final String id;
  final String userId;
  final String fullName;
  final String board;
  final String grade;
  final String state;
  final String city;
  final String phone;
  final List<dynamic> enrolledCourses;
  final Map<String, dynamic> progress;
  final DateTime createdAt;
  final DateTime updatedAt;

  StudentProfileModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.board,
    required this.grade,
    required this.state,
    required this.city,
    required this.phone,
    required this.enrolledCourses,
    required this.progress,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StudentProfileModel.fromJson(Map<String, dynamic> json) {
    return StudentProfileModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      fullName: json['fullName'] ?? '',
      board: json['board'] ?? '',
      grade: json['grade'] ?? '',
      state: json['state'] ?? '',
      city: json['city'] ?? '',
      phone: json['phone'] ?? '',
      enrolledCourses: json['enrolledCourses'] ?? [],
      progress: json['progress'] ?? {},
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
      'userId': userId,
      'fullName': fullName,
      'board': board,
      'grade': grade,
      'state': state,
      'city': city,
      'phone': phone,
      'enrolledCourses': enrolledCourses,
      'progress': progress,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  StudentProfileModel copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? board,
    String? grade,
    String? state,
    String? city,
    String? phone,
    List<dynamic>? enrolledCourses,
    Map<String, dynamic>? progress,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudentProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      board: board ?? this.board,
      grade: grade ?? this.grade,
      state: state ?? this.state,
      city: city ?? this.city,
      phone: phone ?? this.phone,
      enrolledCourses: enrolledCourses ?? this.enrolledCourses,
      progress: progress ?? this.progress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
