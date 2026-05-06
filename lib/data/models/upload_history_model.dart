import 'package:ai_app/data/models/item_model.dart';

class UploadHistoryModel {
  const UploadHistoryModel({
    required this.id,
    required this.fileName,
    required this.createdAt,
    required this.items,
    required this.grandTotal,
    this.filePath,
  });

  final String id;
  final String fileName;
  final String? filePath;
  final DateTime createdAt;
  final List<ItemModel> items;
  final double grandTotal;

  int get detectedObjects => items.fold<int>(
        0,
        (int sum, ItemModel item) => sum + item.count,
      );

  UploadHistoryModel copyWith({
    String? id,
    String? fileName,
    String? filePath,
    DateTime? createdAt,
    List<ItemModel>? items,
    double? grandTotal,
  }) {
    return UploadHistoryModel(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
      grandTotal: grandTotal ?? this.grandTotal,
    );
  }

  factory UploadHistoryModel.fromJson(Map<String, dynamic> json) {
    return UploadHistoryModel(
      id: json['id'] as String,
      fileName: json['file_name'] as String,
      filePath: json['file_path'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      items: (json['items'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic item) => ItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'file_name': fileName,
      'file_path': filePath,
      'created_at': createdAt.toIso8601String(),
      'items': items.map((ItemModel item) => item.toJson()).toList(),
      'grand_total': grandTotal,
    };
  }
}
