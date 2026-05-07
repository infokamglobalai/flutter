import 'package:get/get.dart';
import 'package:najahapp/app/modules/mocktests/controllers/mocktest_attempt_controller.dart';
import 'package:najahapp/app/modules/mocktests/controllers/mocktest_result_controller.dart';
import 'package:najahapp/app/modules/mocktests/controllers/student_mocktests_controller.dart';

class StudentMocktestsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StudentMocktestsController());
  }
}

class MocktestAttemptBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MocktestAttemptController());
  }
}

class MocktestResultBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MocktestResultController());
  }
}
