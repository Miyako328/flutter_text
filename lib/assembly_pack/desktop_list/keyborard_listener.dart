import '../../init.dart';

class KeyBoardListenerPage extends StatefulWidget {
  const KeyBoardListenerPage({Key? key}) : super(key: key);

  @override
  State<KeyBoardListenerPage> createState() => _KeyBoardListenerPageState();
}

//todo 可以监听键盘，但是不太行
class _KeyBoardListenerPageState extends State<KeyBoardListenerPage> {
  final FocusNode _node = FocusNode();

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KeyBoardListenerPage'),
      ),
      body: KeyboardListener(
        autofocus: true,
        onKeyEvent: (KeyEvent event) {
          Log.info(event);
        },
        focusNode: _node,
        child: const SizedBox.shrink(),
      ),
    );
  }
}
