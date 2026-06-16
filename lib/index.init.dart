part of 'index.dart';

List<MainWidgetModel> page1 = <MainWidgetModel>[
  // MainWidgetModel(
  //   title: '聊天室--',
  //   route: ChatPackApp(),
  //   icon: const Icon(Icons.chat),
  // ),
  // MainWidgetModel(
  //   title: 'udp--',
  //   route: UdpTestPage(),
  //   icon: const Icon(Icons.chat),
  // ),
  MainWidgetModel(
    title: 'chatGpt--',
    route: const ChatGptPage(),
    icon: const Icon(Icons.chat),
  ),
  MainWidgetModel(
    title: '聊天列表--',
    route: ChatListWidget(),
    icon: const Icon(Icons.chat),
  ),
  MainWidgetModel(
    title: ' markdown--',
    route: const MarkdownEditor(),
    icon: const Icon(Icons.texture),
  ),
  MainWidgetModel(
    title: ' webRtc--',
    route: const GetUserMediaPage(),
    icon: const Icon(Icons.mediation),
  ),
  MainWidgetModel(
    title: ' webRtc list--',
    route: CallSample(),
    icon: const Icon(Icons.media_bluetooth_on_outlined),
  ),
  MainWidgetModel(
    title: ' webRtc--屏幕分享',
    route: const GetDisplayMediaPage(),
    icon: const Icon(Icons.mediation),
  ),
  MainWidgetModel(
    title: '${1637898885.getLocalTimeStamp}',
    route: null,
    icon: const Icon(Icons.numbers),
  ),
  MainWidgetModel(
    title: '视频通话装置--',
    route: CheckRoomId(),
    icon: const Icon(Icons.video_call),
  ),
  MainWidgetModel(
    title: '本地视频播放--',
    route: VideoIndex(),
    icon: const Icon(Icons.ondemand_video),
  ),
  MainWidgetModel(
    title: '本地视频播放列表--',
    route: VideoList(),
    icon: const Icon(Icons.filter_list),
  ),
  MainWidgetModel(
    title: '音乐播放器--',
    route: MusicPlayPage(),
    icon: const Icon(Icons.music_note),
  ),
  MainWidgetModel(
    title: '图片压缩--',
    route: ImageCompressPage(),
    icon: const Icon(Icons.compress),
  ),
  MainWidgetModel(
    title: '视频压缩--',
    route: VideoCompressPage(),
    icon: const Icon(Icons.compress),
  ),
  MainWidgetModel(
    title: '视频背景登录--',
    route: LoginVideoPage(),
    icon: const Icon(Icons.videogame_asset),
  ),
  MainWidgetModel(
    title: '本地pdf查看--',
    route: PdfRead(),
    icon: const Icon(Icons.picture_as_pdf),
  ),
  MainWidgetModel(
    title: 'paint--',
    route: const PaintMain(),
    icon: const Icon(Icons.format_paint),
  ),
  MainWidgetModel(
    title: 'Game 小游戏--',
    route: const GameListPage(),
    icon: const Icon(Icons.golf_course),
  ),
  MainWidgetModel(
    title: '本地pdf下载--',
    route: pdfView(),
    icon: const Icon(Icons.file_download),
  ),
  // MainWidgetModel(
  //   title: '检查连接数据--',
  //   route: const ConnectWidget(),
  //   icon: const Icon(Icons.wifi),
  // ),
  MainWidgetModel(
    title: '录音--',
    route: MicStreamDemo(),
    icon: const Icon(Icons.volume_up),
  ),
  MainWidgetModel(
    title: 'SqlLite--',
    route: TestDb(),
    icon: const Icon(Icons.storage),
  ),
  MainWidgetModel(
    title: '骨架屏--',
    route: SkeletonView(),
    icon: const Icon(Icons.shopping_basket_outlined),
  ),
  MainWidgetModel(
    title: 'register--',
    route: RegisterPage(),
    icon: const Icon(Icons.recent_actors),
  ),
  MainWidgetModel(
    title: 'mqtt--',
    route: RealTimeListPage(),
    icon: const Icon(Icons.chat),
  ),
  MainWidgetModel(
    title: 'storage--',
    route: StorageTest(),
    icon: const Icon(Icons.storage),
  ),
  MainWidgetModel(
    title: 'scheme url--',
    route: SchemeText(),
    icon: const Icon(Icons.web),
  ),
  MainWidgetModel(
    title: '本地消息推送--',
    route: LocalNotification(),
    icon: const Icon(Icons.messenger_outline_sharp),
  ),
  MainWidgetModel(
    title: '本地消息推送2--',
    route: LocalNotificationList(),
    icon: const Icon(Icons.messenger_rounded),
  ),
  MainWidgetModel(
    title: 'provider text--',
    route: ProviderTextPage(),
    icon: const Icon(Icons.precision_manufacturing_rounded),
  ),
  MainWidgetModel(
    title: 'bloc text--',
    route: BlocTextWidget(),
    icon: const Icon(Icons.app_blocking),
  ),
  MainWidgetModel(
    title: 'url scheme text--',
    route: null,
    onTapFunc: (_) {
      launch('market://details?id=com.example.exhibition');
    },
    icon: const Icon(Icons.scanner),
  ),
  MainWidgetModel(
    title: 'Getx text--',
    route: null,
    onTapFunc: (BuildContext context) async {
      final String? result = await NavigatorUtils.getXOfPush<String>(
          context, GetxTextPage(),
          arguments: <String, dynamic>{'count': 10});
      Log.info('result: $result');
    },
    icon: const Icon(Icons.airplanemode_on),
  ),
  MainWidgetModel(
    title: 'dll 测试页面--',
    route: DllTextPage(),
    icon: const Icon(Icons.dirty_lens),
  ),
  MainWidgetModel(
    title: 'Google 相册解析--',
    route: GoogleView(),
    icon: const Icon(Icons.photo_library),
  ),
  MainWidgetModel(
    title: 'iCloud 相册解析--',
    route: ICloudView(),
    icon: const Icon(Icons.cloud),
  )
];

