import 'package:get/get.dart';
import 'package:najahapp/app/modules/packages/controllers/all_packages_controller.dart';

class AllPackagesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AllPackagesController>(() => AllPackagesController());
  }
}
