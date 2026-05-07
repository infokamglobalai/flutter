import 'package:get/get.dart';
import 'package:najahapp/app/core/constants/api_constants.dart';
import 'package:najahapp/app/core/services/api_service.dart';

class GuestResourceService {
  final ApiService _api = Get.find<ApiService>();

  /// GET /api/guest-resources/public
  Future<List<Map<String, dynamic>>> getPublic() async {
    final resp = await _api.get(ApiConstants.guestResourcesPublic);
    if (resp.data['success'] == true) {
      final list = resp.data['data'] as List<dynamic>? ?? [];
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    throw Exception(resp.data['message'] ?? 'Failed to load guest resources');
  }
}

