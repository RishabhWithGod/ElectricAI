import 'package:ai_app/core/utils/app_snackbar.dart';
import 'package:ai_app/data/models/result_route_args.dart';
import 'package:ai_app/data/models/upload_history_model.dart';
import 'package:ai_app/data/services/api_service.dart';
import 'package:ai_app/data/services/local_storage_service.dart';
import 'package:ai_app/routes/app_routes.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

class UploadController extends GetxController {
  final ApiService _apiService = Get.find();
  final LocalStorageService _localStorageService = Get.find();

  final Rxn<PlatformFile> selectedFile = Rxn<PlatformFile>();
  final RxBool isUploading = false.obs;
  final RxDouble uploadProgress = 0.0.obs;

  Future<void> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const <String>['pdf'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      selectedFile.value = result.files.single;
    }
  }

  void clearSelection() {
    selectedFile.value = null;
    uploadProgress.value = 0;
  }

  Future<void> analyzeDrawing() async {
    final file = selectedFile.value;
    if (file == null) {
      AppSnackbar.showError('Select a PDF drawing before starting analysis.');
      return;
    }

    isUploading.value = true;
    uploadProgress.value = 0;

    try {
      final analysis = await _apiService.analyzeDrawing(
        fileName: file.name,
        filePath: file.path,
        fileBytes: file.bytes,
        onSendProgress: (int sent, int total) {
          if (total > 0) {
            uploadProgress.value = sent / total;
          }
        },
      );

      final session = UploadHistoryModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fileName: file.name,
        filePath: file.path,
        createdAt: DateTime.now(),
        items: analysis.items,
        grandTotal: analysis.grandTotal,
      );

      await _localStorageService.saveSession(session);

      Get.offNamed(
        AppRoutes.result,
        arguments: ResultRouteArgs(session: session, fileBytes: file.bytes),
      );
      AppSnackbar.showSuccess('Drawing analyzed successfully.');
    } catch (error) {
      AppSnackbar.showError(
        error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      isUploading.value = false;
    }
  }
}
