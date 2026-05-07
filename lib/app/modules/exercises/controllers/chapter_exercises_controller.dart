import 'package:get/get.dart';
import 'package:najahapp/app/data/models/exercise_model.dart';
import 'package:najahapp/app/data/services/data_service.dart';

class ChapterExercisesController extends GetxController {
  final DataService _dataService = DataService();

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxList<ExerciseModel> exercises = <ExerciseModel>[].obs;

  late final String chapterId;
  late final String chapterName;

  @override
  void onInit() {
    super.onInit();
    final args = (Get.arguments as Map?) ?? {};
    chapterId = (args['chapterId'] ?? '').toString();
    chapterName = (args['chapterName'] ?? 'Chapter').toString();
    load();
  }

  Future<void> load() async {
    if (chapterId.trim().isEmpty) {
      error.value = 'Missing chapterId';
      return;
    }
    try {
      isLoading.value = true;
      error.value = '';
      final list = await _dataService.fetchChapterExercises(chapterId);
      exercises.assignAll(list.where((e) => e.isActive));
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
      exercises.clear();
    } finally {
      isLoading.value = false;
    }
  }
}

