import 'package:ai_app/core/utils/app_snackbar.dart';
import 'package:ai_app/data/models/item_model.dart';
import 'package:ai_app/data/models/upload_history_model.dart';
import 'package:ai_app/data/services/local_storage_service.dart';
import 'package:get/get.dart';

class EditController extends GetxController {
  final LocalStorageService _localStorageService = Get.find();

  late final UploadHistoryModel originalSession;
  final RxList<ItemModel> items = <ItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;

    if (arguments is UploadHistoryModel) {
      originalSession = arguments;
      items.assignAll(
        arguments.items.map(
          (ItemModel item) => item.copyWith(),
        ),
      );
    }
  }

  double get grandTotal => items.fold<double>(
        0,
        (double sum, ItemModel item) => sum + item.total,
      );

  void updateName(int index, String value) {
    items[index] = items[index].copyWith(name: value);
  }

  void updateCount(int index, String value) {
    final count = int.tryParse(value) ?? 0;
    items[index] = items[index].copyWith(count: count);
  }

  void updateRate(int index, String value) {
    final rate = double.tryParse(value) ?? 0;
    items[index] = items[index].copyWith(rate: rate);
  }

  void addNewItem() {
    items.add(const ItemModel(name: 'New Item', count: 1, rate: 0));
  }

  void removeItem(int index) {
    items.removeAt(index);
  }

  Future<void> saveChanges() async {
    final sanitizedItems = items
        .where((ItemModel item) => item.name.trim().isNotEmpty)
        .map((ItemModel item) => item.copyWith(name: item.name.trim()))
        .toList();

    if (sanitizedItems.isEmpty) {
      AppSnackbar.showError('Add at least one valid item before saving.');
      return;
    }

    final updatedSession = originalSession.copyWith(
      items: sanitizedItems,
      grandTotal: sanitizedItems.fold<double>(
        0,
        (double sum, ItemModel item) => sum + item.total,
      ),
      createdAt: DateTime.now(),
    );

    await _localStorageService.updateSession(updatedSession);
    Get.back<UploadHistoryModel>(result: updatedSession);
    AppSnackbar.showSuccess('Changes saved successfully.');
  }
}
