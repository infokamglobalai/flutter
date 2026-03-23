import 'package:get/get.dart';
import 'package:najahapp/app/core/network/api_client.dart';
import 'package:najahapp/app/core/services/api_service.dart';
import 'package:najahapp/app/core/services/fcm_service.dart';
import 'package:najahapp/app/data/repositories/auth_repository.dart';
import 'package:najahapp/app/data/repositories/content_hierarchy_repository.dart';
import 'package:najahapp/app/data/repositories/subscription_repository.dart';
import 'package:najahapp/app/data/services/brain_games_storage_service.dart';
import 'package:najahapp/app/data/services/data_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Core Services
    // StorageService is already initialized in main.dart
    Get.put(ApiClient(), permanent: true);
    Get.put(ApiService(), permanent: true);

    // Singleton DataService – shares the ApiService connection pool
    Get.put(DataService(), permanent: true);

    // Brain Games Storage Service
    Get.put(BrainGamesStorageService(), permanent: true);

    // Initialize FCM Service (will auto-start in onInit)
    Get.put(FCMService(), permanent: true);

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
