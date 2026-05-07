// ignore_for_file: unused_element

import 'package:get/get.dart';
import '../../../data/models/subscription_model.dart';
import '../../../data/services/data_service.dart';
import '../../../routes/app_pages.dart';

class SubjectChapterController extends GetxController {
  // Subscription data passed from dashboard
  final subscription = Rxn<SubscriptionModel>();

  // Selected subject for filtering
  final selectedSubject = RxnString();

  @override
  void onInit() {
    super.onInit();
    // Get subscription data from navigation arguments
    if (Get.arguments != null) {
      subscription.value = Get.arguments as SubscriptionModel;
    }
  }

  void selectSubject(String? subject) {
    selectedSubject.value = subject;
  }

  List<String> get subjects {
    final sub = subscription.value;
    if (sub == null) return [];

    // Prefer explicit subjects list when present.
    final fromSubjects = sub.subjects.map((s) => s.name).where((n) => n.trim().isNotEmpty).toList();
    if (fromSubjects.isNotEmpty) return fromSubjects;

    // Fallback: derive unique subject names from chapters (backend sometimes
    // populates chapters without a top-level subjects array).
    final set = <String>{};
    for (final ch in sub.chapters) {
      final name = ch.subject.name.trim();
      if (name.isNotEmpty) set.add(name);
    }
    return set.toList()..sort();
  }

  Map<String, dynamic> getChaptersForSubject(String subject) {
    if (subscription.value == null) return {};

    // Filter chapters for the selected subject
    final subjectChapters = subscription.value!.chapters
        .where((chapter) => chapter.subject.name == subject)
        .toList();

    return {
      'count': subjectChapters.length,
      'chapters': List.generate(subjectChapters.length, (index) {
        final chapter = subjectChapters[index];
        final isCompleted = chapter.videoCompleted;
        return {
          'id': index + 1, // Use sequential number for display
          // Keep actual MongoDB ID for reference (used by VideoPlayerController)
          'chapterId': chapter.id,
          '_id': chapter.id,
          'name': chapter.name,
          'title': chapter.name,
          // These are loaded from the API inside VideoPlayer screen.
          // Keep placeholders only so older UI code doesn't crash.
          'documents': const <Map<String, dynamic>>[],
          'exercise': null,
          'assessment': null,
          'progress': isCompleted ? 1.0 : 0.0,
          'completed': isCompleted,
          'videoCompleted': isCompleted,
        };
      }),
    };
  }

  String _getChapterTitle(String subject, int chapterNum) {
    // Mock chapter titles based on subject
    switch (subject.toLowerCase()) {
      case 'mathematics':
        return [
          'Introduction to Algebra',
          'Linear Equations',
          'Quadratic Equations',
          'Trigonometry Basics',
          'Coordinate Geometry',
          'Statistics',
          'Probability',
          'Mensuration',
          'Number Systems',
          'Polynomials',
          'Arithmetic Progressions',
          'Triangles',
          'Circles',
          'Surface Areas',
          'Volumes',
        ][chapterNum % 15];
      case 'science':
        return [
          'Chemical Reactions',
          'Acids and Bases',
          'Metals and Non-Metals',
          'Carbon Compounds',
          'Life Processes',
          'Control and Coordination',
          'Reproduction',
          'Heredity',
          'Light Reflection',
          'Electricity',
          'Magnetic Effects',
          'Energy Sources',
        ][chapterNum % 12];
      default:
        return 'Introduction to $subject';
    }
  }

