class ItemModel {
  const ItemModel({
    required this.name,
    required this.count,
    required this.rate,
    double? total,
  }) : total = total ?? count * rate;

  final String name;
  final int count;
  final double rate;
  final double total;

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    final count = (json['count'] as num?)?.toInt() ?? 0;
    final rate = (json['rate'] as num?)?.toDouble() ?? 0;

    return ItemModel(
      name: json['name'] as String? ?? 'Unnamed Item',
      count: count,
      rate: rate,
      total: (json['total'] as num?)?.toDouble() ?? count * rate,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'count': count,
      'rate': rate,
      'total': total,
    };
  }

  ItemModel copyWith({
    String? name,
    int? count,
    double? rate,
    double? total,
  }) {
    final updatedCount = count ?? this.count;
    final updatedRate = rate ?? this.rate;

    return ItemModel(
      name: name ?? this.name,
      count: updatedCount,
      rate: updatedRate,
      total: total ?? updatedCount * updatedRate,
    );
  }
}
