import 'package:get/get.dart';
import 'package:najahapp/app/core/constants/api_constants.dart';
import 'package:najahapp/app/core/services/api_service.dart';

class CouponService {
  final ApiService _api = Get.find<ApiService>();

  /// POST /api/coupons/validate
  /// Body: { code, amount }
  Future<Map<String, dynamic>> validate({
    required String code,
    required double amount,
  }) async {
    final resp = await _api.post(
      ApiConstants.couponsValidate,
      data: {
        'code': code,
        'amount': amount,
      },
    );
    return resp.data as Map<String, dynamic>;
  }
}

