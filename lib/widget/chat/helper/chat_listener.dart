part of 'chat_helper.dart';

//消息总管道
class ChatMsgConduit {
  static List<MqttReceivedMessage<MqttMessage>> msgList =
      <MqttReceivedMessage<MqttMessage>>[];

  static void listener() {
    ChatHelper.client?.updates
        ?.listen((List<MqttReceivedMessage<MqttMessage>> event) {
      final MqttPublishMessage m = event[0].payload as MqttPublishMessage;
      msgSendCenter(event[0]);
      Log.info(
        'ChatMsgConduit listener ${event[0].topic} '
        '${utf8.decode(m.payload.message)}',
      );
    });
  }

  static void msgSendCenter(MqttReceivedMessage<MqttMessage> event) {
    msgList.add(event);
    MessageControl.sendMsg(EventChat()..msg = event);
  }

  //获取对应topic的记录
  static List<MqttReceivedMessage<MqttMessage>> getMsgWithTopic(String topic) {
    return msgList
        .where((MqttReceivedMessage<MqttMessage> element) =>
            element.topic == topic)
        .toList();
  }

  static void sendOutMsg(String topic, String msg) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addUTF8String(msg);
    ChatHelper.client
        ?.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
  }
}
