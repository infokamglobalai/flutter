import 'package:get/get.dart';
import 'package:najahapp/app/modules/settings/controllers/settings_controller.dart';
import 'package:najahapp/app/modules/dashboard/controllers/dashboard_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(() => SettingsController());
    // Ensure DashboardController is available for user profile info
    Get.lazyPut<DashboardController>(() => DashboardController(), fenix: true);
  }
}
