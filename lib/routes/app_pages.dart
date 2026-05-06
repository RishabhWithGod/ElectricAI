import 'package:ai_app/modules/edit/edit_binding.dart';
import 'package:ai_app/modules/edit/edit_view.dart';
import 'package:ai_app/modules/home/home_binding.dart';
import 'package:ai_app/modules/home/home_view.dart';
import 'package:ai_app/modules/result/result_binding.dart';
import 'package:ai_app/modules/result/result_view.dart';
import 'package:ai_app/modules/upload/upload_binding.dart';
import 'package:ai_app/modules/upload/upload_view.dart';
import 'package:ai_app/routes/app_routes.dart';
import 'package:get/get.dart';

abstract final class AppPages {
  static final List<GetPage<dynamic>> pages = <GetPage<dynamic>>[
    GetPage<HomeView>(
      name: AppRoutes.home,
      page: HomeView.new,
      binding: HomeBinding(),
    ),
    GetPage<UploadView>(
      name: AppRoutes.upload,
      page: UploadView.new,
      binding: UploadBinding(),
    ),
    GetPage<ResultView>(
      name: AppRoutes.result,
      page: ResultView.new,
      binding: ResultBinding(),
    ),
    GetPage<EditView>(
      name: AppRoutes.edit,
      page: EditView.new,
      binding: EditBinding(),
    ),
  ];
}
