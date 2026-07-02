import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../assembly_pack/get_builder_test/get_builder_test_page.dart';
import '../assembly_pack/moonlit_map/moonlit_idle_page.dart';
import '../assembly_pack/moonlit_map/moonlit_map_page.dart';
import '../models/main_widget_model.dart';

class MainController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  RxInt currentIndex = 0.obs;
  RxInt tapTimes = 0.obs;
  RxString? eventData = ''.obs;

  List<MainWidgetModel> page1 = <MainWidgetModel>[];
  List<MainWidgetModel> page2 = <MainWidgetModel>[];
  List<MainWidgetModel> page3 = <MainWidgetModel>[];

  @override
  void onInit() {
    super.onInit();
    _initData();
    _initTabController();
  }

  void _initData() {
    page1 = getPage1();
    page2 = getPage2();
    page3 = getPage3();
  }

  void _initTabController() {
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      currentIndex.value = tabController.index;
    });
  }

  void onTabTapped(int index) {
    currentIndex.value = index;
    tabController.animateTo(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.linear,
    );
  }

  void updateTapTimes(int times) {
    tapTimes.value = times;
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}

// 从index.init.dart中提取页面数据的方法
List<MainWidgetModel> getPage1() {
  return <MainWidgetModel>[
    MainWidgetModel(
      title: '月下地图册',
      route: const MoonlitMapPage(),
      icon: const Icon(Icons.map_outlined),
    ),
    MainWidgetModel(
      title: '月下远征',
      route: const MoonlitIdlePage(),
      icon: const Icon(Icons.explore_outlined),
    ),
    MainWidgetModel(
      title: 'chatGpt--',
      route: null, // 暂时设为null，避免导入错误
      icon: const Icon(Icons.chat),
    ),
    MainWidgetModel(
      title: '聊天列表--',
      route: null,
      icon: const Icon(Icons.chat),
    ),
    MainWidgetModel(
      title: ' markdown--',
      route: null,
      icon: const Icon(Icons.texture),
    ),
    MainWidgetModel(
      title: ' webRtc--',
      route: null,
      icon: const Icon(Icons.mediation),
    ),
    MainWidgetModel(
      title: ' webRtc list--',
      route: null,
      icon: const Icon(Icons.media_bluetooth_on_outlined),
    ),
    MainWidgetModel(
      title: ' webRtc--屏幕分享',
      route: null,
      icon: const Icon(Icons.mediation),
    ),
    MainWidgetModel(
      title: '${DateTime.now().millisecondsSinceEpoch}',
      route: null,
      icon: const Icon(Icons.numbers),
    ),
    MainWidgetModel(
      title: '视频通话装置--',
      route: null,
      icon: const Icon(Icons.video_call),
    ),
    MainWidgetModel(
      title: '本地视频播放--',
      route: null,
      icon: const Icon(Icons.ondemand_video),
    ),
    MainWidgetModel(
      title: '本地视频播放列表--',
      route: null,
      icon: const Icon(Icons.filter_list),
    ),
    MainWidgetModel(
      title: '音乐播放器--',
      route: null,
      icon: const Icon(Icons.music_note),
    ),
    MainWidgetModel(
      title: '图片压缩--',
      route: null,
      icon: const Icon(Icons.compress),
    ),
    MainWidgetModel(
      title: '视频压缩--',
      route: null,
      icon: const Icon(Icons.compress),
    ),
    MainWidgetModel(
      title: '视频背景登录--',
      route: null,
      icon: const Icon(Icons.videogame_asset),
    ),
    MainWidgetModel(
      title: '本地pdf查看--',
      route: null,
      icon: const Icon(Icons.picture_as_pdf),
    ),
    MainWidgetModel(
      title: 'paint--',
      route: null,
      icon: const Icon(Icons.format_paint),
    ),
    MainWidgetModel(
      title: 'Game 小游戏--',
      route: null,
      icon: const Icon(Icons.golf_course),
    ),
  ];
}

