class Session {
  final int seq;              // Camión N°
  final String mode;          // 'cargar' | 'descargar'
  final String transport;
  final String operatorName;
  final DateTime createdAt;
  final String status;        // 'draft' | 'finalized'

  const Session({
    required this.seq,
    required this.mode,
    required this.transport,
    required this.operatorName,
    required this.createdAt,
    required this.status,
  });
}
