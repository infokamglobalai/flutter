import 'package:get/get.dart';
import 'package:najahapp/app/core/network/api_client.dart';
import 'package:najahapp/app/core/constants/api_constants.dart';
import 'package:najahapp/app/data/models/subscription_model.dart';

class SubscriptionRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();

  Future<SubscriptionModel?> getActiveSubscription() async {
    try {
      final response = await _apiClient.get(ApiConstants.activeSubscription);
      if (response.data['subscription'] != null) {
        return SubscriptionModel.fromJson(response.data['subscription']);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<SubscriptionModel> subscribe({
    required String planId,
    required String paymentId,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.subscribe,
        data: {'plan_id': planId, 'payment_id': paymentId},
      );
      return SubscriptionModel.fromJson(response.data['subscription']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cancelSubscription({required String subscriptionId}) async {
    try {
      await _apiClient.post(
        ApiConstants.cancelSubscription,
        data: {'subscription_id': subscriptionId},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<SubscriptionModel>> getSubscriptionHistory() async {
    try {
      final response = await _apiClient.get(ApiConstants.subscriptions);
      final subscriptions = (response.data['subscriptions'] as List)
          .map((sub) => SubscriptionModel.fromJson(sub))
          .toList();
      return subscriptions;
    } catch (e) {
      rethrow;
    }
  }
}
