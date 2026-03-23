import 'package:get/get.dart';
import '../controllers/mentor_chat_controller.dart';

class MentorChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MentorChatController>(() => MentorChatController());
  }
}
