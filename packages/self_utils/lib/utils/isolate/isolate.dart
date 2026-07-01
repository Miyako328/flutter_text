import 'dart:io';
import 'dart:isolate';
import 'package:async/async.dart';

///isolate是dart的线程 通过isolate可以实现dart的多线程
///每个isolate都有自己的事件循环
///isolate在flutter并不共享内存，不同isolate通过消息进行通信
///另外一个可以帮助你决定使用 Future 或 Isolate 的因素是运行某些代码所需要的平均时间。
///
/// 如果一个方法需要几毫秒 => Future
/// 如果一个处理流程需要几百毫秒 => Isolate
///
/// 以下是一些很好的 Isolate 选项：
///
/// JSON 解码：解码 JSON（HttpRequest 的响应）可能需要一些时间 => 使用 compute
/// 加密：加密可能非常耗时 => Isolate
/// 图像处理：处理图像（比如：剪裁）确实需要一些时间来完成 => Isolate
/// 从 Web 加载图像：该场景下，为什么不将它委托给一个完全加载后返回完整图像的 Isolate？
///
///

Future<String?> load() async {
  final ReceivePort receivePort = ReceivePort(); //创建管道
  await Isolate.spawn(messageIso, receivePort.sendPort);
  await for (dynamic msg in receivePort) {
    if (msg is SendPort) {
      final SendPort sendPort = msg;
      sendPort.send('isolate with number ');
      print('isolate with msg');
    } else {
      print('ReceivePort get msg is $msg');
      receivePort.close();
      return msg;
    }
  }
  return null;
}

void messageIso(SendPort sendPort) async {
  final ReceivePort receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort); //取请求数据
  final String url = await receivePort.first;
  receivePort.close();

  sendPort.send(url + '12312313');
  print('取请求数据');
}

/// loadT
Future<dynamic> loadT() async {
  final ReceivePort receivePort = ReceivePort();
  Isolate.spawn(info, receivePort.sendPort);
  return receivePort.first;
}

void info(SendPort sendPort) async {
  Isolate.exit(sendPort, '测试exit');
}

///主线程
///具体的iso实现（主线程）
Stream<int> sendAndReceive(List<int> numbs) async* {
  final p = ReceivePort();
  await Isolate.spawn(_entry, p.sendPort);
  final StreamQueue events = StreamQueue<dynamic>(p); // import 'package:async/async.dart';

// 拿到 子isolate传递过来的 SendPort 用于发送数据
  final SendPort sendPort = await events.next;
  for (int num in numbs) {
    sendPort.send(num);
    final int message = await events.next;
    yield message;
  }
//发送 null 作为结束标识符
  sendPort.send(null);
  await events.cancel();
}

///具体的iso实现（子线程）
Future<void> _entry(SendPort p) async {
  final commandPort = ReceivePort();
  p.send(commandPort.sendPort);
  await for (final message in commandPort) {
    if (message is int) {
      final data = calculateEvenCount(message);
      p.send(data);
    } else if (message == null) {
      commandPort.close();
      break;
    }
  }
}

///计算偶数个数（具体的耗时操作）下面示例代码中会用到
int calculateEvenCount(int num) {
  int count = 0;
  while (num > 0) {
    if (num % 2 == 0) {
      count++;
    }
    num--;
  }
  return count;
}


/// sync* 多元素同步
/// yield关键字有点像return，但是它是单次返回值，并不会像return直接结束整个函数
//
Iterable<String> getEmoji(int count) sync* {
  Runes runes = Runes('\u{1f47a}');
  for (int i =0; i<count; i++) {
    yield String.fromCharCodes(runes.map((e) => e + i));
    sleep(const Duration(seconds: 1));
  }
}

Iterable<String> getEmojiWithTime(int count) sync* {
  yield* getEmoji(count).map((e) => '$e == ${DateTime.now().millisecondsSinceEpoch}');
}