  List<Map<String, dynamic>> _getChapterDocuments(
    String subject,
    int chapterNum,
  ) {
    return [
      {
        'id': 1,
        'name': 'Lecture Notes',
        'type': 'PDF',
        'size': '2.4 MB',
        'pages': 15,
        'icon': 'notes',
        'url': 'https://example.com/notes_$chapterNum.pdf',
        'syncPoints': _generateSyncPoints(15),
      },
      {
        'id': 2,
        'name': 'Practice Problems',
        'type': 'PDF',
        'size': '1.8 MB',
        'pages': 10,
        'icon': 'problems',
        'url': 'https://example.com/problems_$chapterNum.pdf',
        'syncPoints': _generateSyncPoints(10),
      },
      {
        'id': 3,
        'name': 'Solution Guide',
        'type': 'PDF',
        'size': '3.2 MB',
        'pages': 12,
        'icon': 'solutions',
        'url': 'https://example.com/solutions_$chapterNum.pdf',
        'syncPoints': _generateSyncPoints(12),
      },
      {
        'id': 4,
        'name': 'Quick Reference',
        'type': 'PDF',
        'size': '0.8 MB',
        'pages': 4,
        'icon': 'reference',
        'url': 'https://example.com/reference_$chapterNum.pdf',
        'syncPoints': _generateSyncPoints(4),
      },
    ];
  }

  Map<String, dynamic> _getChapterExercise(String subject, int chapterNum) {
    return {
      'id': chapterNum,
      'title': 'Chapter $chapterNum Exercise',
      'questions': 5 + (chapterNum % 5),
      'pdfUrl': 'https://example.com/exercise_$chapterNum.pdf',
      'submitted': false,
      'savedAnswer': '',
      'submittedAt': null,
    };
  }

  Map<String, dynamic> _getChapterAssessment(String subject, int chapterNum) {
    // Generate assessment questions for each chapter
    final questionCount = 5;
    return {
      'id': chapterNum,
      'title': 'Chapter $chapterNum Assessment',
      'totalQuestions': questionCount,
      'questions': _generateAssessmentQuestions(
        subject,
        chapterNum,
        questionCount,
      ),
      'completed': false,
      'score': null,
      'attemptedAt': null,
    };
  }

  List<Map<String, dynamic>> _generateAssessmentQuestions(
    String subject,
    int chapterNum,
    int count,
  ) {
    // Mock assessment questions - in production, fetch from API
    return List.generate(
      count,
      (index) => {
        'id': index + 1,
        'question':
            'Question ${index + 1} for Chapter $chapterNum: ${_getQuestionText(subject, chapterNum, index + 1)}',
        'options': ['Option A', 'Option B', 'Option C', 'Option D'],
        'correctAnswer': index % 4, // Index of correct option
        'selectedAnswer': null,
        'explanation': 'This is the explanation for question ${index + 1}.',
      },
    );
  }

  String _getQuestionText(String subject, int chapterNum, int questionNum) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
        return 'Solve the equation related to ${_getChapterTitle(subject, chapterNum)}';
      case 'science':
        return 'What is the concept behind ${_getChapterTitle(subject, chapterNum)}?';
      default:
        return 'Test question about ${_getChapterTitle(subject, chapterNum)}';
    }
  }

  List<Map<String, dynamic>> _generateSyncPoints(int pages) {
    // Generate sync points for auto-scrolling document with video
    return List.generate(
      pages,
      (index) => {
        'page': index + 1,
        'timeInSeconds':
            (index + 1) * 60, // Each page synced to 1 minute of video
      },
    );
  }

  void navigateToVideoPlayer(Map<String, dynamic> chapter, String subject) {
    // Kick off prefetch BEFORE navigating so data arrives during/before
    // the route transition. Uses the singleton DataService cache.
    final chapterId = (chapter['_id'] ?? chapter['chapterId'] ?? '').toString();
    if (chapterId.isNotEmpty) {
      Get.find<DataService>().prefetchChapterData(chapterId);
    }

    Get.toNamed(
      Routes.VIDEO_PLAYER,
      arguments: {
        'chapter': chapter,
        'subject': subject,
        'subscriptionId': subscription.value?.id ?? '',
        'packageName': subscription.value?.package.name ?? '',
        'grade': subscription.value?.grade.name ?? '',
        'board': subscription.value?.board.name ?? '',
      },
    );
  }
}