List<MainWidgetModel> page2 = <MainWidgetModel>[
  MainWidgetModel(
    title: 'StudyCenter 学习中心',
    route: const StudyCenterPage(),
    icon: const Icon(Icons.book_rounded),
  ),
  MainWidgetModel(
    title: 'Flutter Svg 使用',
    route: const SvgTestPage(),
    icon: const Icon(Icons.picture_in_picture_sharp),
  ),
  MainWidgetModel(
    title: 'chip 使用',
    route: const ChipPageTest(),
    icon: const Icon(Icons.catching_pokemon),
  ),
  MainWidgetModel(
    title: 'PropertyEnum(属性枚举) 使用',
    route: const PropertyEnum(),
    icon: const Icon(Icons.energy_savings_leaf_sharp),
  ),
  MainWidgetModel(
    title: 'AnimationsTextKit 使用',
    route: const AnimationsTextPage(),
    icon: const Icon(Icons.text_fields),
  ),
  MainWidgetModel(
    title: '选座',
    route: ChooseSeat(),
    icon: const Icon(Icons.event_seat),
  ),
  MainWidgetModel(
    title: 'ShellTest',
    route: ShellTest(),
    icon: const Icon(Icons.keyboard),
  ),
  MainWidgetModel(
    title: 'DebounceTPage',
    route: DebounceTPage(),
    icon: const Icon(Icons.keyboard),
  ),
  MainWidgetModel(
    title: 'RiverPodTest',
    route: const RiverPodTestPage(),
    icon: const Icon(Icons.add_to_drive_rounded),
  ),
  MainWidgetModel(
    title: 'TextStyleTest',
    route: TextStyleTest(),
    icon: const Icon(Icons.keyboard),
  ),
  MainWidgetModel(
    title: '闪闪',
    route: const ScratchInfo(),
    icon: const Icon(Icons.flash_auto),
  ),
  MainWidgetModel(
    title: 'redis',
    route: const RedisTest(),
    icon: const Icon(Icons.keyboard),
  ),
  MainWidgetModel(
    title: 'lazy list',
    route: LazyListPage(),
    icon: const Icon(Icons.list_sharp),
  ),
  MainWidgetModel(
    title: 'normal list',
    route: NormalListPage(),
    icon: const Icon(Icons.list_sharp),
  ),
  MainWidgetModel(
    title: '组件能力库',
    route: const ComponentLibraryPage(),
    icon: const Icon(Icons.view_in_ar_outlined),
  ),
  MainWidgetModel(
    title: 'ImageCardPage',
    route: const ImageCardPage(),
    icon: const Icon(Icons.image_aspect_ratio_sharp),
  ),
  MainWidgetModel(
    title: 'PopupTextPage',
    route: PopupTextPage(),
    icon: const Icon(Icons.pool_outlined),
  ),
  MainWidgetModel(
    title: 'Controller',
    route: TestControlPage(),
    icon: const Icon(Icons.control_camera),
  ),
  MainWidgetModel(
    title: '解析gif',
    route: DecodeGifPage(),
    icon: const Icon(Icons.gif),
  ),
  MainWidgetModel(
    title: 'Sliding Image使用',
    route: SlideImagePage(),
    icon: const Icon(Icons.image),
  ),
  MainWidgetModel(
    title: 'api测试',
    route: ApiTextPage(),
    icon: const Icon(Icons.api),
  ),
  MainWidgetModel(
    title: 'MouseTextPage',
    route: MouseTextPage(),
    icon: const Icon(Icons.mouse),
  ),
  MainWidgetModel(
    title: '普通charts的使用',
    route: ListGroupPage(),
    icon: const Icon(Icons.show_chart),
  ),
  MainWidgetModel(
    title: 'PCKeyboardPage使用',
    route: PCKeyboardPage(),
    icon: const Icon(Icons.keyboard),
  ),
  MainWidgetModel(
    title: 'TextInputTest',
    route: TextInputTest(),
    icon: const Icon(Icons.keyboard),
  ),
  MainWidgetModel(
    title: 'Cache Image Page',
    route: CacheImagePage(),
    icon: const Icon(Icons.image_search),
  ),
  MainWidgetModel(
    title: 'inheried',
    route: InheritedShowPage(),
    icon: const Icon(Icons.texture_sharp),
  ),
  MainWidgetModel(
    title: 'kchart',
    route: KChartPage(),
    icon: const Icon(Icons.flash_auto),
  ),
  MainWidgetModel(
    title: 'text',
    route: KChartPage(),
    icon: const Icon(Icons.keyboard),
  ),
  MainWidgetModel(
    title: '搜索',
    route: SearchDemoPage(),
    icon: const Icon(Icons.flash_auto),
  ),
  MainWidgetModel(
    title: 'MarkDownPage',
    route: const MarkDownPage(),
    icon: const Icon(Icons.mark_as_unread),
  ),
  MainWidgetModel(
    title: 'NavigationTest',
    route: const NavigationTest(),
    icon: const Icon(Icons.tab),
  ),
  MainWidgetModel(
    title: '金融list',
    onTapFunc: (BuildContext context) {
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => DemoPage(MediaQuery.of(context).size)),
      );
    },
    icon: const Icon(Icons.flash_auto),
  ),
  MainWidgetModel(
    title: '分组列表',
    route: GroupListPage(),
    icon: const Icon(Icons.group_add),
  ),
  MainWidgetModel(
    title: 'Log日志',
    route: const LogInfoPage(),
    icon: const Icon(Icons.logo_dev),
  ),
  MainWidgetModel(
    title: '悬浮弹窗',
    onTapFunc: (context) {
      DragOverlay.show(context: context, view: GroupListPage());
    },
    icon: const Icon(Icons.group_add),
  ),
  MainWidgetModel(
    title: 'ReFresh使用',
    route: RefreshPage(),
    icon: const Icon(Icons.line_style_rounded),
  ),
  MainWidgetModel(
    title: 'intro 引导教程页',
    route: IntroPage(),
    icon: const Icon(Icons.line_style_rounded),
  ),
  MainWidgetModel(
    title: 'modal Utils使用',
    onTapFunc: (context) {
      ModalText.tipToast(context);
    },
    icon: const Icon(Icons.flash_auto),
  ),
  MainWidgetModel(
    title: 'SlidingUpPanelText使用',
    route: SlidingUpPanelText(),
    icon: const Icon(Icons.keyboard),
  ),
  MainWidgetModel(
    title: 'LayoutBuilder实验',
    route: const LayoutTestPage(),
    icon: const Icon(Icons.local_play_outlined),
  ),
  MainWidgetModel(
    title: 'StreamText',
    route: StreamTextPage(),
    icon: const Icon(Icons.stream),
  ),
  MainWidgetModel(
    title: '测试',
    route: TextT(),
    icon: const Icon(Icons.settings),
  ),
  MainWidgetModel(
    title: '获取package info',
    route: GetPackageWidget(),
    icon: const Icon(Icons.backpack),
  ),
  MainWidgetModel(
    title: 'Box合集',
    route: BoxPage(),
    icon: const Icon(Icons.account_box),
  ),
  MainWidgetModel(
    title: '扫图片条形码',
    route: ScanBook(),
    icon: const Icon(Icons.scanner),
  ),
  MainWidgetModel(
    title: '动画常用组件',
    route: AnimaComponentPage(),
    icon: const Icon(Icons.tablet_android),
  ),
  MainWidgetModel(
    title: '美食列表',
    route: MyApp(),
    icon: const Icon(Icons.fastfood),
  ),
  MainWidgetModel(
    title: 'slider',
    route: SearchDemoPage(),
    icon: const Icon(Icons.swap_horizontal_circle),
  ),
  MainWidgetModel(
    title: '两端滑块组件',
    route: RangeSliderPage(),
    icon: const Icon(Icons.slideshow),
  ),
  MainWidgetModel(
    title: '水平布局',
    route: layoutRow(),
    icon: const Icon(Icons.format_line_spacing),
  ),
  MainWidgetModel(
    title: '装饰容器',
    route: DecoratedBoxPage(),
    icon: const Icon(Icons.inbox),
  ),
  MainWidgetModel(
    title: '自定义表格列表（table）',
    route: TableListComponentPage(),
    icon: const Icon(Icons.table_bar),
  ),
  MainWidgetModel(
    title: '文本输入框',
    onTapFunc: (BuildContext context) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (BuildContext context) => TextFieldPage()),
      ).then((onValue) {
        print('返回回来的手机号是：' + onValue);
      });
    },
    icon: const Icon(Icons.input),
  ),
  MainWidgetModel(
    title: 'checkBox组件',
    route: CheckBoxListTitle(),
    icon: const Icon(Icons.check_box),
  ),
  MainWidgetModel(
    title: 'GridView组件',
    route: GridViewPage(),
    icon: const Icon(Icons.grid_on),
  ),
  MainWidgetModel(
    title: 'RaisedButton组件',
    route: RaisedButtonPage(),
    icon: const Icon(Icons.bug_report),
  ),
  MainWidgetModel(
    title: 'FlexibleSpaceBar组件(折叠)',
    route: FlexibleSpaceBarPage(),
    icon: const Icon(Icons.space_bar),
  ),
  MainWidgetModel(
    title: 'Layout抽屉组件',
    route: LayoutDemo(),
    icon: const Icon(Icons.receipt),
  ),
  MainWidgetModel(
    title: '底部导航栏组件',
    route: BottomBar(),
    icon: const Icon(Icons.local_bar),
  ),
  MainWidgetModel(
    title: 'PopupMenu组件',
    route: PopupMenu(),
    icon: const Icon(Icons.more_vert),
  ),
  MainWidgetModel(
    title: 'Form组件',
    route: FormText(),
    icon: const Icon(Icons.format_align_center),
  ),
  MainWidgetModel(
    title: 'Drag_list组件',
    route: DragText(),
    icon: const Icon(Icons.format_align_justify),
  ),
  MainWidgetModel(
    title: 'sort 排序动画',
    route: const SortAnimationPage(),
    icon: const Icon(Icons.sort),
  ),
  MainWidgetModel(
    title: 'Slidable组件',
    route: SlidableText(),
    icon: const Icon(Icons.input),
  ),
  MainWidgetModel(
    title: 'liquid使用',
    route: LiquidText(),
    icon: const Icon(Icons.keyboard),
  ),
  MainWidgetModel(
    title: 'canvas',
    route: PainterSketchDome(),
    icon: const Icon(Icons.keyboard),
  ),
  MainWidgetModel(
    title: 'stepper',
    route: StepperDemo(),
    icon: const Icon(Icons.more_vert),
  ),
  MainWidgetModel(
    title: 'photo',
    route: PickImage(),
    icon: const Icon(Icons.more_vert),
  ),
  MainWidgetModel(
    title: 'curvedBar',
    route: curvedBar(),
    icon: const Icon(Icons.more_vert),
  ),
  MainWidgetModel(
    title: 'banner组件',
    route: bannerDemo(),
    icon: const Icon(Icons.filter_b_and_w),
  ),
  MainWidgetModel(
    title: 'localAuth组件',
    route: LocalAuthCheck(),
    icon: const Icon(Icons.fingerprint),
  ),
  MainWidgetModel(
    title: 'SpeedDial组件',
    route: SpeedDialDemo(),
    icon: const Icon(Icons.list),
  ),
  MainWidgetModel(
    title: 'simple_animations组件',
    route: Hello(),
    icon: const Icon(Icons.airplane_ticket),
  ),
  MainWidgetModel(
    title: '设置',
    route: overlayDemo(),
    icon: const Icon(Icons.settings),
  ),
];

