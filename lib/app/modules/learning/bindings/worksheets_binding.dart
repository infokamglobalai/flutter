import 'package:get/get.dart';
import '../controllers/worksheets_controller.dart';

class WorksheetsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WorksheetsController>(() => WorksheetsController());
  }
}
