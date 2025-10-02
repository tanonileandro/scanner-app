import '../../domain/entities/barcode_item.dart';

class BarcodeModel extends BarcodeItem {
  const BarcodeModel({
    required super.id,
    required super.code,
    required super.transport,
    required super.createdAt,
  });

  factory BarcodeModel.fromMap(Map<String, Object?> map) => BarcodeModel(
        id: map['id'] as String,
        code: map['code'] as String,
        transport: (map['transport'] as String?) ?? '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'code': code,
        'transport': transport,
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  static BarcodeModel fromEntity(BarcodeItem e) => BarcodeModel(
        id: e.id,
        code: e.code,
        transport: e.transport,
        createdAt: e.createdAt,
      );
}
