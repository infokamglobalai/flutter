import 'package:get/get.dart';
import 'package:najahapp/app/modules/learning/controllers/watch_history_controller.dart';

class WatchHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WatchHistoryController>(() => WatchHistoryController());
  }
}
