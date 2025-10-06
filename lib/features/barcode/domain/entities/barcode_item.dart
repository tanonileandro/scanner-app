class BarcodeItem {
  final String id;
  final String code;
  final String transport;     // nombre del transportista
  final String operatorName;  // persona de logística
  final int sessionSeq;       // N° de camión (sesión)
  final DateTime createdAt;

  const BarcodeItem({
    required this.id,
    required this.code,
    required this.transport,
    required this.operatorName,
    required this.sessionSeq,
    required this.createdAt,
  });
}
