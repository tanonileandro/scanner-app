sealed class Result<T> {
  const Result();
  factory Result.ok(T data) = Ok<T>;
  factory Result.err(String message, [Object? error, StackTrace? stack]) = Err<T>;
}
class Ok<T> extends Result<T> {
  final T data;
  const Ok(this.data);
}
class Err<T> extends Result<T> {
  final String message;
  final Object? error;
  final StackTrace? stack;
  const Err(this.message, [this.error, this.stack]);
}
