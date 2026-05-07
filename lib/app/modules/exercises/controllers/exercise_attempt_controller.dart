import 'package:get/get.dart';
import 'package:najahapp/app/data/models/exercise_model.dart';

class ExerciseAttemptController extends GetxController {
  late final ExerciseModel exercise;

  final RxInt currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final args = (Get.arguments as Map?) ?? {};
    final ex = args['exercise'];
    if (ex is ExerciseModel) {
      exercise = ex;
    } else {
      // Fallback empty exercise to avoid crashes; view will show an error state.
      exercise = ExerciseModel(
        id: '',
        title: '',
        chapter: ChapterInfo(id: '', name: ''),
        questions: const [],
        order: 0,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  void selectOption(int questionIndex, int optionIndex) {
    if (questionIndex < 0 || questionIndex >= exercise.questions.length) return;
    exercise.questions[questionIndex].selectedOptionIndex = optionIndex;
    // Trigger UI refresh
    currentIndex.refresh();
  }

  int get totalQuestions => exercise.questions.length;

  int get answeredCount =>
      exercise.questions.where((q) => q.isAnswered).length;

  int get correctCount => exercise.questions.where((q) => q.isCorrect).length;
}

