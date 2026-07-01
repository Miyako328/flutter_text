// import 'package:dio/dio.dart';
// import 'package:flutter_shortcuts/flutter_shortcuts.dart';
// import 'package:self_utils/utils/toast_utils.dart';
//
// import 'shortcuts_model.dart';
//
// //单例app图标长按菜单
// class ShortCutsInit {
//   static ShortCutsInit? _init;
//
//   static final FlutterShortcuts _flutterShortcuts = FlutterShortcuts();
//
//   factory ShortCutsInit({required List<ShortCutsModel> shortCutList}) =>
//       _init ?? ShortCutsInit._this(shortCutList);
//
//   static List<ShortCutsModel> _list = [];
//
//   static Lock lock = Lock();
//
//   ShortCutsInit._this(List<ShortCutsModel> list) {
//     _list = list;
//     _flutterShortcuts.initialize(debug: true);
//     _flutterShortcuts.listenAction((String key) {
//       _getShortcuts(key);
//     });
//     _init = this;
//     _setShortcuts();
//   }
//
//   //处理shortcuts
//   static void _getShortcuts(String key) async {
//     lock.lock();
//     ToastUtils.showToast(msg: '正在前往$key...');
//     await Future<void>.delayed(const Duration(seconds: 2));
//     final ShortCutsModel result =
//         _list.firstWhere((e) => e.shortcutItem.action == key);
//     result.callBackFunc.call();
//     lock.unlock();
//   }
//
//   //设置shortcuts
//   static void _setShortcuts() {
//     _flutterShortcuts.setShortcutItems(
//       shortcutItems: _list.map((e) => e.shortcutItem).toList(),
//     );
//   }
// }
