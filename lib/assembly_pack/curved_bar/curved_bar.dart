import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class curvedBar extends StatelessWidget {
  Widget build(BuildContext context) {
    return curvedBarDemo();
  }
}

class curvedBarDemo extends StatefulWidget {
  @override
  curvedBarDemoState createState() => curvedBarDemoState();
}

//页面必须继承StatefulWidget
//页面必须实现SingleTickerProviderStateMixin
//页面初始化时，实例化TabController
//在TabBar组件中指定controller为我们实例化的TabController
//在TabBarView组件中指定controller为我们实例化的TabController
class curvedBarDemoState extends State<curvedBarDemo> with SingleTickerProviderStateMixin {
  late TabController tabController;
  List colors = [Colors.blue, Colors.pink, Colors.orange];
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this)
      ..addListener(() {
        setState(() {
          currentIndex = tabController.index;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),        //禁止滑动
        controller: tabController,
        children: <Widget>[
          Container(
            color: colors[0],
          ),
          Container(
            color: colors[1],
          ),
          Container(
            color: colors[2],
          )
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: colors[currentIndex],
        items: <Widget>[
          Icon(Icons.add, size: 30,),
          Icon(Icons.list, size: 30,),
          Icon(Icons.compare_arrows, size: 30,),
        ],
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
          tabController.animateTo(index, duration: Duration(milliseconds: 300), curve: Curves.ease);
        },
      ),
    );
  }
}
