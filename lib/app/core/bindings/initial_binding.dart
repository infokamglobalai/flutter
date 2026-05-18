import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:najahapp/app/core/network/api_client.dart';
import 'package:najahapp/app/core/services/api_service.dart';
import 'package:najahapp/app/core/services/fcm_service.dart';
import 'package:najahapp/app/core/services/storage_service.dart';
import 'package:najahapp/app/data/repositories/auth_repository.dart';
import 'package:najahapp/app/data/repositories/content_hierarchy_repository.dart';
import 'package:najahapp/app/data/repositories/subscription_repository.dart';
import 'package:najahapp/app/data/services/brain_games_storage_service.dart';
import 'package:najahapp/app/data/services/coupon_service.dart';
import 'package:najahapp/app/data/services/data_service.dart';
import 'package:najahapp/app/data/services/guest_resource_service.dart';
import 'package:najahapp/app/data/services/mocktest_service.dart';
import 'package:najahapp/app/data/services/qna_service.dart';

import 'package:najahapp/app/core/services/connectivity_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Core Services
    // StorageService is initialized in main.dart. In widget tests, main.dart is
    // not executed, so we provide a minimal registration (tests should still
    // initialize it via Get.putAsync(() => StorageService().init())).
    if (!Get.isRegistered<StorageService>()) {
      Get.put(StorageService(), permanent: true);
    }
    Get.put(ConnectivityService(), permanent: true);
    Get.put(ApiClient(), permanent: true);
    Get.put(ApiService(), permanent: true);

    // Singleton DataService – shares the ApiService connection pool
    Get.put(DataService(), permanent: true);

    Get.lazyPut<MocktestService>(() => MocktestService(), fenix: true);
    Get.lazyPut<CouponService>(() => CouponService(), fenix: true);
    Get.lazyPut<GuestResourceService>(() => GuestResourceService(), fenix: true);
    Get.lazyPut<QnaService>(() => QnaService(), fenix: true);

    // Brain Games Storage Service
    Get.put(BrainGamesStorageService(), permanent: true);

    // Initialize FCM Service (will auto-start in onInit)
    // Only register when Firebase has been initialized.
    // This keeps widget tests (which don't run main()) from crashing.
    final hasFirebaseApp = Firebase.apps.isNotEmpty;
    if (hasFirebaseApp) {
      Get.put(FCMService(), permanent: true);
    }

    // Repositories
    Get.lazyPut<AuthRepository>(() => AuthRepository(), fenix: true);
    Get.lazyPut<ContentHierarchyRepository>(
      () => ContentHierarchyRepository(),
      fenix: true,
    );
    Get.lazyPut<SubscriptionRepository>(
      () => SubscriptionRepository(),
      fenix: true,
    );
  }
}
