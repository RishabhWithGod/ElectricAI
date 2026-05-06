import 'package:ai_app/core/theme/app_colors.dart';
import 'package:ai_app/core/utils/app_formatters.dart';
import 'package:ai_app/core/widgets/app_scaffold.dart';
import 'package:ai_app/core/widgets/custom_button.dart';
import 'package:ai_app/core/widgets/custom_text_field.dart';
import 'package:ai_app/core/widgets/empty_state_widget.dart';
import 'package:ai_app/data/models/item_model.dart';
import 'package:ai_app/modules/edit/edit_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditView extends GetView<EditController> {
  const EditView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Edit BOQ',
      bottomNavigationBar: Obx(
        () => Container(
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
                    'Updated Total',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    AppFormatters.currency(controller.grandTotal),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              CustomButton(
                label: 'Save Changes',
                icon: Icons.save_outlined,
                onPressed: controller.saveChanges,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.addNewItem,
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.backgroundStart,
        label: const Text('Add Item'),
        icon: const Icon(Icons.add_rounded),
      ),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 170),
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
                    'Fine-tune the estimate',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Adjust quantities, update rates, remove incorrect entries, or add missing items. Totals refresh automatically as you edit.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (controller.items.isEmpty)
              EmptyStateWidget(
                title: 'No editable items yet',
                subtitle:
                    'Tap Add Item to create a new BOQ entry and start building the estimate.',
                icon: Icons.playlist_add_circle_outlined,
                actionLabel: 'Add Item',
                onActionPressed: controller.addNewItem,
              )
            else
              ...List<Widget>.generate(
                controller.items.length,
                (int index) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _EditableItemCard(
                    index: index,
                    item: controller.items[index],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EditableItemCard extends GetView<EditController> {
  const _EditableItemCard({
    required this.index,
    required this.item,
  });

  final int index;
  final ItemModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Item ${index + 1}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => controller.removeItem(index),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CustomTextField(
            fieldKey: ValueKey<String>('name_${index}_${item.name}'),
            labelText: 'Item name',
            initialValue: item.name,
            onChanged: (String value) => controller.updateName(index, value),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: CustomTextField(
                  fieldKey: ValueKey<String>('count_${index}_${item.count}'),
                  labelText: 'Count',
                  initialValue: item.count.toString(),
                  keyboardType: TextInputType.number,
                  onChanged: (String value) =>
                      controller.updateCount(index, value),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  fieldKey: ValueKey<String>('rate_${index}_${item.rate}'),
                  labelText: 'Rate',
                  initialValue: item.rate.toStringAsFixed(0),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (String value) =>
                      controller.updateRate(index, value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Total: ${AppFormatters.currency(item.total)}',
                style: const TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
