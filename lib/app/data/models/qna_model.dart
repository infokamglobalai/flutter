// Data models for the student–mentor Q&A thread system.
// Each QnaThread belongs to one chapter + subscription pair.
// It contains a list of QnaItem objects (each = one student question + optional mentor answer).

class QnaUserRef {
  final String id;
  final String firstName;
  final String lastName;

  const QnaUserRef({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory QnaUserRef.fromJson(Map<String, dynamic> json) {
    return QnaUserRef(
      id: json['_id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
    );
  }
}

class QnaChapterRef {
  final String id;
  final String name;
  final String subjectName;

  const QnaChapterRef({
    required this.id,
    required this.name,
    required this.subjectName,
  });

  factory QnaChapterRef.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      return const QnaChapterRef(id: '', name: '', subjectName: '');
    }
    final rawSubject = json['subject'];
    final subjectName = rawSubject is Map
        ? (rawSubject['name']?.toString() ?? '')
        : '';
    return QnaChapterRef(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      subjectName: subjectName,
    );
  }
}

class QnaItem {
  final String id;
  final QnaUserRef? askedBy;
  final String questionText;
  final String answerText;
  final QnaUserRef? answeredBy;
  final DateTime? answeredAt;
  final DateTime createdAt;

  const QnaItem({
    required this.id,
    this.askedBy,
    required this.questionText,
    required this.answerText,
    this.answeredBy,
    this.answeredAt,
    required this.createdAt,
  });

  bool get isAnswered => answerText.isNotEmpty;

  factory QnaItem.fromJson(Map<String, dynamic> json) {
    return QnaItem(
      id: json['_id']?.toString() ?? '',
      askedBy: json['askedBy'] is Map
          ? QnaUserRef.fromJson(json['askedBy'] as Map<String, dynamic>)
          : null,
      questionText: json['questionText']?.toString() ?? '',
      answerText: json['answerText']?.toString() ?? '',
      answeredBy: json['answeredBy'] is Map
          ? QnaUserRef.fromJson(json['answeredBy'] as Map<String, dynamic>)
          : null,
      answeredAt: json['answeredAt'] != null
          ? DateTime.tryParse(json['answeredAt'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class QnaThread {
  final String id;
  final QnaChapterRef? chapter;
  final String packageSubscriptionId;
  final List<QnaItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Enriched from backend when mentor fetches
  final String? studentName;
  final String? studentId;
  final String? packageName; // optional, may not be populated

  const QnaThread({
    required this.id,
    this.chapter,
    required this.packageSubscriptionId,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
    this.studentName,
    this.studentId,
    this.packageName,
  });

  int get totalQuestions => items.length;
  int get answeredCount => items.where((i) => i.isAnswered).length;
  int get pendingCount => items.where((i) => !i.isAnswered).length;
  bool get hasUnanswered => items.any((i) => !i.isAnswered);

  /// The most recent item (last in list).
  QnaItem? get lastItem => items.isNotEmpty ? items.last : null;

  factory QnaThread.fromJson(Map<String, dynamic> json) {
    final rawChapter = json['chapter'];
    QnaChapterRef? chapter;
    if (rawChapter is Map) {
      chapter = QnaChapterRef.fromJson(rawChapter as Map<String, dynamic>);
    } else if (rawChapter is String) {
      chapter = QnaChapterRef(id: rawChapter, name: '', subjectName: '');
    }

    final rawSub = json['packageSubscription'];
    String subId = '';
    if (rawSub is Map) {
      subId = rawSub['_id']?.toString() ?? '';
    } else if (rawSub is String) {
      subId = rawSub;
    }

    final rawItems = json['items'] as List<dynamic>? ?? [];

    return QnaThread(
      id: json['_id']?.toString() ?? '',
      chapter: chapter,
      packageSubscriptionId: subId,
      items: rawItems
          .map((i) => QnaItem.fromJson(i as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      studentName: json['studentName']?.toString(),
      studentId: json['studentId']?.toString(),
      packageName: json['packageName']?.toString(),
    );
  }

  QnaThread copyWith({
    List<QnaItem>? items,
    String? studentName,
    String? studentId,
  }) {
    return QnaThread(
      id: id,
      chapter: chapter,
      packageSubscriptionId: packageSubscriptionId,
      items: items ?? this.items,
      createdAt: createdAt,
      updatedAt: updatedAt,
      studentName: studentName ?? this.studentName,
      studentId: studentId ?? this.studentId,
      packageName: packageName,
    );
  }
}
