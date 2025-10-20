import 'dart:developer' as developer;

/// Simple application logger for debugging and monitoring.
class AppLogger {
  final String _name;

  const AppLogger(this._name);

  /// Log debug message
  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: _name,
      error: error,
      stackTrace: stackTrace,
      level: 500,
    );
  }

  /// Log info message
  void info(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: _name,
      error: error,
      stackTrace: stackTrace,
      level: 800,
    );
  }

  /// Log warning message
  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: _name,
      error: error,
      stackTrace: stackTrace,
      level: 900,
    );
  }

  /// Log error message
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: _name,
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }
}
