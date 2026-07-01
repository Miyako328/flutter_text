// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "appName": MessageLookupByLibrary.simpleMessage("Flutter Utils"),
        "easy": MessageLookupByLibrary.simpleMessage("easy"),
        "gameOverText": MessageLookupByLibrary.simpleMessage(
            "You lose!But Dont Mind,Try again will better"),
        "gameOverTitle": MessageLookupByLibrary.simpleMessage("O!"),
        "gamePlay": MessageLookupByLibrary.simpleMessage("Game Difficulty"),
        "hard": MessageLookupByLibrary.simpleMessage("hard"),
        "langSetting": MessageLookupByLibrary.simpleMessage("lang setting"),
        "mineSweeping":
            MessageLookupByLibrary.simpleMessage("Mine Sweeping Game!"),
        "normal": MessageLookupByLibrary.simpleMessage("normal"),
        "playAgain": MessageLookupByLibrary.simpleMessage("Play Again"),
        "settingTitle": MessageLookupByLibrary.simpleMessage("Game Setting!"),
        "themeColor":
            MessageLookupByLibrary.simpleMessage("Choose Theme Color"),
        "winText": MessageLookupByLibrary.simpleMessage("You win!Time is "),
        "winTitle": MessageLookupByLibrary.simpleMessage("Congratulation!!")
      };
}
