import 'package:flutter_test/flutter_test.dart';
import 'package:self_utils/utils/isolate/isolate.dart';

void main() {
  test('isolate', () async {
    final String? get = await load();
    print(get);
  });

  test('isolate2', () async {
    final dynamic get2 = await loadT();
    print(get2);
  });

  test('isolate3', () async {
    final numbs = [10000, 20000, 30000, 40000];
    print('start');
    await for (final data in sendAndReceive(numbs)) {
      print(data.toString());
    }
    print('end');
  });

  test('isolate4', () async {
    final Iterable<String> get4 = getEmoji(10);
    get4.forEach((String element) {
      print('$element == ${DateTime.now().millisecondsSinceEpoch}');
    });
  });

  test('isolate5', () {
    final Iterable<String> get5 = getEmojiWithTime(10);
    get5.forEach((String element) {
      print('$element');
    });
  });
}