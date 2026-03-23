import 'package:get/get.dart';

class CustomAssessmentController extends GetxController {
  // Selection state
  final selectedGrade = Rxn<String>();
  final selectedSubject = Rxn<String>();
  final selectedChapters = <String>[].obs;

  // Available options based on selections
  final availableSubjects = <String>[].obs;
  final availableChapters = <Map<String, dynamic>>[].obs;

  // Assessment state
  final assessmentQuestions = <Map<String, dynamic>>[].obs;
  final currentQuestionIndex = 0.obs;
  final assessmentAnswers =
      <int, int>{}.obs; // question index -> selected option
  final isLoadingQuestions = false.obs;
  final isSubmittingAssessment = false.obs;
  final assessmentCompleted = false.obs;
  final assessmentScore = 0.obs;
  final correctAnswersCount = 0.obs;
  final totalQuestions = 0.obs;

  // Timer
  final timeElapsed = 0.obs;
  final isTimerRunning = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Load initial data if needed
  }

  @override
  void onClose() {
    stopTimer();
    super.onClose();
  }

  // Selection Methods
  void selectGrade(String grade) {
    selectedGrade.value = grade;
    selectedSubject.value = null;
    selectedChapters.clear();
    _loadSubjectsForGrade(grade);
  }

  void selectSubject(String subject) {
    selectedSubject.value = subject;
    selectedChapters.clear();
    _loadChaptersForSubject(subject);
  }

  void toggleChapterSelection(String chapterId) {
    if (selectedChapters.contains(chapterId)) {
      selectedChapters.remove(chapterId);
    } else {
      selectedChapters.add(chapterId);
    }
  }

  bool isChapterSelected(String chapterId) {
    return selectedChapters.contains(chapterId);
  }

  // Data Loading Methods
  void _loadSubjectsForGrade(String grade) {
    // Mock subjects based on grade
    // In production, fetch from API based on student's subscribed packages
    final subjects = <String>[
      'Mathematics',
      'Science',
      'English',
      'Social Science',
      'Hindi',
      'Computer Science',
    ];
    availableSubjects.value = subjects;
  }

  void _loadChaptersForSubject(String subject) {
    // Mock chapters for the selected subject
    // In production, fetch from API based on student's subscribed content
    final chapters = <Map<String, dynamic>>[];

    int chapterCount = 15; // Default
    if (subject == 'Mathematics') {
      chapterCount = 15;
    } else if (subject == 'Science') {
      chapterCount = 12;
    } else if (subject == 'English') {
      chapterCount = 10;
    } else if (subject == 'Social Science') {
      chapterCount = 14;
    } else if (subject == 'Hindi') {
      chapterCount = 12;
    } else if (subject == 'Computer Science') {
      chapterCount = 8;
    }

    for (int i = 1; i <= chapterCount; i++) {
      chapters.add({
        'id': 'ch_${i}',
        'number': i,
        'name': _getChapterName(subject, i),
        'questionsAvailable': 15 + (i % 5) * 2,
      });
    }

    availableChapters.value = chapters;
  }

  String _getChapterName(String subject, int chapterNum) {
    // Mock chapter names
    switch (subject) {
      case 'Mathematics':
        final mathChapters = [
          'Real Numbers',
          'Polynomials',
          'Linear Equations',
          'Quadratic Equations',
          'Arithmetic Progressions',
          'Triangles',
          'Coordinate Geometry',
          'Introduction to Trigonometry',
          'Applications of Trigonometry',
          'Circles',
          'Constructions',
          'Areas Related to Circles',
          'Surface Areas and Volumes',
          'Statistics',
          'Probability',
        ];
        return chapterNum <= mathChapters.length
            ? mathChapters[chapterNum - 1]
            : 'Chapter $chapterNum';
      case 'Science':
        final scienceChapters = [
          'Chemical Reactions and Equations',
          'Acids, Bases and Salts',
          'Metals and Non-metals',
          'Carbon and its Compounds',
          'Periodic Classification',
          'Life Processes',
          'Control and Coordination',
          'Reproduction',
          'Heredity and Evolution',
          'Light - Reflection and Refraction',
          'The Human Eye',
          'Electricity',
        ];
        return chapterNum <= scienceChapters.length
            ? scienceChapters[chapterNum - 1]
            : 'Chapter $chapterNum';
      default:
        return 'Chapter $chapterNum';
    }
  }

  // Validation
  bool canCreateAssessment() {
    return selectedGrade.value != null &&
        selectedSubject.value != null &&
        selectedChapters.isNotEmpty;
  }

  String? getValidationMessage() {
    if (selectedGrade.value == null) {
      return 'Please select a grade';
    }
    if (selectedSubject.value == null) {
      return 'Please select a subject';
    }
    if (selectedChapters.isEmpty) {
      return 'Please select at least one chapter';
    }
    return null;
  }

  // Assessment Creation
  Future<void> createAssessment() async {
    final validationMsg = getValidationMessage();
    if (validationMsg != null) {
      Get.snackbar(
        'Incomplete Selection',
        validationMsg,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoadingQuestions.value = true;

      // Simulate API call to fetch questions
      await Future.delayed(const Duration(milliseconds: 800));

      // Generate questions from selected chapters
      final questions = <Map<String, dynamic>>[];

      // Get questions from each selected chapter
      for (final chapterId in selectedChapters) {
        final chapter = availableChapters.firstWhere(
          (ch) => ch['id'] == chapterId,
        );
        final chapterQuestions = _generateQuestionsForChapter(
          selectedSubject.value!,
          chapter['number'] as int,
          chapter['name'] as String,
        );
        questions.addAll(chapterQuestions);
      }

      // Shuffle and pick at least 10 questions
      questions.shuffle();
      final selectedQuestions = questions
          .take(questions.length > 15 ? 15 : questions.length)
          .toList();

      if (selectedQuestions.length < 10) {
        Get.snackbar(
          'Insufficient Questions',
          'Not enough questions available. Please select more chapters.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      assessmentQuestions.value = selectedQuestions;
      totalQuestions.value = selectedQuestions.length;
      currentQuestionIndex.value = 0;
      assessmentAnswers.clear();
      assessmentCompleted.value = false;
      assessmentScore.value = 0;
      correctAnswersCount.value = 0;

      // Navigate to assessment view
      Get.toNamed('/custom-assessment');

      // Start timer
      startTimer();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create assessment: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingQuestions.value = false;
    }
  }

  List<Map<String, dynamic>> _generateQuestionsForChapter(
    String subject,
    int chapterNum,
    String chapterName,
  ) {
    // Generate 3-5 questions per chapter
    final questionCount = 3 + (chapterNum % 3);
    final questions = <Map<String, dynamic>>[];

    for (int i = 0; i < questionCount; i++) {
      questions.add({
        'id': 'q_${chapterNum}_${i + 1}',
        'chapterId': 'ch_$chapterNum',
        'chapterName': chapterName,
        'question': _generateQuestionText(subject, chapterName, i + 1),
        'options': _generateOptions(subject, i),
        'correctAnswer': i % 4, // Mock correct answer index
        'selectedAnswer': null,
        'explanation': _generateExplanation(subject, chapterName, i + 1),
      });
    }

    return questions;
  }

  String _generateQuestionText(String subject, String chapterName, int qNum) {
    switch (subject) {
      case 'Mathematics':
        return 'Question $qNum: Solve the problem related to $chapterName';
      case 'Science':
        return 'Question $qNum: Explain the concept from $chapterName';
      case 'English':
        return 'Question $qNum: Identify the correct usage in $chapterName';
      default:
        return 'Question $qNum from $chapterName';
    }
  }

  List<String> _generateOptions(String subject, int index) {
    return [
      'Option A - ${['Correct answer', 'Partially correct', 'Incorrect', 'Wrong'][index % 4]}',
      'Option B - ${['Wrong', 'Correct answer', 'Partially correct', 'Incorrect'][index % 4]}',
      'Option C - ${['Incorrect', 'Wrong', 'Correct answer', 'Partially correct'][index % 4]}',
      'Option D - ${['Partially correct', 'Incorrect', 'Wrong', 'Correct answer'][index % 4]}',
    ];
  }

  String _generateExplanation(String subject, String chapterName, int qNum) {
    return 'This is the explanation for question $qNum from $chapterName. '
        'The correct answer is based on the key concepts covered in this chapter.';
  }

  // Assessment Navigation
  void selectAnswer(int questionIndex, int optionIndex) {
    assessmentAnswers[questionIndex] = optionIndex;
  }

  void nextQuestion() {
    if (currentQuestionIndex.value < assessmentQuestions.length - 1) {
      currentQuestionIndex.value++;
    }
  }

  void previousQuestion() {
    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex.value--;
    }
  }

  void goToQuestion(int index) {
    if (index >= 0 && index < assessmentQuestions.length) {
      currentQuestionIndex.value = index;
    }
  }

  // Timer Methods
  void startTimer() {
    timeElapsed.value = 0;
    isTimerRunning.value = true;
    _runTimer();
  }

  void stopTimer() {
    isTimerRunning.value = false;
  }

  void _runTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (isTimerRunning.value) {
        timeElapsed.value++;
        _runTimer();
      }
    });
  }

  String getFormattedTime() {
    final minutes = (timeElapsed.value ~/ 60).toString().padLeft(2, '0');
    final seconds = (timeElapsed.value % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  // Assessment Submission
  Future<void> submitAssessment() async {
    // Check if all questions are answered
    if (assessmentAnswers.length < assessmentQuestions.length) {
      Get.snackbar(
        'Incomplete Assessment',
        'Please answer all questions before submitting (${assessmentAnswers.length}/${assessmentQuestions.length} answered)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onError,
      );
      return;
    }

    isSubmittingAssessment.value = true;
    stopTimer();

    try {
      // Simulate submission delay
      await Future.delayed(const Duration(seconds: 2));

      // Calculate score
      int correctAnswers = 0;
      for (int i = 0; i < assessmentQuestions.length; i++) {
        final question = assessmentQuestions[i];
        final correctAnswer = question['correctAnswer'] as int;
        final selectedAnswer = assessmentAnswers[i];

        if (correctAnswer == selectedAnswer) {
          correctAnswers++;
        }
      }

      correctAnswersCount.value = correctAnswers;
      assessmentScore.value =
          (correctAnswers / assessmentQuestions.length * 100).round();
      assessmentCompleted.value = true;

      // Show success message
      Get.snackbar(
        'Assessment Complete!',
        'Your score: ${assessmentScore.value}% ($correctAnswers/${assessmentQuestions.length} correct)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: assessmentScore.value >= 60
            ? Get.theme.primaryColor
            : Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onPrimary,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit assessment: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmittingAssessment.value = false;
    }
  }

  // Reset & Restart
  void resetAssessment() {
    currentQuestionIndex.value = 0;
    assessmentAnswers.clear();
    assessmentCompleted.value = false;
    assessmentScore.value = 0;
    correctAnswersCount.value = 0;
    timeElapsed.value = 0;
    startTimer();
  }

  void exitAssessment() {
    stopTimer();
    Get.back();
  }

  void backToConfiguration() {
    stopTimer();
    assessmentQuestions.clear();
    assessmentAnswers.clear();
    assessmentCompleted.value = false;
    Get.back();
  }
}
