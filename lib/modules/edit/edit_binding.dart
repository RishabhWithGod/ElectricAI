import 'package:ai_app/modules/edit/edit_controller.dart';
import 'package:get/get.dart';

class EditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditController>(EditController.new);
  }
}
