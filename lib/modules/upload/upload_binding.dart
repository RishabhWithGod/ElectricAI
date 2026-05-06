import 'package:ai_app/modules/upload/upload_controller.dart';
import 'package:get/get.dart';

class UploadBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UploadController>(UploadController.new);
  }
}
