/// Sealed-like result type for success/failure handling.
sealed class Result<T> {
  const Result();
}

/// Success result with data.
class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

/// Failure result with error message.
class Failure<T> extends Result<T> {
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  const Failure(this.message, {this.error, this.stackTrace});
}

/// Extension methods for Result type.
extension ResultExtension<T> on Result<T> {
  /// Returns true if this is a Success.
  bool get isSuccess => this is Success<T>;

  /// Returns true if this is a Failure.
  bool get isFailure => this is Failure<T>;

  /// Returns the data if Success, otherwise null.
  T? get dataOrNull => this is Success<T> ? (this as Success<T>).data : null;

  /// Returns the error message if Failure, otherwise null.
  String? get errorOrNull =>
      this is Failure<T> ? (this as Failure<T>).message : null;

  /// Transforms the data if Success, otherwise returns the same Failure.
  Result<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      Success(:final data) => Success(transform(data)),
      Failure(:final message, :final error, :final stackTrace) => Failure(
        message,
        error: error,
        stackTrace: stackTrace,
      ),
    };
  }

  /// Executes appropriate callback based on result type.
  R when<R>({
    required R Function(T data) success,
    required R Function(String message, Object? error) failure,
  }) {
    return switch (this) {
      Success(:final data) => success(data),
      Failure(:final message, :final error) => failure(message, error),
    };
  }
}
