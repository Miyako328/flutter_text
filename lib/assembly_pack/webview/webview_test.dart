import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_cef/webview_cef.dart' as cef;

import '../../init.dart';
import 'method.dart';

const String _defaultBrowserUrl = 'http://192.168.1.108:9010/';

class WebViewTest extends StatefulWidget {
  const WebViewTest({Key? key}) : super(key: key);

  @override
  State<WebViewTest> createState() => _WebViewTestState();
}

class _WebViewTestState extends State<WebViewTest> {
  final _controller = cef.WebViewController();
  final _textController = TextEditingController();
  String title = '';

  List<WebModel> webs = [];
  List<PopupMenuItem<WebModel>> popMenu = [];

  @override
  void initState() {
    super.initState();
    if (!GlobalStore.isMobile) {
      // WebViewUtils();
      init();
      _getWebs();
    }
  }

  void _getWebs() {
    webs = WebCollect.getAllWebs();
    popMenu = webs
        .map(
          (WebModel e) => PopupMenuItem<WebModel>(
            onTap: () {
              _textController.text = e.url!;
              _controller.loadUrl(e.url!);
            },
            child: Text('${e.title}'),
          ),
        )
        .toList();
    setState(() {});
  }

  void init() async {
    const String url = _defaultBrowserUrl;
    _textController.text = url;
    await _controller.initialize();
    await _controller.loadUrl(url);
    _controller.setWebviewListener(cef.WebviewEventsListener(
      onTitleChanged: (t) {
        setState(() {
          title = t;
        });
      },
      onUrlChanged: (url) {
        _textController.text = url;
      },
    ));
    _controller.addListener(() {
      _controller.ready;
      Log.info('message');
    });
    if (!mounted) return;
    setState(() {});
  }

  void _loadUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      _textController.text = url;
      _controller.loadUrl(url);
    } else if (url.startsWith('www.')) {
      final String nextUrl = 'https://$url';
      _textController.text = nextUrl;
      _controller.loadUrl(nextUrl);
    } else {
      _textController.text = url;
      _controller.loadUrl('https://www.baidu.com/s?wd=$url');
    }
  }

  @override
  void dispose() {
    if (!GlobalStore.isMobile) {
      _controller.removeListener(() {});
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalStore.isMobile
          ? AppBar(
              title: const Text('webview'),
            )
          : null,
      body: GlobalStore.isMobile
          ? const WebView(
              initialUrl: _defaultBrowserUrl,
              javascriptMode: JavascriptMode.unrestricted,
            )
          : ColoredBox(
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                children: <Widget>[
                  _BrowserToolbar(
                    textController: _textController,
                    isCollected: webs.any(
                      (WebModel element) => element.url == _textController.text,
                    ),
                    favorites: popMenu,
                    onReload: _controller.reload,
                    onBack: _controller.goBack,
                    onForward: _controller.goForward,
                    onDevTools: _controller.openDevTools,
                    onSubmit: _loadUrl,
                    onCollect: () {
                      WebCollect.setWebs(WebModel()
                        ..url = _textController.text
                        ..title = title);
                      _getWebs();
                    },
                  ),
                  _controller.value
                      ? Expanded(
                          child: cef.WebView(_controller),
                        )
                      : const Expanded(
                          child: Center(
                            child: Text('浏览器初始化中'),
                          ),
                        ),
                ],
              ),
            ),
    );
  }
}

class _BrowserToolbar extends StatelessWidget {
  final TextEditingController textController;
  final bool isCollected;
  final List<PopupMenuItem<WebModel>> favorites;
  final VoidCallback onReload;
  final VoidCallback onBack;
  final VoidCallback onForward;
  final VoidCallback onDevTools;
  final ValueChanged<String> onSubmit;
  final VoidCallback onCollect;

  const _BrowserToolbar({
    required this.textController,
    required this.isCollected,
    required this.favorites,
    required this.onReload,
    required this.onBack,
    required this.onForward,
    required this.onDevTools,
    required this.onSubmit,
    required this.onCollect,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(86, 8, 12, 8),
        child: Row(
          children: <Widget>[
            _ToolbarIconButton(
              tooltip: '刷新',
              icon: Icons.refresh_rounded,
              onPressed: onReload,
            ),
            _ToolbarIconButton(
              tooltip: '后退',
              icon: Icons.arrow_back_rounded,
              onPressed: onBack,
            ),
            _ToolbarIconButton(
              tooltip: '前进',
              icon: Icons.arrow_forward_rounded,
              onPressed: onForward,
            ),
            _ToolbarIconButton(
              tooltip: '开发者工具',
              icon: Icons.developer_mode_rounded,
              onPressed: onDevTools,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 36,
                child: TextField(
                  controller: textController,
                  onSubmitted: onSubmit,
                  textInputAction: TextInputAction.go,
                  decoration: InputDecoration(
                    isDense: true,
                    prefixIcon: const Icon(Icons.language_rounded, size: 18),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(999),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _ToolbarIconButton(
              tooltip: isCollected ? '已收藏' : '收藏',
              icon:
                  isCollected ? Icons.star_rounded : Icons.star_border_rounded,
              onPressed: onCollect,
            ),
            PopupMenuButton<WebModel>(
              tooltip: '收藏夹',
              offset: const Offset(0, 38),
              itemBuilder: (BuildContext context) => favorites,
              child: const SizedBox(
                width: 36,
                height: 36,
                child: Icon(Icons.collections_bookmark_rounded, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolbarIconButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  const _ToolbarIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 36,
        height: 36,
        child: IconButton(
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          onPressed: onPressed,
          icon: Icon(icon, size: 20),
        ),
      ),
    );
  }
}
