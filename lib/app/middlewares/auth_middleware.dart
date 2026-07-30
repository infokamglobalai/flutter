import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/services/storage_service.dart';
import 'package:najahapp/app/modules/auth/controllers/auth_controller.dart';
import 'package:najahapp/app/routes/app_pages.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    try {
      if (Get.isRegistered<StorageService>()) {
        final storageService = Get.find<StorageService>();
        final token = storageService.getTokenSync();
        if (token != null && token.isNotEmpty) {
          return null;
        }
      }

      if (Get.isRegistered<AuthController>()) {
        final auth = Get.find<AuthController>();
        if (auth.currentUser.value != null) {
          return null;
        }
      }
    } catch (e) {
      debugPrint('AuthMiddleware error: $e');
      return null;
    }

    return const RouteSettings(name: Routes.LOGIN);
  }
}
