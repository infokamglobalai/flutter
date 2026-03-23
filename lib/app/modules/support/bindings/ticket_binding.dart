import 'package:get/get.dart';
import 'package:najahapp/app/modules/support/controllers/ticket_controller.dart';

class TicketBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TicketController>(() => TicketController());
  }
}
