import 'package:get/get.dart';
import 'package:najahapp/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:najahapp/app/data/models/subscription_model.dart';

class MySubscriptionsController extends GetxController {
  final isLoading = false.obs;
  final error = ''.obs;
  final subscriptions = <SubscriptionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    loadSubscriptions();
  }

  Future<void> loadSubscriptions() async {
    try {
      isLoading.value = true;
      error.value = '';

      // Get subscriptions from DashboardController if it's already loaded
      final dashboardController = Get.find<DashboardController>();

      // Load fresh data
      await dashboardController.loadUserSubscriptions();

      // Update local subscriptions
      subscriptions.value = dashboardController.userSubscriptions;

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      error.value = e.toString();
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
