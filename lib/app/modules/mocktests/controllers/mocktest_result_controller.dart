import 'package:get/get.dart';
import 'package:najahapp/app/data/services/mocktest_service.dart';

class MocktestResultController extends GetxController {
  final MocktestService _svc = Get.find<MocktestService>();

  final isLoading = false.obs;
  final error = ''.obs;
  final payload = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      if (args['result'] != null) {
        payload.value = Map<String, dynamic>.from(args['result'] as Map);
        return;
      }
      final aid = args['attemptId']?.toString();
      if (aid != null && aid.isNotEmpty) {
        _fetch(aid);
      }
    }
  }

  Future<void> _fetch(String attemptId) async {
    try {
      isLoading.value = true;
      error.value = '';
      final data = await _svc.getAttemptResults(attemptId);
      payload.value = data;
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }
}
