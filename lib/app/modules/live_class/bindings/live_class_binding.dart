import 'package:get/get.dart';
import '../controllers/live_class_controller.dart';

class LiveClassBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LiveClassController>(() => LiveClassController());
  }
}
