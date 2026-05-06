import 'package:ai_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract final class AppSnackbar {
  static void showError(String message) {
    _show(
      title: 'Something went wrong',
      message: message,
      color: AppColors.danger,
      icon: Icons.error_outline_rounded,
    );
  }

  static void showSuccess(String message) {
    _show(
      title: 'Success',
      message: message,
      color: AppColors.success,
      icon: Icons.check_circle_outline_rounded,
    );
  }

  static void showInfo(String message) {
    _show(
      title: 'Heads up',
      message: message,
      color: AppColors.accent,
      icon: Icons.info_outline_rounded,
    );
  }

  static void _show({
    required String title,
    required String message,
    required Color color,
    required IconData icon,
  }) {
    Get.closeAllSnackbars();
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      backgroundColor: AppColors.cardSoft,
      borderRadius: 18,
      borderColor: color.withOpacity(0.5),
      borderWidth: 1,
      icon: Icon(icon, color: color),
      colorText: AppColors.textPrimary,
      duration: const Duration(seconds: 3),
    );
  }
}
