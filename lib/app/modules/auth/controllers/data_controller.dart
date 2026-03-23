import 'package:get/get.dart';
import '../../../data/services/data_service.dart';
import '../../../data/models/board_model.dart';
import '../../../data/models/grade_model.dart';

class DataController extends GetxController {
  final DataService _dataService = DataService();

  final RxList<BoardModel> boards = <BoardModel>[].obs;
  final RxList<GradeModel> grades = <GradeModel>[].obs;
  final isLoadingBoards = false.obs;
  final isLoadingGrades = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBoards();
    fetchGrades();
  }

  Future<void> fetchBoards() async {
    try {
      isLoadingBoards.value = true;
      final result = await _dataService.fetchBoards();

      if (result['success'] == true) {
        boards.value = result['boards'];
      }
    } catch (e) {
      // Handle error silently or show snackbar
    } finally {
      isLoadingBoards.value = false;
    }
  }

  Future<void> fetchGrades() async {
    try {
      isLoadingGrades.value = true;
      final result = await _dataService.fetchGrades();

      if (result['success'] == true) {
        grades.value = result['grades'];
      }
    } catch (e) {
      // Handle error silently or show snackbar
    } finally {
      isLoadingGrades.value = false;
    }
  }

  List<String> get boardNames => boards.map((board) => board.name).toList();
  List<String> get gradeNames => grades.map((grade) => grade.name).toList();
}
