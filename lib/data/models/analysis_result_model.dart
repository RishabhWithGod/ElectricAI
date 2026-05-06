import 'package:ai_app/data/models/item_model.dart';

class AnalysisResultModel {
  const AnalysisResultModel({
    required this.items,
    required this.grandTotal,
  });

  final List<ItemModel> items;
  final double grandTotal;

  factory AnalysisResultModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? <dynamic>[];
    final items = itemsJson
        .map((dynamic item) => ItemModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return AnalysisResultModel(
      items: items,
      grandTotal: (json['grand_total'] as num?)?.toDouble() ??
          items.fold<double>(0, (double sum, ItemModel item) => sum + item.total),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'items': items.map((ItemModel item) => item.toJson()).toList(),
      'grand_total': grandTotal,
    };
  }
}
