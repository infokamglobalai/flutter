import 'package:get/get.dart';
import 'package:najahapp/app/data/models/subscription_model.dart';
import 'package:najahapp/app/data/services/data_service.dart';
import 'package:najahapp/app/data/services/mocktest_service.dart';
import 'package:najahapp/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:najahapp/app/routes/app_pages.dart';

class StudentMocktestsController extends GetxController {
  final MocktestService _mocktestService = Get.find<MocktestService>();
  final DataService _dataService = Get.find<DataService>();

  final isLoading = true.obs;
  final error = ''.obs;
  final items = <Map<String, dynamic>>[].obs;

  late String subscriptionId;
  SubscriptionModel? subscription;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['subscriptionId'] != null) {
      subscriptionId = args['subscriptionId'].toString();
    } else {
      subscriptionId = '';
    }
  }

  @override
  void onReady() {
    super.onReady();
    _load();
  }

  Future<void> _resolveSubscription() async {
    // Prefer DashboardController cache if available (fast, avoids extra request).
    if (Get.isRegistered<DashboardController>()) {
      final dash = Get.find<DashboardController>();
      await dash.loadUserSubscriptions();
      for (final s in dash.userSubscriptions) {
        if (s.id == subscriptionId) {
          subscription = s;
          return;
        }
      }
    }

    // Fallback: fetch subscriptions directly (works for deep links / cold starts).
    final subs = await _dataService.fetchUserSubscriptions();
    for (final s in subs) {
      if (s.id == subscriptionId) {
        subscription = s;
        return;
      }
    }
    subscription = null;
  }

  Future<void> _load() async {
    if (subscriptionId.isEmpty) {
      error.value = 'Missing subscription';
      isLoading.value = false;
      return;
    }

    try {
      isLoading.value = true;
      error.value = '';
      await _resolveSubscription();
      if (subscription == null) {
        error.value = 'Subscription not found or you do not have access.';
        return;
      }

      final list = await _mocktestService.getStudentMocktests(
        boardId: subscription!.board.id,
        gradeId: subscription!.grade.id,
        packageId: subscription!.id,
      );
      items.assignAll(list);
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> reload() => _load();

  void openAttempt(Map<String, dynamic> test) {
    final id = test['_id']?.toString() ?? test['id']?.toString() ?? '';
    if (id.isEmpty) return;

    final attempted = test['hasAttempted'] == true;
    final status = test['attemptStatus']?.toString();
    final attemptId = test['attemptId']?.toString();

    if (attempted && status == 'completed' && attemptId != null && attemptId.isNotEmpty) {
      Get.toNamed(
        Routes.MOCKTEST_RESULT,
        arguments: {'attemptId': attemptId},
      );
      return;
    }

    Get.toNamed(
      Routes.MOCKTEST_ATTEMPT,
      arguments: {
        'mocktestId': id,
        'packageId': subscriptionId,
        'title': test['title']?.toString() ?? 'Mock test',
      },
    );
  }
}
