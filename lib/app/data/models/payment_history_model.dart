class PaymentHistoryModel {
  final String id;
  final SubscriptionReference subscription;
  final String student;
  final double amount;
  final String paymentStatus;
  final String paymentMethod;
  final String transactionId;
  final DateTime paymentDate;
  final String description;
  final double refundAmount;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentHistoryModel({
    required this.id,
    required this.subscription,
    required this.student,
    required this.amount,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.transactionId,
    required this.paymentDate,
    required this.description,
    required this.refundAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentHistoryModel.fromJson(Map<String, dynamic> json) {
    return PaymentHistoryModel(
      id: json['_id'] as String? ?? '',
      subscription:
          json['subscription'] != null &&
              json['subscription'] is Map<String, dynamic>
          ? SubscriptionReference.fromJson(
              json['subscription'] as Map<String, dynamic>,
            )
          : SubscriptionReference.empty(),
      student: json['student'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: json['paymentStatus'] as String? ?? 'unknown',
      paymentMethod: json['paymentMethod'] as String? ?? 'unknown',
      transactionId: json['transactionId'] as String? ?? '',
      paymentDate: json['paymentDate'] != null
          ? DateTime.tryParse(json['paymentDate'] as String) ?? DateTime.now()
          : DateTime.now(),
      description: json['description'] as String? ?? '',
      refundAmount: (json['refundAmount'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String get formattedAmount => '₹${amount.toStringAsFixed(2)}';
  String get formattedDate =>
      '${paymentDate.day}/${paymentDate.month}/${paymentDate.year}';
}

class SubscriptionReference {
  final String id;
  final PackageReference package;
  final String packageType;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;

  SubscriptionReference({
    required this.id,
    required this.package,
    required this.packageType,
    this.startDate,
    this.endDate,
    required this.isActive,
  });

  factory SubscriptionReference.fromJson(Map<String, dynamic> json) {
    return SubscriptionReference(
      id: json['_id'] as String? ?? '',
      package:
          json['package'] != null && json['package'] is Map<String, dynamic>
          ? PackageReference.fromJson(json['package'] as Map<String, dynamic>)
          : PackageReference.empty(),
      packageType: json['packageType'] as String? ?? 'unknown',
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  factory SubscriptionReference.empty() {
    return SubscriptionReference(
      id: '',
      package: PackageReference.empty(),
      packageType: 'unknown',
      isActive: false,
    );
  }
}

class PackageReference {
  final String id;
  final String name;
  final String? description;
  final String? image;

  PackageReference({
    required this.id,
    required this.name,
    this.description,
    this.image,
  });

  factory PackageReference.fromJson(Map<String, dynamic> json) {
    return PackageReference(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown Package',
      description: json['description'] as String?,
      image: json['image'] as String?,
    );
  }

  factory PackageReference.empty() {
    return PackageReference(id: '', name: 'Unknown Package');
  }
}
