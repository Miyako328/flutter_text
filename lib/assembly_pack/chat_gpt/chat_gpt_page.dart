import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:self_utils/init.dart' show DateTimeHelper;

import 'chat_model.dart';

class Send extends Intent {}

// AIzaSyB9CytQv69FK0VH6ehO6eXMgxVEPTo0hxA
class ChatGptPage extends StatefulWidget {
  const ChatGptPage({Key? key}) : super(key: key);

  @override
  State<ChatGptPage> createState() => _ChatGptPageState();
}

const Color backgroundColor = Color(0xff343541);
const Color botBackgroundColor = Color(0xff444654);

class _ChatGptPageState extends State<ChatGptPage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final safetySettings = [
    SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
    SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
    SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
    SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
  ];
  final List<ChatModel> _messages = [];
  late GenerativeModel model;

  late bool isLoading;

  void init() async {
    model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: 'AIzaSyB9CytQv69FK0VH6ehO6eXMgxVEPTo0hxA',
        safetySettings: safetySettings);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    isLoading = false;
    init();
  }

  @override
  Widget build(BuildContext context) {
    // pc快捷键
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.enter): Send(),
      },
      child: Actions(
        actions: {
          Send: CallbackAction<Send>(
              onInvoke: (intent) => _sendMessage()),
        },
        child: Scaffold(
          appBar: Platform.isMacOS || Platform.isWindows || Platform.isLinux
              ? null
              : AppBar(
            title: const Text('ChatGpt text'),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: _buildList(),
                ),
                Visibility(
                  visible: isLoading,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      _buildInput(),
                      _buildSubmit(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _sendMessage() async {
    // 设置发送中的状态，显示加载动画
    setState(() {
        isLoading = true;
    });
    var input = _textController.text;
    // 创建用户消息模型并加入消息列表
    final ChatModel my = ChatModel(
        text: input,
        role: 0,
        timeStamp: DateTimeHelper.getLocalTimeStamp());
    setState(() {
      _messages.add(my);
    });
    // 延迟50毫秒后滚动到消息列表底部
    Future<void>.delayed(const Duration(milliseconds: 50))
        .then((_) => _scrollDown());
    _textController.clear(); // 清空输入框
    // 准备内容并生成机器回复
    final List<Content> content = [Content.text('$input')];
    final GenerateContentResponse response =
    await model.generateContent(content);
    // 如果有回复，则添加机器消息到消息列表并更新状态
    if (response.text != null && response.text!.isNotEmpty) {
      final ChatModel robot = ChatModel(
          text: response.text!,
          role: 1,
          timeStamp: DateTimeHelper.getLocalTimeStamp());
      setState(() {
        _messages.add(robot);
        isLoading = false; // 发送完成，隐藏加载动画
      });
      // 延迟50毫秒后滚动到消息列表底部
      Future<void>.delayed(const Duration(milliseconds: 50))
          .then((_) => _scrollDown());
    }
  }


  Widget _buildSubmit() {
    return Visibility(
      visible: !isLoading,
      child: Container(
        child: IconButton(
          icon: const Icon(
            Icons.send_rounded,
            color: Color.fromRGBO(142, 142, 160, 1),
          ),
          onPressed: () async {
            _sendMessage();
          },
        ),
      ),
    );
  }

  Expanded _buildInput() {
    return Expanded(
      child: TextField(
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(color: Colors.black),
        controller: _textController,
        decoration: const InputDecoration(
          filled: true,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
      ),
    );
  }

  ListView _buildList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        var message = _messages[index];
        return ChatMessageWidget(
          text: message.text,
          chatMessageType: message.role,
        );
      },
    );
  }

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}

class ChatMessageWidget extends StatelessWidget {
  const ChatMessageWidget({required this.text, required this.chatMessageType});

  final String text;
  final dynamic chatMessageType;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          chatMessageType == 1
              ? Container(
                  margin: const EdgeInsets.only(right: 16.0),
                  child: const CircleAvatar(
                    backgroundColor: Color.fromRGBO(16, 163, 127, 1),
                    child: Text('G'),
                  ),
                )
              : Container(
                  margin: const EdgeInsets.only(right: 16.0),
                  child: const CircleAvatar(
                    child: Icon(
                      Icons.person,
                    ),
                  ),
                ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: chatMessageType == 1
                            ? Colors.lightBlue
                            : Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
