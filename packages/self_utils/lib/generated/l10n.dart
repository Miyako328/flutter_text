// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Flutter Utils`
  String get appName {
    return Intl.message(
      'Flutter Utils',
      name: 'appName',
      desc: '',
      args: [],
    );
  }

  /// `lang setting`
  String get langSetting {
    return Intl.message(
      'lang setting',
      name: 'langSetting',
      desc: '',
      args: [],
    );
  }

  /// `Mine Sweeping Game!`
  String get mineSweeping {
    return Intl.message(
      'Mine Sweeping Game!',
      name: 'mineSweeping',
      desc: '',
      args: [],
    );
  }

  /// `Congratulation!!`
  String get winTitle {
    return Intl.message(
      'Congratulation!!',
      name: 'winTitle',
      desc: '',
      args: [],
    );
  }

  /// `You win!Time is `
  String get winText {
    return Intl.message(
      'You win!Time is ',
      name: 'winText',
      desc: '',
      args: [],
    );
  }

  /// `Play Again`
  String get playAgain {
    return Intl.message(
      'Play Again',
      name: 'playAgain',
      desc: '',
      args: [],
    );
  }

  /// `Game Setting!`
  String get settingTitle {
    return Intl.message(
      'Game Setting!',
      name: 'settingTitle',
      desc: '',
      args: [],
    );
  }

  /// `Choose Theme Color`
  String get themeColor {
    return Intl.message(
      'Choose Theme Color',
      name: 'themeColor',
      desc: '',
      args: [],
    );
  }

  /// `Game Difficulty`
  String get gamePlay {
    return Intl.message(
      'Game Difficulty',
      name: 'gamePlay',
      desc: '',
      args: [],
    );
  }

  /// `easy`
  String get easy {
    return Intl.message(
      'easy',
      name: 'easy',
      desc: '',
      args: [],
    );
  }

  /// `normal`
  String get normal {
    return Intl.message(
      'normal',
      name: 'normal',
      desc: '',
      args: [],
    );
  }

  /// `hard`
  String get hard {
    return Intl.message(
      'hard',
      name: 'hard',
      desc: '',
      args: [],
    );
  }

  /// `O!`
  String get gameOverTitle {
    return Intl.message(
      'O!',
      name: 'gameOverTitle',
      desc: '',
      args: [],
    );
  }

  /// `You lose!But Dont Mind,Try again will better`
  String get gameOverText {
    return Intl.message(
      'You lose!But Dont Mind,Try again will better',
      name: 'gameOverText',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
