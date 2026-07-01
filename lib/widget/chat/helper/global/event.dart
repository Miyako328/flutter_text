import 'package:mqtt_client/mqtt_client.dart';

class EventChat {
  MqttReceivedMessage<MqttMessage>? msg;
}

class DbGlobal {
  static String ip = '192.168.1.108';
  static int port = 18199;
  static String database = 'flutter_text';
  static String username = 'flutter_text';
  static String password = 'LJcdfbjA2mR8m7m2';
}
