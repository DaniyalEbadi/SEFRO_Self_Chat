class AppLogger {
  AppLogger._();

  static void info(String message) {
    // ignore: avoid_print
    print('[INFO] $message');
  }

  static void warning(String message) {
    // ignore: avoid_print
    print('[WARNING] $message');
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    // ignore: avoid_print
    print('[ERROR] $message');
    if (error != null) {
      // ignore: avoid_print
      print('  Cause: $error');
    }
    if (stackTrace != null) {
      // ignore: avoid_print
      print('  Stack: $stackTrace');
    }
  }

  static void debug(String message) {
    // ignore: avoid_print
    print('[DEBUG] $message');
  }

  static void api(String method, String path, int statusCode) {
    // ignore: avoid_print
    print('[API] $method $path -> $statusCode');
  }
}
