import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:self_utils/init.dart';
import 'package:self_utils/utils/log_colorful.dart';

void main() {
  test('array_unique', () {
    List<String> a = ['ab', 'c', 'd', 'd', 'e', 'ab', 'd'];
    print(ArrayHelper.unique(listData: a, getKey: (String item) => item));
  });

  test('lock test', () async {
    Lock lock = Lock();
    int count = 0;
    int i = 0;

    await Future.wait(Iterable.generate(
        3,
        (_) => Future(() async {
              await lock.lock();

              ///Func
              count++;
              print('add$count');
              await Future.delayed(const Duration(milliseconds: 10));
              count--;
              print('cut$count');
              expect(count, 0);

              lock.unlock();
              i++;

              print('fin$i');
            })));
    expect(i, 3);
  });

  test('mixin', () {
    A a = A();
    B b = B();
    D d = D();
    a.eat();
    b.eat();
    d.eat();
  });

  test('containList', () {
    final result = ArrayHelper.containList(['0', 4], [0, 4, 8]);
    expect(result, false);
  });

  test('a', () {
    RegExp regex = RegExp(r'^[A-Z-]+[-A-Z]$');
    print(regex.hasMatch('NI-AVG-NOV'));
  });

  test('log', () {
    int? a;
    a.log();
  });

  test('print with color', () {
    //\x1B[35m {内容} \x1B[0m 打印带颜色
    print('\x1B[35m 紫色hello world \x1B[0m');
    print('\x1B[31m 红色hello world \x1B[0m');
    print('\x1B[1;35m 紫色粗体hello world \x1B[0m');
    print('\x1B[1m 粗体 \x1B[0m');
    print('\x1B[4m 下划线hello world \x1B[0m');
  });

  test('salt', () {
    final res = Encrypt.encryptToBase64('password');
    print(res);
  });

  test('flatten', () {
    final multiArray = [
      [1, 2],
      [3, 4],
      [5, 6],
    ];
    final res = ArrayHelper.flatten(multiArray);
    print(res);
  });

  test('random', () {
    final index = Random().nextInt(20);
    print(index);
  });
}
