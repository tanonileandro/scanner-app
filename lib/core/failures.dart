class Failure implements Exception {
  final String message;
  final Object? cause;
  final StackTrace? stack;
  Failure(this.message, {this.cause, this.stack});

  @override
  String toString() => 'Failure($message)';
}
