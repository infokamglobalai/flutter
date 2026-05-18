import 'package:najahapp/app/data/models/subject_model.dart';
import 'package:najahapp/app/data/models/grade_model.dart';
import 'package:najahapp/app/data/models/board_model.dart';

class PackageModel {
  final String id;
  final String name;
  final List<String> types;
  final String description;
  final List<String> chapters;
  final List<SubjectModel> subjects;
  final double totalPrice;
  final double internationalPrice;
  final int validityDays;
  final String? image;
  final bool isActive;
  final bool isCompetitiveExam;
  final int displayOrder;
  final List<GradeModel> grades;
  final GradeModel? grade;
  final BoardModel? board;
  final PackageDiscount? discount;
  final String pricingType; // 'package' or 'subject'
  final int minSubjectSelection;
  final List<SubjectPrice> subjectPrices;
  final PackageInstallments? installments;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  PackageModel({
    required this.id,
    required this.name,
    required this.types,
    required this.description,
    required this.chapters,
    this.subjects = const [],
    required this.totalPrice,
    this.internationalPrice = 0.0,
    required this.validityDays,
    this.image,
    required this.isActive,
    this.isCompetitiveExam = false,
    this.displayOrder = 0,
    this.grades = const [],
    this.grade,
    this.board,
    this.discount,
    this.pricingType = 'package',
    this.minSubjectSelection = 1,
    this.subjectPrices = const [],
    this.installments,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  static String _asString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Map && value.containsKey('_id')) return value['_id'].toString();
    if (value is Map && value.containsKey('id')) return value['id'].toString();
    return value.toString();
  }

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: _asString(json['_id']),
      name: _asString(json['name']),
      types: json['types'] != null
          ? (json['types'] as List<dynamic>).map((e) => _asString(e)).toList()
          : [],
      description: _asString(json['description']),
      chapters: json['chapters'] != null
          ? (json['chapters'] as List<dynamic>)
              .map((e) => _asString(e))
              .toList()
          : [],
      subjects: json['subjects'] != null && json['subjects'] is List
          ? (json['subjects'] as List)
              .where((e) => e is Map)
              .map((e) => SubjectModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      internationalPrice: (json['internationalPrice'] as num?)?.toDouble() ?? 0.0,
      validityDays: json['validityDays'] as int? ?? 0,
      image: json['image'] != null ? _asString(json['image']) : null,
      isActive: json['isActive'] as bool? ?? false,
      isCompetitiveExam: json['isCompetitiveExam'] as bool? ?? false,
      displayOrder: json['displayOrder'] as int? ?? 0,
      grades: json['grades'] != null && json['grades'] is List
          ? (json['grades'] as List)
              .where((e) => e is Map)
              .map((e) => GradeModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      grade: json['grade'] != null && json['grade'] is Map
          ? GradeModel.fromJson(json['grade'] as Map<String, dynamic>)
          : null,
      board: json['board'] != null && json['board'] is Map
          ? BoardModel.fromJson(json['board'] as Map<String, dynamic>)
          : null,
      discount: json['discount'] != null
          ? PackageDiscount.fromJson(json['discount'] as Map<String, dynamic>)
          : null,
      pricingType: _asString(json['pricingType']).isEmpty ? 'package' : _asString(json['pricingType']),
      minSubjectSelection: json['minSubjectSelection'] as int? ?? 1,
      subjectPrices: json['subjectPrices'] != null && json['subjectPrices'] is List
          ? (json['subjectPrices'] as List)
              .map((e) => SubjectPrice.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      installments: json['installments'] != null
          ? PackageInstallments.fromJson(json['installments'] as Map<String, dynamic>)
          : null,
      createdBy: _asString(json['createdBy']),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(_asString(json['createdAt']))
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(_asString(json['updatedAt']))
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'types': types,
      'description': description,
      'chapters': chapters,
      'subjects': subjects.map((e) => e.toJson()).toList(),
      'totalPrice': totalPrice,
      'internationalPrice': internationalPrice,
      'validityDays': validityDays,
      'image': image,
      'isActive': isActive,
      'isCompetitiveExam': isCompetitiveExam,
      'displayOrder': displayOrder,
      'grades': grades.map((e) => e.toJson()).toList(),
      'grade': grade?.toJson(),
      'board': board?.toJson(),
      'discount': discount?.toJson(),
      'pricingType': pricingType,
      'minSubjectSelection': minSubjectSelection,
      'subjectPrices': subjectPrices.map((e) => e.toJson()).toList(),
      'installments': installments?.toJson(),
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get imageUrl {
    if (image == null || image!.isEmpty) return '';
    if (image!.startsWith('http')) return image!;
    return 'https://lms.eduaitutors.com$image';
  }
}

class SubjectPrice {
  final String subjectId;
  final double price;
  final double internationalPrice;

  SubjectPrice({
    required this.subjectId,
    required this.price,
    required this.internationalPrice,
  });

  factory SubjectPrice.fromJson(Map<String, dynamic> json) {
    return SubjectPrice(
      subjectId: PackageModel._asString(json['subject']),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      internationalPrice: (json['internationalPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject': subjectId,
      'price': price,
      'internationalPrice': internationalPrice,
    };
  }
}

class PackageInstallments {
  final bool enabled;
  final double bookingAmount;
  final int count;
  final List<int> dueDays;

  PackageInstallments({
    required this.enabled,
    required this.bookingAmount,
    required this.count,
    required this.dueDays,
  });

  factory PackageInstallments.fromJson(Map<String, dynamic> json) {
    return PackageInstallments(
      enabled: json['enabled'] as bool? ?? false,
      bookingAmount: (json['bookingAmount'] as num?)?.toDouble() ?? 0.0,
      count: json['count'] as int? ?? 1,
      dueDays: json['dueDays'] != null
          ? (json['dueDays'] as List<dynamic>).map((e) => e as int).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'bookingAmount': bookingAmount,
      'count': count,
      'dueDays': dueDays,
    };
  }
}

class PackageDiscount {
  final bool isActive;
  final String title;
  final String description;
  final double percentage;
  final List<String> freebies;

  PackageDiscount({
    required this.isActive,
    required this.title,
    required this.description,
    required this.percentage,
    required this.freebies,
  });

  factory PackageDiscount.fromJson(Map<String, dynamic> json) {
    return PackageDiscount(
      isActive: json['isActive'] as bool? ?? false,
      title: PackageModel._asString(json['title']),
      description: PackageModel._asString(json['description']),
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      freebies: json['freebies'] != null
          ? (json['freebies'] as List<dynamic>)
              .map((e) => PackageModel._asString(e))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isActive': isActive,
      'title': title,
      'description': description,
      'percentage': percentage,
      'freebies': freebies,
    };
  }
}

