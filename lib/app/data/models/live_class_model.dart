class LiveClassModel {
  final String id;
  final String title;
  final String description;
  final String roomId;
  final DateTime scheduledAt;
  final int durationMinutes;
  final String status; // 'scheduled', 'live', 'ended', 'cancelled'
  final String? teacherName;
  final String? teacherAvatar;
  final String? subjectName;
  final String? gradeName;
  final DateTime createdAt;

  LiveClassModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.roomId,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.status,
    this.teacherName,
    this.teacherAvatar,
    this.subjectName,
    this.gradeName,
    required this.createdAt,
  });

  factory LiveClassModel.fromJson(Map<String, dynamic> json) {
    String teacherNameStr = '';
    String? teacherAvatarStr;
    if (json['teacher'] != null) {
      if (json['teacher'] is Map) {
        final t = json['teacher'] as Map<String, dynamic>;
        teacherNameStr = '${t['firstName'] ?? ''} ${t['lastName'] ?? ''}'.trim();
        if (teacherNameStr.isEmpty) {
          teacherNameStr = t['userName'] ?? t['email'] ?? '';
        }
        teacherAvatarStr = t['avatar'] ?? t['profilePicture'];
      }
    }

    String subjectStr = '';
    if (json['subject'] != null) {
      if (json['subject'] is Map) {
        subjectStr = json['subject']['name'] ?? '';
      } else if (json['subject'] is String) {
        subjectStr = json['subject'];
      }
    }

    String gradeStr = '';
    if (json['grade'] != null) {
      if (json['grade'] is Map) {
        gradeStr = json['grade']['name'] ?? '';
      } else if (json['grade'] is String) {
        gradeStr = json['grade'];
      }
    }

    return LiveClassModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? 'Live Class',
      description: json['description'] ?? '',
      roomId: json['roomId'] ?? '',
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.parse(json['scheduledAt'])
          : DateTime.now(),
      durationMinutes: json['durationMinutes'] ?? 60,
      status: json['status'] ?? 'scheduled',
      teacherName: teacherNameStr.isNotEmpty ? teacherNameStr : null,
      teacherAvatar: teacherAvatarStr,
      subjectName: subjectStr.isNotEmpty ? subjectStr : null,
      gradeName: gradeStr.isNotEmpty ? gradeStr : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  bool get isLive => status == 'live';
  bool get isScheduled => status == 'scheduled';
  bool get isEnded => status == 'ended';

  DateTime get endTime => scheduledAt.add(Duration(minutes: durationMinutes));

  bool get isJoinable {
    if (isLive) return true;
    if (isScheduled) {
      final now = DateTime.now();
      // Allow joining 10 mins before scheduled time up to end time
      final joinWindowStart = scheduledAt.subtract(const Duration(minutes: 10));
      return now.isAfter(joinWindowStart) && now.isBefore(endTime);
    }
    return false;
  }
}
