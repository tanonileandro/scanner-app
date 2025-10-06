import '../../domain/entities/barcode_item.dart';

class BarcodeModel extends BarcodeItem {
  const BarcodeModel({
    required super.id,
    required super.code,
    required super.transport,
    required super.operatorName,
    required super.sessionSeq,
    required super.createdAt,
  });

  factory BarcodeModel.fromMap(Map<String, Object?> map) => BarcodeModel(
        id: map['id'] as String,
        code: map['code'] as String,
        transport: (map['transport'] as String?) ?? '',
        operatorName: (map['operator_name'] as String?) ?? '',
        sessionSeq: (map['session_seq'] as int?) ?? -1,
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'code': code,
        'transport': transport,
        'operator_name': operatorName,
        'session_seq': sessionSeq,
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  static BarcodeModel fromEntity(BarcodeItem e) => BarcodeModel(
        id: e.id,
        code: e.code,
        transport: e.transport,
        operatorName: e.operatorName,
        sessionSeq: e.sessionSeq,
        createdAt: e.createdAt,
      );
}

