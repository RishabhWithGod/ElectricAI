import 'package:ai_app/core/theme/app_theme.dart';
import 'package:ai_app/routes/app_pages.dart';
import 'package:ai_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DrawingEstimatorApp extends StatelessWidget {
  const DrawingEstimatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AI Drawing Estimator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.home,
      getPages: AppPages.pages,
      defaultTransition: Transition.cupertino,
    );
  }
}
