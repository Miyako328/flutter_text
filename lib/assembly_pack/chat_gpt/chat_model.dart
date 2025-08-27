class ChatModel {
  String text;
  num role;
  int timeStamp;

  ChatModel({required this.text, required this.role, required this.timeStamp});

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['text'] = text;
    map['role'] = role;
    map['timeStamp'] = timeStamp;
    return map;
  }

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
        text: json['text'] as String,
        role: json['role'] as num,
        timeStamp: json['timeStamp'] as int);
  }

  Map<String, dynamic> toJson() => _ChatModelToJson(this);

  Map<String, dynamic> _ChatModelToJson(value) {
    return <String, dynamic>{
      'text': value.text,
      'role': value.role,
      'timeStamp': value.timeStamp,
    };
  }

  static List<ChatModel> listFromJson(List<dynamic>? json) {
    return json == null
        ? <ChatModel>[]
        : json.map((e) => ChatModel.fromJson(e)).toList();
  }
}
