// import 'package:flutter_doraemonkit/flutter_doraemonkit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_text/assembly_pack/desktop_list/desktop_sys_manager.dart';
import 'package:flutter_text/services/app_startup_service.dart';
import 'package:flutter_text/services/app_window_service.dart';
import 'package:flutter_text/splash.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:self_utils/init.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'init.dart';
import 'index.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppWindowService.initializeDesktopWindow();
  AppStartupService.registerSecurityKeyboard();
  AppStartupService.registerCoreControllers();

  runApp(ProviderScope(child: Assembly()));
}

///BotToastInit BotToastNavigatorObserver toast弹窗初始化
class Assembly extends StatefulWidget {
  @override
  AssemblyState createState() => AssemblyState();
}

class AssemblyState extends State<Assembly> {
  bool? todayShowAd;
  StreamSubscription<void>? _themeSubscription;

  List<ShortCutsModel> list = <ShortCutsModel>[
    ShortCutsModel(
      shortcutItem: const ShortcutItem(
        type: 'charts',
        localizedTitle: 'charts',
        icon: 'assets/images/sun.jpg',
      ),
      callBackFunc: () async {
        final NavigatorState navigatorHelper =
            await NavigatorHelper.navigatorState;
        navigatorHelper.push(
          MaterialPageRoute<void>(
              builder: (BuildContext context) => ListGroupPage()),
        );
      },
    )
  ];

  @override
  void initState() {
    AppStartupService.configurePlatformFlags();
    Future<void>.delayed(Duration.zero, () async {
      AppStartupService.registerQuickActions(list);
      await init();
    });
    super.initState();
  }

  Future<void> init() async {
    todayShowAd = await AppStartupService.initializeAppState();
    if (mounted) {
      setState(() {});
    }
    _listenTheme();
  }

  void _listenTheme() {
    _themeSubscription?.cancel();
    _themeSubscription = EventBusHelper.listen<EventBusM>((EventBusM event) {
      if (event.theme != '') {
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    _themeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenWidget(
      child: NavigatorInitializer(
        child: NotificationListenPage(
          child: AppLifecycleWidget(
            child: ModalStyleWidget(
              child: DesktopSysManager(
                child: GetMaterialApp(
                  builder: BotToastInit(),
                  showPerformanceOverlay: GlobalStore.isShowOverlay,
                  title: 'Flutter study',
                  theme: GlobalStore.theme == 'light'
                      ? ThemeData.light()
                      : ThemeData.dark(),
                  debugShowCheckedModeBanner: false,
                  localizationsDelegates: const <LocalizationsDelegate<
                      dynamic>>[
                    S.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  locale: GlobalStore.locale,
                  supportedLocales: S.delegate.supportedLocales,
                  navigatorObservers: <NavigatorObserver>[
                    BotToastNavigatorObserver()
                  ],
                  routes: <String, WidgetBuilder>{
                    'home': (BuildContext context) => MainIndexPage(),
                    'subjectDetectorTool': (BuildContext context) =>
                        const SubjectDetectorToolPage(),
                  },
                  home: GestureDetector(
                    onLongPress: () {
                      // setState(() {
                      //   GlobalStore.isShowOverlay = !GlobalStore.isShowOverlay;
                      // });
                      // FlutterDoraemonkit.toggle();
                    },
                    child: todayShowAd != null
                        ? (todayShowAd == true
                            ? GlobalStore.isShowGary
                                ? ColorFiltered(
                                    colorFilter: GlobalStore.greyScale,
                                    child: GlobalStore.isMobile
                                        ? MainIndexPage()
                                        : ManagementPage(),
                                  )
                                : GlobalStore.isMobile
                                    ? MainIndexPage()
                                    : ManagementPage()
                            : SplashPage())
                        : Container(
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
