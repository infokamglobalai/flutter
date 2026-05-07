import 'package:get/get.dart';
import 'package:najahapp/app/data/services/data_service.dart';

class PublicAssessmentResultController extends GetxController {
  final DataService _data = Get.find<DataService>();

  final attemptId = ''.obs;
  final isLoading = false.obs;
  final error = ''.obs;
  final result = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      attemptId.value = (args['attemptId'] ?? '').toString();
      final fallback = args['fallback'];
      if (fallback is Map) {
        result.value = fallback.cast<String, dynamic>();
      }
    }
    if (attemptId.value.isNotEmpty) {
      load();
    }
  }

  Future<void> load() async {
    if (isLoading.value) return;
    isLoading.value = true;
    error.value = '';
    try {
      final res = await _data.fetchAssessmentAttemptResult(attemptId.value);
      if (res['success'] == true) {
        result.value = (res['data'] as Map).cast<String, dynamic>();
      } else {
        error.value = (res['message'] ?? 'Failed to load result').toString();
      }
    } finally {
      isLoading.value = false;
    }
  }
}

