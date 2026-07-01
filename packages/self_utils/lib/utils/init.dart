import 'package:sentry/sentry.dart';

class ReportError {
  // 'https://ba709b0b128b46a183f63a5601dc49fd@o396530.ingest.sentry.io/5249966'
  final SentryClient _sentryClient = SentryClient(SentryOptions(
      dsn:
          'https://ba709b0b128b46a183f63a5601dc49fd@o396530.ingest.sentry.io/5249966'));

  bool get isInDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  Future<void> reportError(dynamic error, dynamic stackTrace) async {
    print('Caught error: $error');
    if (isInDebugMode) {
      print(stackTrace);
      return;
    } else {
      _sentryClient.captureException(
        error,
        stackTrace: stackTrace,
      );
    }
  }
}
