import 'package:get/get.dart';
import 'package:najahapp/app/data/repositories/auth_repository.dart';
import 'package:najahapp/app/data/repositories/subscription_repository.dart';
import 'package:najahapp/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:najahapp/app/modules/auth/controllers/auth_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepository>(() => AuthRepository());
    Get.lazyPut<SubscriptionRepository>(() => SubscriptionRepository());
    // Make AuthController optional - only create if not already exists
    if (!Get.isRegistered<AuthController>()) {
      Get.lazyPut<AuthController>(() => AuthController());
    }
    Get.lazyPut<DashboardController>(() => DashboardController());
  }
}
