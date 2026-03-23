import 'package:get/get.dart';
import '../controllers/guest_dashboard_controller.dart';

class GuestDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GuestDashboardController>(() => GuestDashboardController());
  }
}
