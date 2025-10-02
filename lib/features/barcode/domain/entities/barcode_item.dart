class BarcodeItem {
  final String id;         // uuid
  final String code;       // código leído
  final String transport;  // nombre del transportista seleccionado
  final DateTime createdAt;

  const BarcodeItem({
    required this.id,
    required this.code,
    required this.transport,
    required this.createdAt,
  });
}
