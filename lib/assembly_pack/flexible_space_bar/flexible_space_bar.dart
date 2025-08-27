import 'package:flutter/material.dart';

class FlexibleSpaceBarPage extends StatelessWidget {
  @override
  // AppBar和SliverAppBar都是继承StatefulWidget类，都代表Toolbar，
  // 二者的区别在于AppBar位置固定在应用的最上面；而SliverAppBar是可以随内容滚动的
  // AppBar和SliverAppBar的构造方法类似
  //  this.leading,         左侧标题
  //  this.automaticallyImplyLeading = true,
  //  this.title,               标题
  //  this.actions,          菜单
  //  this.flexibleSpace,        可以展开区域，通常是一个FlexibleSpaceBar
  //  this.bottom,         底部内容区域
  //  this.elevation,            阴影
  //  this.forceElevated = false,
  //  this.backgroundColor,       背景色
  //  this.brightness,   主题明亮
  //  this.iconTheme,  图标主题
  //  this.textTheme,    文字主题
  //  this.primary = true,  是否预留高度
  //  this.centerTitle,     标题是否居中
  //  this.titleSpacing = NavigationToolbar.kMiddleSpacing,
  //  this.expandedHeight,     展开高度
  //  this.floating = false,       是否随着滑动隐藏标题
  //  this.pinned = false,  是否固定在顶部
  //  this.snap = false,   与floating结合使用

  /*
      fit: 属性内容
          BoxFit.fill  //全部显示，显示可能拉伸，充满
          BoxFit.contain    //全部显示，显示原比例，不需充满
          BoxFit.cover    //显示可能拉伸，可能裁剪，充满
          BoxFit.fitWidth    //显示可能拉伸，可能裁剪，宽度充满
          BoxFit.fitHeight    //显示可能拉伸，可能裁剪，高度充满
          BoxFit.none
          BoxFit.scaleDown   //效果和contain差不多,但是此属性不允许显示超过源图片大小，可小不可大
  */

  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'slider Study',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('flexibleSpaceBar 组件'),
        ),
        body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  expandedHeight: 200.0, //展开高度
                  floating: false, //是否随滑动隐藏标题
                  pinned: true, //是否固定在顶部
                  flexibleSpace: FlexibleSpaceBar(
                    //可折叠的应用栏
                    centerTitle: true,
                    title: Text(
                      '可折叠的组件',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    background: Image.asset(
                      'images/sun.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              ];
            },
            body: Center(
              child: Container(),
            )),
      ),
    );
  }
}