List<MainWidgetModel> page3 = <MainWidgetModel>[
  MainWidgetModel(
    title: '翻译',
    route: translatePage(),
    icon: const Icon(Icons.translate),
  ),
  MainWidgetModel(
    title: '天 气 预 报',
    route: RealTimePage(),
    icon: const Icon(Icons.cloud),
  ),
  MainWidgetModel(
    title: '书架',
    route: BookShelf(),
    icon: const Icon(Icons.book),
  ),
  MainWidgetModel(
    title: '梨视频',
    route: PearVideoFirstPage(),
    icon: const Icon(Icons.video_library),
  ),
  MainWidgetModel(
    title: 'game',
    route: const TankMainPage(),
    icon: const Icon(Icons.gamepad),
  ),
  MainWidgetModel(
    title: 'webview test',
    route: const WebViewTest(),
    icon: const Icon(Icons.web),
  ),
  MainWidgetModel(
    title: 'AutoPlayListPage',
    route: const AutoPlayListPage(),
    icon: const Icon(Icons.video_call),
  ),
  MainWidgetModel(
    title: 'ChooseLangPage',
    route: const ChooseLangPage(),
    icon: const Icon(Icons.video_call),
  ),
];

List<MainWidgetModel> page4 = [
  MainWidgetModel(
    title: '组件能力库',
    route: const ComponentLibraryPage(),
    icon: const Icon(Icons.view_in_ar_outlined),
  ),
  MainWidgetModel(
    title: 'SMB 挂载目录',
    route: const SmbMountPage(),
    icon: const Icon(Icons.lan_outlined),
    category: '桌面与系统能力',
    description: '配置 NAS SMB 地址和本地挂载目录，作为 DropDock 投递收件箱。',
    tags: <String>['SMB', 'NAS', 'DropDock', '局域网'],
  ),
  MainWidgetModel(
    title: '动画常用组件',
    route: AnimaComponentPage(),
    icon: const Icon(Icons.tablet_android),
  ),
  MainWidgetModel(
    title: '书架',
    route: BookShelf(),
    icon: const Icon(Icons.book),
  ),
  MainWidgetModel(
    title: '聊天列表--',
    route: ChatListWidget(),
    icon: const Icon(Icons.chat),
  ),
  MainWidgetModel(
    title: '日历',
    route: const WinCalendarPage(),
    icon: const Icon(Icons.calendar_month),
  ),
  MainWidgetModel(
    title: '本地视频播放--',
    route: VideoIndex(),
    icon: const Icon(Icons.ondemand_video),
  ),
  MainWidgetModel(
    title: '浏览器',
    route: const WebViewTest(),
    icon: const Icon(Icons.web),
  ),
];
