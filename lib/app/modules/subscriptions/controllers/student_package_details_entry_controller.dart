import 'package:get/get.dart';
import 'package:najahapp/app/data/services/data_service.dart';
import 'package:najahapp/app/routes/app_pages.dart';

class StudentPackageDetailsEntryController extends GetxController {
  final DataService _data = DataService();

  final isLoading = false.obs;
  final error = ''.obs;

  late final String packageId;

  @override
  void onInit() {
    super.onInit();
    packageId = (Get.parameters['packageId'] ?? '').toString().trim();
    _open();
  }

  Future<void> _open() async {
    if (packageId.isEmpty) {
      error.value = 'Missing packageId';
      return;
    }
    try {
      isLoading.value = true;
      error.value = '';

      final subs = await _data.fetchUserSubscriptions();
      final sub = subs.firstWhereOrNull((s) => s.id == packageId);
      if (sub == null) {
        error.value = 'Package not found';
        return;
      }

      Get.offNamed(
        Routes.SUBJECT_CHAPTER_DETAIL,
        arguments: sub,
      );
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }
}

