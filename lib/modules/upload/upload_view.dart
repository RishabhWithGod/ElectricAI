import 'package:ai_app/core/theme/app_colors.dart';
import 'package:ai_app/core/widgets/app_scaffold.dart';
import 'package:ai_app/core/widgets/custom_button.dart';
import 'package:ai_app/modules/upload/upload_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UploadView extends GetView<UploadController> {
  const UploadView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Upload Drawing',
      body: Obx(
        () {
          final PlatformFile? selectedFile = controller.selectedFile.value;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: AppColors.cardGradient,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Upload a PDF drawing for analysis',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'We will send your drawing to the AI backend, extract detected objects, estimate costs, and prepare an editable BOQ.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: selectedFile == null
                        ? AppColors.border
                        : AppColors.accent,
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 72,
                      width: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accent.withOpacity(0.14),
                      ),
                      child: const Icon(
                        Icons.picture_as_pdf_rounded,
                        color: AppColors.accentSoft,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      selectedFile?.name ?? 'No PDF selected',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      selectedFile == null
                          ? 'Supported format: PDF only'
                          : '${(selectedFile.size / 1024).toStringAsFixed(2)} KB',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: CustomButton(
                            label: 'Choose PDF',
                            icon: Icons.upload_file_rounded,
                            onPressed: controller.pickPdf,
                          ),
                        ),
                        if (selectedFile != null) ...<Widget>[
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomButton(
                              label: 'Clear',
                              icon: Icons.close_rounded,
                              isOutlined: true,
                              onPressed: controller.clearSelection,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (controller.isUploading.value) ...<Widget>[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Uploading and analyzing...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: controller.uploadProgress.value == 0
                              ? null
                              : controller.uploadProgress.value,
                          minHeight: 10,
                          backgroundColor: Colors.white.withOpacity(0.08),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.accent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        controller.uploadProgress.value == 0
                            ? 'Waiting for server response...'
                            : '${(controller.uploadProgress.value * 100).toStringAsFixed(0)}% uploaded',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              CustomButton(
                label: 'Analyze Drawing',
                icon: Icons.auto_awesome_rounded,
                isLoading: controller.isUploading.value,
                onPressed: controller.analyzeDrawing,
              ),
            ],
          );
        },
      ),
    );
  }
}
