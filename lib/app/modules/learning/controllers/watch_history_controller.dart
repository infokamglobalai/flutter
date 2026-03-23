import 'package:get/get.dart';

enum ActivityType { video, document, assessment }

enum ProgressStatus { excellent, good, needsImprovement }

class ActivityItem {
  final String id;
  final ActivityType type;
  final String title;
  final String subject;
  final String chapter;
  final DateTime date;
  final int durationMinutes; // For videos and documents
  final int? score; // For assessments (out of 100)
  final int? totalQuestions; // For assessments
  final int? correctAnswers; // For assessments

  ActivityItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subject,
    required this.chapter,
    required this.date,
    this.durationMinutes = 0,
    this.score,
    this.totalQuestions,
    this.correctAnswers,
  });

  String get formattedDuration {
    if (durationMinutes < 60) {
      return '$durationMinutes min';
    } else {
      final hours = durationMinutes ~/ 60;
      final mins = durationMinutes % 60;
      return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
    }
  }

  String get typeLabel {
    switch (type) {
      case ActivityType.video:
        return 'Video';
      case ActivityType.document:
        return 'Document';
      case ActivityType.assessment:
        return 'Assessment';
    }
  }
}

class WatchHistoryController extends GetxController {
  final activities = <ActivityItem>[].obs;
  final filteredActivities = <ActivityItem>[].obs;
  final selectedFilter = 'All'.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadActivities();
  }

  void loadActivities() {
    isLoading.value = true;

    // Mock data - Replace with API call in production
    final mockActivities = [
      // Videos
      ActivityItem(
        id: '1',
        type: ActivityType.video,
        title: 'Quadratic Equations - Complete Solution Methods',
        subject: 'Mathematics',
        chapter: 'Chapter 4: Quadratic Equations',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        durationMinutes: 45,
      ),
      ActivityItem(
        id: '2',
        type: ActivityType.video,
        title: 'Photosynthesis Process Explained',
        subject: 'Science',
        chapter: 'Chapter 6: Life Processes',
        date: DateTime.now().subtract(const Duration(days: 1)),
        durationMinutes: 32,
      ),
      ActivityItem(
        id: '3',
        type: ActivityType.video,
        title: 'Chemical Reactions and Equations',
        subject: 'Science',
        chapter: 'Chapter 1: Chemical Reactions',
        date: DateTime.now().subtract(const Duration(days: 2)),
        durationMinutes: 38,
      ),

      // Documents
      ActivityItem(
        id: '4',
        type: ActivityType.document,
        title: 'Grammar Rules - Tenses Summary',
        subject: 'English',
        chapter: 'Chapter 3: Grammar',
        date: DateTime.now().subtract(const Duration(hours: 5)),
        durationMinutes: 15,
      ),
      ActivityItem(
        id: '5',
        type: ActivityType.document,
        title: 'French Revolution - Key Events',
        subject: 'Social Science',
        chapter: 'Chapter 1: The French Revolution',
        date: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
        durationMinutes: 22,
      ),
      ActivityItem(
        id: '6',
        type: ActivityType.document,
        title: 'Trigonometry Formula Sheet',
        subject: 'Mathematics',
        chapter: 'Chapter 8: Trigonometry',
        date: DateTime.now().subtract(const Duration(days: 3)),
        durationMinutes: 18,
      ),

      // Assessments
      ActivityItem(
        id: '7',
        type: ActivityType.assessment,
        title: 'Quadratic Equations Practice Test',
        subject: 'Mathematics',
        chapter: 'Chapter 4: Quadratic Equations',
        date: DateTime.now().subtract(const Duration(hours: 1)),
        durationMinutes: 30,
        score: 92,
        totalQuestions: 20,
        correctAnswers: 18,
      ),
      ActivityItem(
        id: '8',
        type: ActivityType.assessment,
        title: 'Photosynthesis Quiz',
        subject: 'Science',
        chapter: 'Chapter 6: Life Processes',
        date: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        durationMinutes: 15,
        score: 75,
        totalQuestions: 15,
        correctAnswers: 11,
      ),
      ActivityItem(
        id: '9',
        type: ActivityType.assessment,
        title: 'Grammar Assessment',
        subject: 'English',
        chapter: 'Chapter 3: Grammar',
        date: DateTime.now().subtract(const Duration(days: 2)),
        durationMinutes: 20,
        score: 88,
        totalQuestions: 25,
        correctAnswers: 22,
      ),
      ActivityItem(
        id: '10',
        type: ActivityType.assessment,
        title: 'French Revolution Test',
        subject: 'Social Science',
        chapter: 'Chapter 1: The French Revolution',
        date: DateTime.now().subtract(const Duration(days: 3)),
        durationMinutes: 40,
        score: 65,
        totalQuestions: 30,
        correctAnswers: 19,
      ),
      ActivityItem(
        id: '11',
        type: ActivityType.assessment,
        title: 'Chemical Reactions Quiz',
        subject: 'Science',
        chapter: 'Chapter 1: Chemical Reactions',
        date: DateTime.now().subtract(const Duration(days: 4)),
        durationMinutes: 25,
        score: 95,
        totalQuestions: 20,
        correctAnswers: 19,
      ),

      // More videos
      ActivityItem(
        id: '12',
        type: ActivityType.video,
        title: 'Electricity and Circuits Basics',
        subject: 'Science',
        chapter: 'Chapter 12: Electricity',
        date: DateTime.now().subtract(const Duration(days: 5)),
        durationMinutes: 55,
      ),
      ActivityItem(
        id: '13',
        type: ActivityType.video,
        title: 'Poetry Analysis Techniques',
        subject: 'English',
        chapter: 'Chapter 7: Poetry',
        date: DateTime.now().subtract(const Duration(days: 6)),
        durationMinutes: 28,
      ),

      // More documents
      ActivityItem(
        id: '14',
        type: ActivityType.document,
        title: 'Democracy in Contemporary World Notes',
        subject: 'Social Science',
        chapter: 'Chapter 2: Democracy',
        date: DateTime.now().subtract(const Duration(days: 7)),
        durationMinutes: 20,
      ),
    ];

    activities.value = mockActivities;
    filteredActivities.value = mockActivities;
    isLoading.value = false;
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    if (filter == 'All') {
      filteredActivities.value = activities;
    } else {
      final type = filter == 'Videos'
          ? ActivityType.video
          : filter == 'Documents'
          ? ActivityType.document
          : ActivityType.assessment;
      filteredActivities.value = activities
          .where((activity) => activity.type == type)
          .toList();
    }
  }

  // Statistics getters
  int get totalVideosWatched =>
      activities.where((a) => a.type == ActivityType.video).length;

  int get totalDocumentsViewed =>
      activities.where((a) => a.type == ActivityType.document).length;

  int get totalAssessments =>
      activities.where((a) => a.type == ActivityType.assessment).length;

  int get totalWatchTimeMinutes => activities
      .where((a) => a.type == ActivityType.video)
      .fold(0, (sum, item) => sum + item.durationMinutes);

  String get totalWatchTimeFormatted {
    final hours = totalWatchTimeMinutes ~/ 60;
    final mins = totalWatchTimeMinutes % 60;
    if (hours == 0) return '${mins}m';
    return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
  }

  double get averageAssessmentScore {
    final assessments = activities
        .where((a) => a.type == ActivityType.assessment)
        .toList();
    if (assessments.isEmpty) return 0;
    final totalScore = assessments.fold(
      0,
      (sum, item) => sum + (item.score ?? 0),
    );
    return totalScore / assessments.length;
  }

  ProgressStatus get overallProgressStatus {
    final avgScore = averageAssessmentScore;
    if (avgScore >= 85) return ProgressStatus.excellent;
    if (avgScore >= 70) return ProgressStatus.good;
    return ProgressStatus.needsImprovement;
  }

  String getProgressStatusText(ProgressStatus status) {
    switch (status) {
      case ProgressStatus.excellent:
        return 'Excellent';
      case ProgressStatus.good:
        return 'Good';
      case ProgressStatus.needsImprovement:
        return 'Need to Improve';
    }
  }

  ProgressStatus getActivityProgressStatus(ActivityItem activity) {
    if (activity.type != ActivityType.assessment) {
      // For videos and documents, consider completion
      return ProgressStatus.good;
    }
    final score = activity.score ?? 0;
    if (score >= 85) return ProgressStatus.excellent;
    if (score >= 70) return ProgressStatus.good;
    return ProgressStatus.needsImprovement;
  }
}
