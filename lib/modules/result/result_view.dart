import 'package:ai_app/core/theme/app_colors.dart';
import 'package:ai_app/core/utils/app_formatters.dart';
import 'package:ai_app/core/widgets/app_scaffold.dart';
import 'package:ai_app/core/widgets/custom_button.dart';
import 'package:ai_app/core/widgets/empty_state_widget.dart';
import 'package:ai_app/core/widgets/item_card.dart';
import 'package:ai_app/modules/result/result_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResultView extends GetView<ResultController> {
  const ResultView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Analysis Result',
      actions: <Widget>[
        Obx(
          () => IconButton(
            onPressed:
                controller.isExporting.value ? null : controller.shareBoq,
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Share BOQ',
          ),
        ),
      ],
      bottomNavigationBar: Obx(
        () {
          final session = controller.session.value;
          if (session == null) {
            return const SizedBox.shrink();
          }

          return Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
            decoration: BoxDecoration(
              color: AppColors.backgroundStart.withOpacity(0.96),
              border: Border(
                top: BorderSide(color: AppColors.border.withOpacity(0.7)),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Text(
                      'Grand Total',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      AppFormatters.currency(session.grandTotal),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: CustomButton(
                        label: 'Edit',
                        icon: Icons.edit_outlined,
                        isOutlined: true,
                        onPressed: controller.openEdit,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        label: 'Download BOQ',
                        icon: Icons.download_rounded,
                        isLoading: controller.isExporting.value,
                        onPressed: controller.downloadBoq,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      body: Obx(
        () {
          final session = controller.session.value;
          if (session == null) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: EmptyStateWidget(
                title: 'No result data found',
                subtitle:
                    'Upload a drawing or open a recent analysis to view extracted items.',
                icon: Icons.analytics_outlined,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.refreshAnalysis,
            color: AppColors.accent,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 180),
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: AppColors.cardGradient,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              session.fileName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              '${session.detectedObjects} objects',
                              style: const TextStyle(
                                color: AppColors.accentSoft,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Last updated ${AppFormatters.dateTime(session.createdAt)}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 18),
                      if (controller.isRefreshing.value)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            minHeight: 8,
                            backgroundColor: Colors.white.withOpacity(0.08),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.accent,
                            ),
                          ),
                        )
                      else
                        const Text(
                          'Pull down to re-run the backend analysis.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Detected items',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                if (session.items.isEmpty)
                  const EmptyStateWidget(
                    title: 'No items detected',
                    subtitle:
                        'The analysis completed, but the backend did not return any detected objects.',
                    icon: Icons.search_off_rounded,
                  )
                else
                  ...session.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: ItemCard(item: item),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
