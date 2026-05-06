import 'package:ai_app/core/theme/app_colors.dart';
import 'package:ai_app/core/utils/app_formatters.dart';
import 'package:ai_app/core/widgets/app_scaffold.dart';
import 'package:ai_app/core/widgets/custom_button.dart';
import 'package:ai_app/core/widgets/empty_state_widget.dart';
import 'package:ai_app/core/widgets/loading_widget.dart';
import 'package:ai_app/data/models/upload_history_model.dart';
import 'package:ai_app/modules/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Obx(
        () {
          if (controller.isLoading.value) {
            return const LoadingWidget(message: 'Loading recent analyses...');
          }

          return RefreshIndicator(
            onRefresh: controller.loadHistory,
            color: AppColors.accent,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: <Widget>[
                _HeroPanel(history: controller.history),
                const SizedBox(height: 24),
                CustomButton(
                  label: 'Upload Drawing',
                  icon: Icons.upload_file_rounded,
                  onPressed: controller.openUpload,
                ),
                const SizedBox(height: 28),
                const Text(
                  'Recent uploads',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                if (controller.history.isEmpty)
                  EmptyStateWidget(
                    title: 'No drawings analyzed yet',
                    subtitle:
                        'Upload your first PDF drawing to get object counts, cost estimates, and an editable BOQ.',
                    icon: Icons.auto_awesome_mosaic_rounded,
                    actionLabel: 'Upload Now',
                    onActionPressed: controller.openUpload,
                  )
                else
                  ...controller.history.map(_HistoryCard.new),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.history,
  });

  final List<UploadHistoryModel> history;

  @override
  Widget build(BuildContext context) {
    final totalProjects = history.length;
    final totalValue = history.fold<double>(
      0,
      (double sum, UploadHistoryModel item) => sum + item.grandTotal,
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF163A69), Color(0xFF0C1D37)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'AI-powered BOQ workflow',
              style: TextStyle(
                color: AppColors.accentSoft,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'AI Drawing Estimator',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          const Text(
            'Upload electrical or architectural drawings, extract detected objects, and turn them into editable cost estimates in seconds.',
            style: TextStyle(
              color: AppColors.textSecondary,
              height: 1.5,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: <Widget>[
              Expanded(
                child: _SummaryChip(
                  label: 'Projects',
                  value: totalProjects.toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryChip(
                  label: 'Estimated value',
                  value: AppFormatters.currency(totalValue),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends GetView<HomeController> {
  const _HistoryCard(this.session);

  final UploadHistoryModel session;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => controller.openHistory(session),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: <Widget>[
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: AppColors.accentSoft,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      session.fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppFormatters.dateTime(session.createdAt),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        Text(
                          '${session.items.length} items',
                          style: const TextStyle(
                            color: AppColors.accentSoft,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          AppFormatters.currency(session.grandTotal),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
