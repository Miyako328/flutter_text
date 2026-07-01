import 'package:quick_actions/quick_actions.dart';
import 'package:self_utils/utils/shortcuts/shortcuts_model.dart';

class ShortCutsQuick {
  static ShortCutsQuick? _shortCutsQuick;

  static List<ShortCutsModel> _shortCutsAction = [];

  factory ShortCutsQuick({required List<ShortCutsModel> shortCutsAction}) =>
      _shortCutsQuick ?? ShortCutsQuick._init(shortCutsAction);

  ShortCutsQuick._init(List<ShortCutsModel> list) {
    _shortCutsAction = list;
    QuickActions quickActions = const QuickActions();
    quickActions.initialize((type) {
      ShortCutsModel action = _shortCutsAction
          .firstWhere((element) => element.shortcutItem.type == type);
      action.callBackFunc.call();
    });
    quickActions
        .setShortcutItems(_shortCutsAction.map((e) => e.shortcutItem).toList());
    _shortCutsQuick = this;
  }
}
