import 'package:get/get.dart';
import 'package:najahapp/app/modules/subscriptions/controllers/my_subscriptions_controller.dart';

class MySubscriptionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MySubscriptionsController>(() => MySubscriptionsController());
  }
}
