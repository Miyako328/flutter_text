import 'package:quick_actions/quick_actions.dart';

typedef ShortCutsFunc = void Function();

class ShortCutsModel {
  ShortcutItem shortcutItem;
  ShortCutsFunc callBackFunc;

  ShortCutsModel({required this.shortcutItem, required this.callBackFunc});
}
