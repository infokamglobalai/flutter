import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../config/tenant_config.dart';
import 'api_service.dart';

class TenantService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  final tenantName = TenantConfig.tenantName.obs;
  final logoUrl = ''.obs;
  final primaryColorHex = TenantConfig.primaryColorHex.obs;
  final isLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTenantSettings();
  }

  Future<void> fetchTenantSettings() async {
    try {
      final response = await _apiService.get('/tenant-settings/settings');
      if (response.data['success'] == true && response.data['data'] != null) {
        final data = response.data['data'];
        if (data['instituteName'] != null && data['instituteName'].isNotEmpty) {
          tenantName.value = data['instituteName'];
        }
        if (data['logoUrl'] != null && data['logoUrl'].isNotEmpty) {
          logoUrl.value = data['logoUrl'];
        }
        if (data['primaryColor'] != null && data['primaryColor'].isNotEmpty) {
          primaryColorHex.value = data['primaryColor'];
        }
        isLoaded.value = true;
      }
    } on DioException catch (_) {
      // Best-effort; fallback to TenantConfig
    } catch (_) {
      // Best-effort; fallback to TenantConfig
    }
  }

  Color get primaryColor {
    final hex = primaryColorHex.value.replaceAll('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    }
    return const Color(0xFF6366F1);
  }
}
