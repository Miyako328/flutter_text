
import 'package:flutter/material.dart';

class LayoutDemo extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Drawer抽屉组件示例'),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 10, right: 10, left: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: Text('属性', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                  ),
                  Container(
                    child: Text('说明', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10, right: 10, left: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: Text('Drawer', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10, right: 10, left: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: Text('elevation', style: TextStyle(fontSize: 20),),
                  ),
                  Container(
                    child: Text('背景高度', style: TextStyle(fontSize: 20),),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10, right: 10, left: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: Text('child', style: TextStyle(fontSize: 20),),
                  ),
                  Container(
                    child: Text('子组件', style: TextStyle(fontSize: 20),),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10, right: 10, left: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: Text('semanticlabel', style: TextStyle(fontSize: 20),),
                  ),
                  Container(
                    child: Text('标签', style: TextStyle(fontSize: 20),),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 20, right: 10, left: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: Text('UserAccountDrawerHeader', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10, right: 10, left: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: Text('decoration', style: TextStyle(fontSize: 20),),
                  ),
                  Container(
                    child: Text('头部装饰', style: TextStyle(fontSize: 20),),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10, right: 10, left: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: Text('margin', style: TextStyle(fontSize: 20),),
                  ),
                  Container(
                    child: Text('外边距', style: TextStyle(fontSize: 20),),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10, right: 10, left: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: Text('currentAccountPicture', style: TextStyle(fontSize: 20),),
                  ),
                  Container(
                    child: Text('主图像', style: TextStyle(fontSize: 20),),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10, right: 10, left: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: Text('otherAccountPictures', style: TextStyle(fontSize: 20),),
                  ),
                  Container(
                    child: Text('副图像', style: TextStyle(fontSize: 20),),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10, right: 10, left: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: Text('accountName', style: TextStyle(fontSize: 20),),
                  ),
                  Container(
                    child: Text('标题', style: TextStyle(fontSize: 20),),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10, right: 10, left: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: Text('accountEmail', style: TextStyle(fontSize: 20),),
                  ),
                  Container(
                    child: Text('副标题', style: TextStyle(fontSize: 20),),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10, right: 10, left: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: Text('onDetailsPressed', style: TextStyle(fontSize: 20),),
                  ),
                  Container(
                    child: Text('点击监听', style: TextStyle(fontSize: 20),),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            //设置用户信息 头像、用户名、Email等
            UserAccountsDrawerHeader(
              accountName: new Text(
                "玄微子",
              ),
              accountEmail: new Text(
                "xuanweizi@163.com",
              ),
              //设置当前用户头像
              currentAccountPicture: new CircleAvatar(
                backgroundImage: new AssetImage("images/1.jpeg"),
              ),
              onDetailsPressed: () {},
              //属性本来是用来设置当前用户的其他账号的头像 这里用来当QQ二维码图片展示
              otherAccountsPictures: [
                new Container(
                  child: Image.asset('images/code.jpeg'),
                ),
              ],
            ),
            ListTile(
              leading: new CircleAvatar(child: Icon(Icons.color_lens)),//导航栏菜单
              title: Text('个性装扮'),
            ),
            ListTile(
              leading: new CircleAvatar(child: Icon(Icons.photo)),
              title: Text('我的相册'),
            ),
            ListTile(
              leading: new CircleAvatar(child: Icon(Icons.wifi)),
              title: Text('免流量特权'),
            ),
          ],
        ),
      ),
    );

  }
}