List<MainWidgetModel> getPage2() {
  return <MainWidgetModel>[
    MainWidgetModel(
      title: '动画容器--',
      route: null,
      icon: const Icon(Icons.animation),
    ),
    MainWidgetModel(
      title: '动画交叉淡入淡出--',
      route: null,
      icon: const Icon(Icons.animation),
    ),
    MainWidgetModel(
      title: '动画物理页面--',
      route: null,
      icon: const Icon(Icons.animation),
    ),
    MainWidgetModel(
      title: '动画文本--',
      route: null,
      icon: const Icon(Icons.text_fields),
    ),
    MainWidgetModel(
      title: '自动播放列表--',
      route: null,
      icon: const Icon(Icons.playlist_play),
    ),
    MainWidgetModel(
      title: '横幅演示--',
      route: null,
      icon: const Icon(Icons.view_carousel),
    ),
    MainWidgetModel(
      title: 'Bloc文本--',
      route: null,
      icon: const Icon(Icons.block),
    ),
    MainWidgetModel(
      title: '底部栏--',
      route: null,
      icon: const Icon(Icons.navigation),
    ),
    MainWidgetModel(
      title: 'Box--',
      route: null,
      icon: const Icon(Icons.check_box),
    ),
    MainWidgetModel(
      title: '日历--',
      route: null,
      icon: const Icon(Icons.calendar_today),
    ),
    MainWidgetModel(
      title: '聊天--',
      route: null,
      icon: const Icon(Icons.chat),
    ),
    MainWidgetModel(
      title: '选择语言--',
      route: null,
      icon: const Icon(Icons.language),
    ),
    MainWidgetModel(
      title: '选择座位--',
      route: null,
      icon: const Icon(Icons.event_seat),
    ),
    MainWidgetModel(
      title: '压缩--',
      route: null,
      icon: const Icon(Icons.compress),
    ),
    MainWidgetModel(
      title: '连接--',
      route: null,
      icon: const Icon(Icons.link),
    ),
    MainWidgetModel(
      title: '控制器测试--',
      route: null,
      icon: const Icon(Icons.control_camera),
    ),
    MainWidgetModel(
      title: '数据库--',
      route: null,
      icon: const Icon(Icons.storage),
    ),
    MainWidgetModel(
      title: '数据库注册--',
      route: null,
      icon: const Icon(Icons.app_registration),
    ),
    MainWidgetModel(
      title: '数据库测试--',
      route: null,
      icon: const Icon(Icons.verified),
    ),
    MainWidgetModel(
      title: '桌面列表--',
      route: null,
      icon: const Icon(Icons.desktop_mac),
    ),
    MainWidgetModel(
      title: 'DLL文本--',
      route: null,
      icon: const Icon(Icons.code),
    ),
    MainWidgetModel(
      title: '事件总线--',
      route: null,
      icon: const Icon(Icons.event),
    ),
    MainWidgetModel(
      title: '游戏--',
      route: null,
      icon: const Icon(Icons.games),
    ),
    MainWidgetModel(
      title: 'GetBuilder测试页面--',
      route: GetBuilderTestPage(),
      icon: const Icon(Icons.build),
    ),
    MainWidgetModel(
      title: 'GetX文本--',
      route: null,
      icon: const Icon(Icons.text_fields),
    ),
    MainWidgetModel(
      title: '高亮--',
      route: null,
      icon: const Icon(Icons.highlight),
    ),
    MainWidgetModel(
      title: '图片卡片--',
      route: null,
      icon: const Icon(Icons.image),
    ),
    MainWidgetModel(
      title: '介绍--',
      route: null,
      icon: const Icon(Icons.info),
    ),
    MainWidgetModel(
      title: 'J书--',
      route: null,
      icon: const Icon(Icons.book),
    ),
    MainWidgetModel(
      title: 'K线图--',
      route: null,
      icon: const Icon(Icons.show_chart),
    ),
    MainWidgetModel(
      title: '布局教学--',
      route: null,
      icon: const Icon(Icons.grid_view),
    ),
    MainWidgetModel(
      title: '懒加载列表--',
      route: null,
      icon: const Icon(Icons.list),
    ),
    MainWidgetModel(
      title: '本地通知--',
      route: null,
      icon: const Icon(Icons.notifications),
    ),
    MainWidgetModel(
      title: '登录--',
      route: null,
      icon: const Icon(Icons.login),
    ),
    MainWidgetModel(
      title: '管理--',
      route: null,
      icon: const Icon(Icons.manage_accounts),
    ),
    MainWidgetModel(
      title: 'Markdown--',
      route: null,
      icon: const Icon(Icons.text_format),
    ),
    MainWidgetModel(
      title: '扫雷--',
      route: null,
      icon: const Icon(Icons.grid_on),
    ),
    MainWidgetModel(
      title: 'MQTT文本--',
      route: null,
      icon: const Icon(Icons.message),
    ),
    MainWidgetModel(
      title: '音乐播放--',
      route: null,
      icon: const Icon(Icons.music_note),
    ),
    MainWidgetModel(
      title: '导航--',
      route: null,
      icon: const Icon(Icons.navigation),
    ),
    MainWidgetModel(
      title: '新拟态--',
      route: null,
      icon: const Icon(Icons.style),
    ),
    MainWidgetModel(
      title: '其他图表--',
      route: null,
      icon: const Icon(Icons.bar_chart),
    ),
    MainWidgetModel(
      title: '绘画--',
      route: null,
      icon: const Icon(Icons.brush),
    ),
    MainWidgetModel(
      title: '梨视频--',
      route: null,
      icon: const Icon(Icons.video_library),
    ),
    MainWidgetModel(
      title: '属性枚举--',
      route: null,
      icon: const Icon(Icons.category),
    ),
    MainWidgetModel(
      title: 'Provider--',
      route: null,
      icon: const Icon(Icons.settings),
    ),
    MainWidgetModel(
      title: '富文本--',
      route: null,
      icon: const Icon(Icons.text_format),
    ),
    MainWidgetModel(
      title: 'Riverpod--',
      route: null,
      icon: const Icon(Icons.water_drop),
    ),
    MainWidgetModel(
      title: '保存文本--',
      route: null,
      icon: const Icon(Icons.save),
    ),
    MainWidgetModel(
      title: '扫描书籍--',
      route: null,
      icon: const Icon(Icons.qr_code_scanner),
    ),
    MainWidgetModel(
      title: '刮刮乐--',
      route: null,
      icon: const Icon(Icons.brush),
    ),
    MainWidgetModel(
      title: '滑动图片--',
      route: null,
      icon: const Icon(Icons.swipe),
    ),
    MainWidgetModel(
      title: '排序组件--',
      route: null,
      icon: const Icon(Icons.sort),
    ),
    MainWidgetModel(
      title: '交错动画--',
      route: null,
      icon: const Icon(Icons.animation),
    ),
    MainWidgetModel(
      title: '数独--',
      route: null,
      icon: const Icon(Icons.grid_3x3),
    ),
    MainWidgetModel(
      title: '表格示例--',
      route: null,
      icon: const Icon(Icons.table_chart),
    ),
    MainWidgetModel(
      title: '翻译--',
      route: null,
      icon: const Icon(Icons.translate),
    ),
    MainWidgetModel(
      title: 'UDP--',
      route: null,
      icon: const Icon(Icons.network_check),
    ),
    MainWidgetModel(
      title: '单元--',
      route: null,
      icon: const Icon(Icons.science),
    ),
    MainWidgetModel(
      title: '视频聊天--',
      route: null,
      icon: const Icon(Icons.video_chat),
    ),
    MainWidgetModel(
      title: '视频播放器--',
      route: null,
      icon: const Icon(Icons.play_circle),
    ),
    MainWidgetModel(
      title: '天气--',
      route: null,
      icon: const Icon(Icons.wb_sunny),
    ),
    MainWidgetModel(
      title: 'WebRTC--',
      route: null,
      icon: const Icon(Icons.video_call),
    ),
    MainWidgetModel(
      title: 'WebView--',
      route: null,
      icon: const Icon(Icons.web),
    ),
  ];
}

