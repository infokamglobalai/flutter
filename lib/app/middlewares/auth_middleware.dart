import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/services/storage_service.dart';
import 'package:najahapp/app/routes/app_pages.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final storageService = Get.find<StorageService>();
    final token = storageService.getString('auth_token');

    // If no token, redirect to login
    if (token == null || token.isEmpty) {
      return const RouteSettings(name: Routes.LOGIN);
    }

    return null;
  }
}
