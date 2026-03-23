import 'package:get/get.dart';
import '../controllers/student_coaching_controller.dart';

class StudentCoachingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentCoachingController>(() => StudentCoachingController());
  }
}
