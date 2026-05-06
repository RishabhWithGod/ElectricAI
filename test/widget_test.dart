import 'package:ai_app/app.dart';
import 'package:ai_app/data/services/api_service.dart';
import 'package:ai_app/data/services/local_storage_service.dart';
import 'package:ai_app/data/services/pdf_export_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    Get.reset();
    SharedPreferences.setMockInitialValues(<String, Object>{});

    final localStorageService = LocalStorageService();
    await localStorageService.init();

    Get.put<ApiService>(ApiService(), permanent: true);
    Get.put<LocalStorageService>(localStorageService, permanent: true);
    Get.put<PdfExportService>(PdfExportService(), permanent: true);
  });

  tearDown(Get.reset);

  testWidgets('renders home screen upload CTA', (WidgetTester tester) async {
    await tester.pumpWidget(const DrawingEstimatorApp());
    await tester.pumpAndSettle();

    expect(find.text('AI Drawing Estimator'), findsWidgets);
    expect(find.text('Upload Drawing'), findsOneWidget);
  });
}
