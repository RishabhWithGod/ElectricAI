import 'dart:typed_data';

import 'dart:typed_data';

import 'package:ai_app/core/utils/app_snackbar.dart';
import 'package:ai_app/data/models/result_route_args.dart';
import 'package:ai_app/data/models/upload_history_model.dart';
import 'package:ai_app/data/services/api_service.dart';
import 'package:ai_app/data/services/local_storage_service.dart';
import 'package:ai_app/data/services/pdf_export_service.dart';
import 'package:ai_app/routes/app_routes.dart';
import 'package:get/get.dart';

class ResultController extends GetxController {
  final ApiService _apiService = Get.find();
  final LocalStorageService _localStorageService = Get.find();
  final PdfExportService _pdfExportService = Get.find();

  final Rxn<UploadHistoryModel> session = Rxn<UploadHistoryModel>();
  final RxBool isRefreshing = false.obs;
  final RxBool isExporting = false.obs;

  Uint8List? _fileBytes;

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;

    if (arguments is ResultRouteArgs) {
      session.value = arguments.session;
      _fileBytes = arguments.fileBytes;
    } else if (arguments is UploadHistoryModel) {
      session.value = arguments;
    }
  }

  Future<void> refreshAnalysis() async {
    final current = session.value;
    if (current == null) {
      return;
    }

    if ((_fileBytes == null || _fileBytes!.isEmpty) &&
        (current.filePath == null || current.filePath!.isEmpty)) {
      AppSnackbar.showInfo(
        'Original PDF is unavailable for re-analysis. Upload the drawing again to refresh.',
      );
      return;
    }

    isRefreshing.value = true;
    try {
      final analysis = await _apiService.analyzeDrawing(
        fileName: current.fileName,
        filePath: current.filePath,
        fileBytes: _fileBytes != null ? Uint8List.fromList(_fileBytes!) : null,
      );

      final updated = current.copyWith(
        items: analysis.items,
        grandTotal: analysis.grandTotal,
        createdAt: DateTime.now(),
      );

      session.value = updated;
      await _localStorageService.updateSession(updated);
      AppSnackbar.showSuccess('Results refreshed successfully.');
    } catch (error) {
      AppSnackbar.showError(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> openEdit() async {
    final current = session.value;
    if (current == null) {
      return;
    }

    final updated = await Get.toNamed(AppRoutes.edit, arguments: current);
    if (updated is UploadHistoryModel) {
      session.value = updated;
    }
  }

  Future<void> downloadBoq() async {
    final current = session.value;
    if (current == null) {
      return;
    }

    isExporting.value = true;
    try {
      final filePath = await _pdfExportService.saveBoqPdf(current);
      AppSnackbar.showSuccess('BOQ saved to $filePath');
    } catch (error) {
      AppSnackbar.showError('Unable to export BOQ right now.');
    } finally {
      isExporting.value = false;
    }
  }

  Future<void> shareBoq() async {
    final current = session.value;
    if (current == null) {
      return;
    }

    isExporting.value = true;
    try {
      await _pdfExportService.shareBoqPdf(current);
    } catch (error) {
      AppSnackbar.showError('Unable to share the BOQ right now.');
    } finally {
      isExporting.value = false;
    }
  }
}
