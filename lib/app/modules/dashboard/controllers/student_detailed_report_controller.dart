import 'package:get/get.dart';
import 'package:najahapp/app/data/services/data_service.dart';
import 'package:najahapp/app/data/services/mocktest_service.dart';

class StudentDetailedReportController extends GetxController {
  final DataService _data = Get.find<DataService>();
  final MocktestService _mocktest = Get.find<MocktestService>();

  final isLoading = false.obs;
  final error = ''.obs;
  final payload = Rxn<Map<String, dynamic>>();

  late final String type;
  late final String attemptId;

  @override
  void onInit() {
    super.onInit();

    // Prefer path parameters when available.
    final pType = Get.parameters['type'];
    final pAttempt = Get.parameters['attemptId'];

    final args = Get.arguments;
    final aType = (args is Map) ? args['type']?.toString() : null;
    final aAttempt = (args is Map) ? args['attemptId']?.toString() : null;

    type = (pType ?? aType ?? '').trim();
    attemptId = (pAttempt ?? aAttempt ?? '').trim();

    fetch();
  }

  Future<void> fetch() async {
    if (type.isEmpty || attemptId.isEmpty) {
      error.value = 'Missing report details';
      return;
    }
    try {
      isLoading.value = true;
      error.value = '';

      if (type == 'mocktest') {
        final data = await _mocktest.getAttemptResults(attemptId);
        payload.value = data;
        return;
      }

      // default: assessment
      final res = await _data.fetchAssessmentAttemptResult(attemptId);
      if (res['success'] == true) {
        payload.value = Map<String, dynamic>.from(res['data'] as Map);
      } else {
        error.value = (res['message'] ?? 'Failed to load report').toString();
      }
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }
}

