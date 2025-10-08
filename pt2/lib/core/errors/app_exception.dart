/// Base application exception for user-friendly error messages.
class AppException implements Exception {
  AppException(this.message, {this.stackTrace});

  final String message;
  final StackTrace? stackTrace;

  @override
  String toString() => message;
}
