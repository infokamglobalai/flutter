import 'package:get/get.dart';

class FullAssessmentController extends GetxController {
  // Package and subject data
  final packageData = Rx<Map<String, dynamic>>({});
  final selectedSubject = ''.obs;

  // Assessment state
  final allChapters = <Map<String, dynamic>>[].obs;
  final allQuestions = <Map<String, dynamic>>[].obs;
  final currentQuestionIndex = 0.obs;
  final assessmentAnswers =
      <int, int>{}.obs; // question index -> selected option
  final isSubmittingAssessment = false.obs;
  final assessmentCompleted = false.obs;
  final assessmentScore = 0.obs;
  final correctAnswersCount = 0.obs;

  // Access control
  final allVideosCompleted = false.obs;
  final totalVideos = 0.obs;
  final completedVideos = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadArguments();
    _loadAssessmentData();
  }

  void _loadArguments() {
    if (Get.arguments != null) {
      final args = Get.arguments as Map<String, dynamic>;
      packageData.value = args['package'] ?? {};
      selectedSubject.value = args['subject'] ?? '';
    }
  }

  void _loadAssessmentData() {
    // Get all chapters for the selected subject
    final chapters = packageData.value['chapters'] as Map<String, dynamic>?;
    if (chapters == null) return;

    final chapterList = chapters[selectedSubject.value] as int? ?? 0;
    final chapterData = _getChaptersForSubject(
      selectedSubject.value,
      chapterList,
    );

    allChapters.value = chapterData;

    // Check if all videos are completed
    totalVideos.value = chapterData.length;
    completedVideos.value = chapterData
        .where((c) => c['videoCompleted'] == true)
        .length;
    allVideosCompleted.value = completedVideos.value == totalVideos.value;

    if (allVideosCompleted.value) {
      _loadAllQuestions();
    }
  }

  List<Map<String, dynamic>> _getChaptersForSubject(String subject, int count) {
    // Mock data - in production, fetch from API
    return List.generate(
      count,
      (index) => {
        'id': index + 1,
        'name': 'Chapter ${index + 1}',
        'videoCompleted': index < 3, // First 3 chapters completed for testing
        'assessment': {
          'questions': _generateAssessmentQuestions(subject, index + 1, 5),
        },
      },
    );
  }

  List<Map<String, dynamic>> _generateAssessmentQuestions(
    String subject,
    int chapterNum,
    int count,
  ) {
    return List.generate(
      count,
      (index) => {
        'id': index + 1,
        'chapterNum': chapterNum,
        'question':
            'Chapter $chapterNum - Question ${index + 1}: ${_getQuestionText(subject, chapterNum, index + 1)}',
        'options': [
          'Option A for Chapter $chapterNum Q${index + 1}',
          'Option B for Chapter $chapterNum Q${index + 1}',
          'Option C for Chapter $chapterNum Q${index + 1}',
          'Option D for Chapter $chapterNum Q${index + 1}',
        ],
        'correctAnswer': index % 4, // Index of correct option
        'selectedAnswer': null,
        'explanation':
            'This is the explanation for Chapter $chapterNum, Question ${index + 1}.',
      },
    );
  }

  String _getQuestionText(String subject, int chapterNum, int questionNum) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
        return 'Solve the mathematical problem from chapter $chapterNum';
      case 'science':
        return 'Explain the scientific concept from chapter $chapterNum';
      default:
        return 'Answer the question about chapter $chapterNum';
    }
  }

  void _loadAllQuestions() {
    // Combine all questions from all chapters
    final questions = <Map<String, dynamic>>[];
    for (var chapter in allChapters) {
      final chapterAssessment = chapter['assessment'] as Map<String, dynamic>?;
      if (chapterAssessment != null) {
        final chapterQuestions = chapterAssessment['questions'] as List?;
        if (chapterQuestions != null) {
          questions.addAll(chapterQuestions.cast<Map<String, dynamic>>());
        }
      }
    }
    allQuestions.value = questions;
  }

  void selectAnswer(int questionIndex, int optionIndex) {
    assessmentAnswers[questionIndex] = optionIndex;
  }

  void nextQuestion() {
    if (currentQuestionIndex.value < allQuestions.length - 1) {
      currentQuestionIndex.value++;
    }
  }

  void previousQuestion() {
    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex.value--;
    }
  }

  void goToQuestion(int index) {
    if (index >= 0 && index < allQuestions.length) {
      currentQuestionIndex.value = index;
    }
  }

  Future<void> submitAssessment() async {
    // Check if all questions are answered
    if (assessmentAnswers.length < allQuestions.length) {
      Get.snackbar(
        'Incomplete',
        'Please answer all questions before submitting',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onError,
      );
      return;
    }

    isSubmittingAssessment.value = true;
    await Future.delayed(const Duration(seconds: 3));

    // Calculate score
    int correctAnswers = 0;
    for (int i = 0; i < allQuestions.length; i++) {
      final question = allQuestions[i];
      final correctAnswer = question['correctAnswer'] as int;
      final selectedAnswer = assessmentAnswers[i];

      if (correctAnswer == selectedAnswer) {
        correctAnswers++;
      }
    }

    correctAnswersCount.value = correctAnswers;
    assessmentScore.value = (correctAnswers / allQuestions.length * 100)
        .round();
    assessmentCompleted.value = true;
    isSubmittingAssessment.value = false;

    // Show success message
    Get.snackbar(
      'Assessment Complete!',
      'Your score: ${assessmentScore.value}% ($correctAnswers/${allQuestions.length} correct)',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: assessmentScore.value >= 60
          ? Get.theme.primaryColor
          : Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onPrimary,
      duration: const Duration(seconds: 5),
    );
  }

  void restartAssessment() {
    currentQuestionIndex.value = 0;
    assessmentAnswers.clear();
    assessmentCompleted.value = false;
    assessmentScore.value = 0;
    correctAnswersCount.value = 0;
  }

  void viewResults() {
    // Navigate to detailed results view
    Get.toNamed(
      '/assessment-results',
      arguments: {
        'questions': allQuestions,
        'answers': assessmentAnswers,
        'score': assessmentScore.value,
        'correctCount': correctAnswersCount.value,
      },
    );
  }
}