List<MainWidgetModel> getPage3() {
  return <MainWidgetModel>[
    MainWidgetModel(
      title: '百度TTS--',
      route: null,
      icon: const Icon(Icons.record_voice_over),
    ),
    MainWidgetModel(
      title: '梨视频--',
      route: null,
      icon: const Icon(Icons.video_library),
    ),
    MainWidgetModel(
      title: '扫描书籍--',
      route: null,
      icon: const Icon(Icons.qr_code_scanner),
    ),
    MainWidgetModel(
      title: '聊天GPT--',
      route: null,
      icon: const Icon(Icons.chat),
    ),
    MainWidgetModel(
      title: '聊天列表--',
      route: null,
      icon: const Icon(Icons.chat),
    ),
    MainWidgetModel(
      title: '聊天室--',
      route: null,
      icon: const Icon(Icons.chat_bubble),
    ),
    MainWidgetModel(
      title: '用户登录--',
      route: null,
      icon: const Icon(Icons.login),
    ),
    MainWidgetModel(
      title: '用户注册--',
      route: null,
      icon: const Icon(Icons.person_add),
    ),
    MainWidgetModel(
      title: '用户变更--',
      route: null,
      icon: const Icon(Icons.person),
    ),
    MainWidgetModel(
      title: '聊天室--',
      route: null,
      icon: const Icon(Icons.chat_bubble_outline),
    ),
    MainWidgetModel(
      title: '聊天列表--',
      route: null,
      icon: const Icon(Icons.list),
    ),
    MainWidgetModel(
      title: '聊天详情--',
      route: null,
      icon: const Icon(Icons.chat_bubble),
    ),
    MainWidgetModel(
      title: '聊天输入--',
      route: null,
      icon: const Icon(Icons.input),
    ),
  ];
}
