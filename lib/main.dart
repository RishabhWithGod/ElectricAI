import 'package:ai_app/app.dart';
import 'package:ai_app/data/services/api_service.dart';
import 'package:ai_app/data/services/local_storage_service.dart';
import 'package:ai_app/data/services/pdf_export_service.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localStorageService = LocalStorageService();
  await localStorageService.init();

  Get.put<ApiService>(ApiService(), permanent: true);
  Get.put<LocalStorageService>(localStorageService, permanent: true);
  Get.put<PdfExportService>(PdfExportService(), permanent: true);

  runApp(const DrawingEstimatorApp());
}
