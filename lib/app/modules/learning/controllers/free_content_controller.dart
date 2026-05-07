import 'package:get/get.dart';
import 'package:najahapp/app/data/services/guest_resource_service.dart';

class FreeContentController extends GetxController {
  final GuestResourceService _guestResourceService =
      Get.find<GuestResourceService>();

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxList<Map<String, dynamic>> resources = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    try {
      isLoading.value = true;
      error.value = '';
      final list = await _guestResourceService.getPublic();
      resources.assignAll(list);
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
      resources.clear();
    } finally {
      isLoading.value = false;
    }
  }
}

