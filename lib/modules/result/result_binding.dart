import 'package:ai_app/modules/result/result_controller.dart';
import 'package:get/get.dart';

class ResultBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ResultController>(ResultController.new);
  }
}
