import 'package:ai_app/data/models/result_route_args.dart';
import 'package:ai_app/data/models/upload_history_model.dart';
import 'package:ai_app/data/services/local_storage_service.dart';
import 'package:ai_app/routes/app_routes.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final LocalStorageService _localStorageService = Get.find();

  final RxList<UploadHistoryModel> history = <UploadHistoryModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  Future<void> loadHistory() async {
    isLoading.value = true;
    history.assignAll(_localStorageService.getHistory());
    isLoading.value = false;
  }

  Future<void> openUpload() async {
    await Get.toNamed(AppRoutes.upload);
    await loadHistory();
  }

  Future<void> openHistory(UploadHistoryModel session) async {
    await Get.toNamed(
      AppRoutes.result,
      arguments: ResultRouteArgs(session: session),
    );
    await loadHistory();
  }
}
