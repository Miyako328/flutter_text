import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotification extends StatefulWidget {
  @override
  LocalNotificationState createState() => LocalNotificationState();
}

class LocalNotificationState extends State<LocalNotification> {
  FlutterLocalNotificationsPlugin fNotification =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    const AndroidInitializationSettings android =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: android);
    fNotification.initialize(initSettings, onDidReceiveNotificationResponse: onSelectNotification);
  }

  Future<void> onSelectNotification(NotificationResponse? payload) async {
    debugPrint('payload : $payload');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Notification'),
        content: Text('$payload'),
      ),
    );
  }

  @override
  void dispose() {
    fNotification.cancel(0);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('本地消息推送'),
      ),
      body: Center(
        child: InkWell(
          onTap: showNotification,
          child: Text(
            'Demo',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ),
    );
  }

  void showNotification() async {
    const AndroidNotificationDetails android = AndroidNotificationDetails(
        'channel id', 'channel NAME',
        priority: Priority.high, importance: Importance.max);
    const iOS =  DarwinNotificationDetails();
    const platform = NotificationDetails(android: android, iOS: iOS);
    await fNotification.show(
        0, '本地推送测试标题', '本地推送测试内容', platform,
        payload: '测试测试');
  }
}
