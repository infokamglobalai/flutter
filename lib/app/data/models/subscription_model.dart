class SubscriptionModel {
  final String id;
  final String student;
  final PackageInfo package;
  final String packageType;
  final BoardInfo board;
  final GradeInfo grade;
  final List<SubjectInfo> subjects;
  final List<ChapterInfo> chapters;
  final double totalPrice;
  final double paidAmount;
  final double discountApplied;
  final DateTime? endDate;
  final bool isActive;
  final String paymentStatus;
  final String paymentMethod;
  final String? transactionId;
  final List<PaymentHistory> paymentHistory;
  final DateTime startDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubscriptionModel({
    required this.id,
    required this.student,
    required this.package,
    required this.packageType,
    required this.board,
    required this.grade,
    required this.subjects,
    required this.chapters,
    required this.totalPrice,
    required this.paidAmount,
    required this.discountApplied,
    this.endDate,
    required this.isActive,
    required this.paymentStatus,
    required this.paymentMethod,
    this.transactionId,
    required this.paymentHistory,
    required this.startDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    String _asString(dynamic v) {
      if (v == null) return '';
      if (v is String) return v;
      if (v is num || v is bool) return v.toString();
      if (v is Map) {
        final id = v['_id'] ?? v['id'] ?? v['value'];
        if (id is String) return id;
        if (id != null) return id.toString();
      }
      return v.toString();
    }

    DateTime _asDate(dynamic v) {
      if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);
      if (v is DateTime) return v;
      if (v is String && v.isNotEmpty) {
        return DateTime.tryParse(v) ?? DateTime.fromMillisecondsSinceEpoch(0);
      }
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    DateTime? _asNullableDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
      return null;
    }

    Map<String, dynamic> _asMap(dynamic v) {
      if (v is Map<String, dynamic>) return v;
      if (v is Map) return Map<String, dynamic>.from(v as Map);
      // Sometimes backend returns an id string instead of a populated object.
      if (v is String && v.isNotEmpty) return {'_id': v};
      return const <String, dynamic>{};
    }

    return SubscriptionModel(
      id: _asString(json['_id']),
      student: _asString(json['student']),
      package: PackageInfo.fromJson(_asMap(json['package'])),
      packageType: _asString(json['packageType']),
      board: BoardInfo.fromJson(_asMap(json['board'])),
      grade: GradeInfo.fromJson(_asMap(json['grade'])),
      subjects:
          (json['subjects'] as List?)
              ?.map((s) => SubjectInfo.fromJson(_asMap(s)))
              .toList() ??
          [],
      chapters:
          (json['chapters'] as List?)
              ?.map((c) => ChapterInfo.fromJson(_asMap(c)))
              .toList() ??
          [],
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      paidAmount: (json['paidAmount'] ?? 0).toDouble(),
      discountApplied: (json['discountApplied'] ?? 0).toDouble(),
      endDate: _asNullableDate(json['endDate']),
      isActive: json['isActive'] ?? false,
      paymentStatus: _asString(json['paymentStatus']),
      paymentMethod: _asString(json['paymentMethod']),
      transactionId: json['transactionId'] == null
          ? null
          : _asString(json['transactionId']),
      paymentHistory:
          (json['paymentHistory'] as List?)
              ?.map((p) => PaymentHistory.fromJson(_asMap(p)))
              .toList() ??
          [],
      startDate: _asDate(json['startDate']),
      createdAt: _asDate(json['createdAt']),
      updatedAt: _asDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'student': student,
      'package': package.toJson(),
      'packageType': packageType,
      'board': board.toJson(),
      'grade': grade.toJson(),
      'subjects': subjects.map((s) => s.toJson()).toList(),
      'chapters': chapters.map((c) => c.toJson()).toList(),
      'totalPrice': totalPrice,
      'paidAmount': paidAmount,
      'discountApplied': discountApplied,
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'paymentHistory': paymentHistory.map((p) => p.toJson()).toList(),
      'startDate': startDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper methods
  int get totalVideos {
    // Each chapter has one video
    return chapters.length;
  }

  int get totalAssessments {
    return chapters.length;
  }

  int get totalExercises {
    // Each chapter has one exercise
    return chapters.length;
  }

  double get progress {
    if (chapters.isEmpty) return 0.0;
    final completedChapters = chapters.where((c) => c.videoCompleted).length;
    return completedChapters / chapters.length;
  }
}

class PackageInfo {
  final String id;
  final String name;
  final List<String> types;
  final String description;
  final String? image;

  PackageInfo({
    required this.id,
    required this.name,
    required this.types,
    required this.description,
    this.image,
  });

  factory PackageInfo.fromJson(Map<String, dynamic> json) {
    return PackageInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      types: (json['types'] as List?)?.map((t) => t.toString()).toList() ?? [],
      description: json['description'] ?? '',
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'types': types,
      'description': description,
      'image': image,
    };
  }

  String get imageUrl {
    final img = (image ?? '').toString().trim();
    if (img.isEmpty) return '';
    if (img.startsWith('http')) return img;
    return 'https://lms.eduaitutors.com$img';
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
  final SubjectInfo subject;
  final String? grade;
  final List<String> boards;
  final double price;
  final bool videoCompleted;

  ChapterInfo({
    required this.id,
    required this.name,
    required this.subject,
    this.grade,
    required this.boards,
    required this.price,
    this.videoCompleted = false,
  });

  factory ChapterInfo.fromJson(Map<String, dynamic> json) {
    String _asString(dynamic v) {
      if (v == null) return '';
      if (v is String) return v;
      if (v is num || v is bool) return v.toString();
      if (v is Map) {
        final id = v['_id'] ?? v['id'] ?? v['value'];
        if (id is String) return id;
        if (id != null) return id.toString();
      }
      return v.toString();
    }

    return ChapterInfo(
      id: _asString(json['_id']),
      name: _asString(json['name']),
      subject: SubjectInfo.fromJson(
        json['subject'] is Map ? Map<String, dynamic>.from(json['subject']) : {},
      ),
      grade: json['grade'] == null ? null : _asString(json['grade']),
      boards:
          (json['boards'] as List?)
                  ?.map((b) => _asString(b))
                  .where((s) => s.isNotEmpty)
                  .toList() ??
              [],
      price: (json['price'] ?? 0).toDouble(),
      videoCompleted: json['videoCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'subject': subject.toJson(),
      'grade': grade,
      'boards': boards,
      'price': price,
      'videoCompleted': videoCompleted,
    };
  }
}

class PaymentHistory {
  final String id;
  final double amount;
  final String paymentStatus;
  final String paymentMethod;
  final String? transactionId;
  final DateTime paymentDate;

  PaymentHistory({
    required this.id,
    required this.amount,
    required this.paymentStatus,
    required this.paymentMethod,
    this.transactionId,
    required this.paymentDate,
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
    return PaymentHistory(
      id: json['_id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      paymentStatus: json['paymentStatus'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      transactionId: json['transactionId'],
      paymentDate: DateTime.parse(json['paymentDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'amount': amount,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'paymentDate': paymentDate.toIso8601String(),
    };
  }
}
