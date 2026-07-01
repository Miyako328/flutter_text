import 'package:flutter/services.dart';
import 'package:flutter_text/init.dart';
import 'package:flutter_text/model/img_model.dart';
import 'package:self_utils/widget/image_widget.dart';

/// /// 显示状态栏
//   void _statusBarShow() {
//     SystemChrome.setEnabledSystemUIMode(
//       SystemUiMode.manual,
//       overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom] /// 显示状态栏，显示 android 底部导航栏
//     );
//     setState((){});
//   }
//
//   /// 隐藏状态栏
//   void _statusBarHide() {
//     SystemChrome.setEnabledSystemUIMode(
//       SystemUiMode.manual,
//       overlays: [SystemUiOverlay.bottom]                      /// 隐藏状态栏，显示 android 底部导航栏
//     );
//     setState((){});
//   }
///

class WidgetBanner extends StatefulWidget {
  final List<ImageModel> _images;
  final double height;
  final ValueChanged<int>? onTap;
  final Curve curve;
  final bool isShowIndicator;

  const WidgetBanner(
    this._images, {
    this.curve = Curves.linear,
    this.height = 250,
    this.onTap,
    this.isShowIndicator = false,
  });

  @override
  _WidgetBannerState createState() => _WidgetBannerState();
}

class _WidgetBannerState extends State<WidgetBanner> {
  late PageController _pageController;
  late int _currentIndex;
  Timer? _timer;

  //初始化
  @override
  void initState() {
    super.initState();
    _currentIndex = widget._images.length * 5;
    _pageController = PageController(initialPage: _currentIndex);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]

        /// 隐藏状态栏，显示 android 底部导航栏
        );
    _initTimer();
  }

  //关闭的时候还原顶部状态栏
  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]

        /// 隐藏状态栏，显示 android 底部导航栏
        );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        _buildPageView(),
        _buildIndicator(),
      ],
    );
  }

  Widget _buildIndicator() {
    final int length = widget._images.length;
    return Positioned(
      bottom: 10,
      child: Row(
        children: widget._images.map((ImageModel s) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3.0),
            child: ClipOval(
              child: Container(
                width: 8,
                height: 8,
                color: s == widget._images[_currentIndex % length]
                    ? Colors.white
                    : Colors.grey,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPageView() {
    final int length = widget._images.length;
    return Container(
      height: widget.height,
      child: PageView.builder(
          controller: _pageController,
          onPageChanged: (int index) {
            setState(() {
              _currentIndex = index;
              if (index == 0) {
                _currentIndex = length;
                _changePage();
              }
            });
          },
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onPanDown: (DragDownDetails details) {},
              onTap: () {
                //外部url跳转
                if (widget._images[index % length].overBrowerUrl != '') {
                  _overBrowserUrl(widget._images[index % length].overBrowerUrl);
                }
              },
              child: Container(
                padding: const EdgeInsets.only(left: 30, right: 30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: widget._images[index % length].image != null
                    ? CustomNetWorkImage(
                        widget._images[index % length].image ?? '',
                        fit: BoxFit.fitHeight,
                      )
                    : Image.asset(
                        widget._images[index % length].fileImage ?? '',
                        fit: BoxFit.scaleDown,
                      ),
              ),
            );
          }),
    );
  }

  //初始化定时任务
  void _initTimer() {
    _timer ??= Timer.periodic(const Duration(seconds: 5), (Timer t) {
      _currentIndex++;
      _pageController.animateToPage(_currentIndex,
          duration: const Duration(milliseconds: 500), curve: Curves.linear);
    });
  }

  //切换banner页
  void _changePage() {
    Timer(const Duration(milliseconds: 500), () {
      _pageController.jumpToPage(_currentIndex);
    });
  }

  //底部提示框
  void _onTapImage(int index, int length) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('当前page为${index % length}'),
      duration: const Duration(milliseconds: 500),
    ));
  }

  //跳转外部浏览器url
  void _overBrowserUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  //跳转内部页面
  void _insideUrl(String url) {}
}
