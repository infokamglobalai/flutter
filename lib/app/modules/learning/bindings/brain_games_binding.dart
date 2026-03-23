import 'package:get/get.dart';
import 'package:najahapp/app/data/services/brain_games_storage_service.dart';
import '../controllers/brain_games_controller.dart';

class BrainGamesBinding extends Bindings {
  @override
  void dependencies() {
    // Put storage service first, as controller depends on it
    Get.put<BrainGamesStorageService>(
      BrainGamesStorageService(),
      permanent: true,
    );
    Get.lazyPut<BrainGamesController>(() => BrainGamesController());
  }
}
