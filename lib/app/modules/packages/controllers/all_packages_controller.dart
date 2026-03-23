import 'package:get/get.dart';
import 'package:najahapp/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:najahapp/app/data/models/package_model.dart';

class AllPackagesController extends GetxController {
  final isLoading = false.obs;
  final error = ''.obs;
  final packages = <PackageModel>[].obs;

  List<PackageModel> get regularPackages =>
      packages.where((p) => !p.isCompetitiveExam).toList();

  List<PackageModel> get competitivePackages =>
      packages.where((p) => p.isCompetitiveExam).toList();

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    loadPackages();
  }

  Future<void> loadPackages() async {
    try {
      isLoading.value = true;
      error.value = '';

      // Get packages from DashboardController if it's already loaded
      final dashboardController = Get.find<DashboardController>();

      // Load fresh data
      await dashboardController.loadPublicPackages();

      // Update local packages
      packages.value = dashboardController.publicPackages;

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
