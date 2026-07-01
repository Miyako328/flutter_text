class ApiException implements Exception {
  int code = 0;
  String? message;
  Object? innerException;
  StackTrace? stackTrace;
  String? level;

  bool get enableErrorLog =>
      level != null &&
          level?.isNotEmpty == true &&
          level != '友好提示' &&
          level != '0';

  ApiException(this.code, this.message, [this.level]);

  ApiException.withInner(
      this.code, this.message, this.innerException, this.stackTrace);

  String toString() {
    if (message?.isNotEmpty != true) {
      return '服务器异常';
    }

    if (innerException == null) {
      return '$message';
    }

    return "ApiException $code: $message ${level ?? ''} (Inner exception: $innerException)\n\n" +
        stackTrace.toString();
  }
}