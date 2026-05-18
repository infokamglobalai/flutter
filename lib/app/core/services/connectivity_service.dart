import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _subscription;
  
  final isConnected = true.obs;

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnectivity();
    _subscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _checkInitialConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      debugPrint('Connectivity Error: $e');
    }
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    // If result is not 'none', we are connected
    final hasConnection = result != ConnectivityResult.none;
    
    if (isConnected.value && !hasConnection) {
      // Just went offline
      _showNoInternetSnackbar();
    } else if (!isConnected.value && hasConnection) {
      // Just came back online
      _showBackOnlineSnackbar();
    }
    
    isConnected.value = hasConnection;
  }

  void _showNoInternetSnackbar() {
    Get.rawSnackbar(
      title: 'No Internet Connection',
      message: 'Please check your network settings.',
      isDismissible: false,
      duration: const Duration(days: 1), // Stay until online
      backgroundColor: Colors.red[800]!,
      icon: const Icon(Icons.wifi_off_rounded, color: Colors.white),
      snackPosition: SnackPosition.TOP,
      mainButton: TextButton(
        onPressed: () => Get.back(),
        child: const Text('DISMISS', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showBackOnlineSnackbar() {
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }
    Get.rawSnackbar(
      title: 'Back Online',
      message: 'Connected to the internet.',
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.green[800]!,
      icon: const Icon(Icons.wifi_rounded, color: Colors.white),
      snackPosition: SnackPosition.TOP,
    );
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }
}
