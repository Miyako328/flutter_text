import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Model {
  int? id;
  String? img;
  String? title;
  int? price;
  String? protuct_img;
  String? show;
  String? peisong;
  bool? is_collection;

}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'Flutter Study',
      home: TabBarDemo(),
    );
  }
}

class TabBarDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const TabBar(
            tabs: [
              Tab(text: '美食'),
              Tab(text: '美食'),
              Tab(text: '美食'),
              Tab(text: '美食'),
            ],
          ),
        ),

        body: TabBarView(
          children: [
            RandomWords(),
            const Icon(Icons.directions_transit),
            const Icon(Icons.directions_bike),
            const Icon(Icons.directions_bike),
          ],
        ),
      ),
    );
  }
}

class RandomWords extends StatefulWidget {
  @override
  RandomWordsState createState() => RandomWordsState();
}

//list区
class RandomWordsState extends State<RandomWords> {
  @override
  late List<Model> _shopList;
  int _page = 1;
  bool isLoading = false; //是否正在加载数据
  ScrollController _scrollController =  ScrollController();

  //初始化数据
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels  ==
          _scrollController.position.maxScrollExtent) {
        print('滑动到了最底部');
        _getMore();
      }
    });
    _shopList = [
      Model()
        ..id = 1
        ..title = '牛油果'
        ..price = 45
        ..img = 'images/timg.jpg'
        ..peisong = '100'
        ..protuct_img = 'images/timg.jpg'
        ..show = '精选日本仙台和牛，烧制三分熟切片，淋秘制酱汁，配以新泻县鱼诏产越光米，鲜香嫩滑回味留甘，限量供应'
        ..is_collection = false,

      Model()
        ..id = 2
        ..title = '百香果'
        ..price = 10
        ..img = 'images/timg2.jpg'
        ..peisong = '100'
        ..protuct_img = 'images/timg2.jpg'
        ..show = '精选日本仙台和牛，烧制三分熟切片，淋秘制酱汁，配以新泻县鱼诏产越光米，鲜香嫩滑回味留甘，限量供应'
        ..is_collection = false,

      Model()
        ..id = 3
        ..title = '花生'
        ..price = 100
        ..img = 'images/timg3.jpg'
        ..peisong = '100'
        ..protuct_img = 'images/timg3.jpg'
        ..show = '精选日本仙台和牛，烧制三分熟切片，淋秘制酱汁，配以新泻县鱼诏产越光米，鲜香嫩滑回味留甘，限量供应'
        ..is_collection = false,

      Model()
        ..id = 4
        ..title = '牛油果'
        ..price = 50
        ..img = 'images/timg.jpg'
        ..peisong = '100'
        ..protuct_img = 'images/timg.jpg'
        ..show = '精选日本仙台和牛，烧制三分熟切片，淋秘制酱汁，配以新泻县鱼诏产越光米，鲜香嫩滑回味留甘，限量供应'
        ..is_collection = false,

      Model()
        ..id = 5
        ..title = '牛油果'
        ..price = 411
        ..img = 'images/timg2.jpg'
        ..peisong = '100'
        ..protuct_img = 'images/timg2.jpg'
        ..show = '精选日本仙台和牛，烧制三分熟切片，淋秘制酱汁，配以新泻县鱼诏产越光米，鲜香嫩滑回味留甘，限量供应'
        ..is_collection = true,

      Model()
        ..id = 6
        ..title = '牛油果'
        ..price = 600
        ..img = 'images/timg.jpg'
        ..peisong = '100'
        ..protuct_img = 'images/timg.jpg'
        ..show = '精选日本仙台和牛，烧制三分熟切片，淋秘制酱汁，配以新泻县鱼诏产越光米，鲜香嫩滑回味留甘，限量供应'
        ..is_collection = false,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector (
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        child: _buildSuggestions(),
      ),
    );
  }

  Widget _buildSuggestions() {
    return ListView.builder(
      itemCount: _shopList.length,
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, i) {
        return pageWidget(i);
      },
    );
  }

  Future<Null> _onRefresh() async {
    await Future<void>.delayed(const Duration(seconds: 3), () {
      print('refresh');
      setState(() {
        _shopList = [
          Model()
            ..id = 1
            ..title = '牛油果'
            ..price = 45
            ..img = 'images/timg.jpg'
            ..peisong = '100'
            ..protuct_img = 'images/timg.jpg'
            ..show = '精选日本仙台和牛，烧制三分熟切片，淋秘制酱汁，配以新泻县鱼诏产越光米，鲜香嫩滑回味留甘，限量供应'
            ..is_collection = false,

          Model()
            ..id = 2
            ..title = '百香果'
            ..price = 10
            ..img = 'images/timg2.jpg'
            ..peisong = '100'
            ..protuct_img = 'images/timg2.jpg'
            ..show = '精选日本仙台和牛，烧制三分熟切片，淋秘制酱汁，配以新泻县鱼诏产越光米，鲜香嫩滑回味留甘，限量供应'
            ..is_collection = false,

          Model()
            ..id = 3
            ..title = '花生'
            ..price = 100
            ..img = 'images/timg3.jpg'
            ..peisong = '100'
            ..protuct_img = 'images/timg3.jpg'
            ..show = '精选日本仙台和牛，烧制三分熟切片，淋秘制酱汁，配以新泻县鱼诏产越光米，鲜香嫩滑回味留甘，限量供应'
            ..is_collection = false,

          Model()
            ..id = 4
            ..title = '牛油果'
            ..price = 50
            ..img = 'images/timg.jpg'
            ..peisong = '100'
            ..protuct_img = 'images/timg.jpg'
            ..show = '精选日本仙台和牛，烧制三分熟切片，淋秘制酱汁，配以新泻县鱼诏产越光米，鲜香嫩滑回味留甘，限量供应'
            ..is_collection = false,

          Model()
            ..id = 5
            ..title = '牛油果'
            ..price = 411
            ..img = 'images/timg2.jpg'
            ..peisong = '100'
            ..protuct_img = 'images/timg2.jpg'
            ..show = '精选日本仙台和牛，烧制三分熟切片，淋秘制酱汁，配以新泻县鱼诏产越光米，鲜香嫩滑回味留甘，限量供应'
            ..is_collection = true,

          Model()
            ..id = 6
            ..title = '牛油果'
            ..price = 600
            ..img = 'images/timg.jpg'
            ..peisong = '100'
            ..protuct_img = 'images/timg.jpg'
            ..show = '精选日本仙台和牛，烧制三分熟切片，淋秘制酱汁，配以新泻县鱼诏产越光米，鲜香嫩滑回味留甘，限量供应'
            ..is_collection = false,
        ];
      });
    });
  }

  //模板
  Widget pageWidget(i) {
    return Column(
        children: <Widget>[
          Row(
              children: <Widget>[
                Container(
                  child:  Image(
                    image: AssetImage('${_shopList[i].img}'),
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                  width: 150,
                  height: 150,
                  padding:  EdgeInsets.only(top: 10, bottom: 10),
                  margin:  EdgeInsets.only(right: 10, left: 10),
                ),
                Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(right: 10),
                            child:  Text(
                              '${_shopList[i].title}',
                              style: TextStyle(
                                  fontSize: 18
                              ),
                            ),
                          ),
                          Text('￥${_shopList[i].price}'),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 5),
                            child:  const Text('当日午餐',
                              style: TextStyle(
                                  color: Color.fromARGB(100, 0, 0, 128)
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 5),
                            child: const Text('当日晚餐',
                                style: TextStyle(
                                    color: Color.fromRGBO(96, 96, 96, 0.5)
                                )
                            ),
                          ),
                          Container(
                            padding:const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 5),
                            child: const Text('当日夜宵',
                                style: TextStyle(
                                    color: Color.fromRGBO(96, 96, 96, 0.5)
                                )
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.only(bottom: 10),
                        child: GestureDetector(
                          child: Text(
                              '${_shopList[i].is_collection}' == 'false' ? '收藏': '已收藏'
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                 MaterialPageRoute(
                                    builder: (BuildContext context) =>  SecondScreen(view: _shopList[i])
                                )
                            ).then((onValue) {
                              setState(() {
                                _shopList.map((item){
                                  if ( item == _shopList[i] )
                                    item.is_collection = onValue == null ? false : onValue;
                                  return item;
                                }).toList();
                              });
                            });
                          },
                        ),
                      ),
                       Row(
                        children: <Widget>[
                           Container(
                            padding:  EdgeInsets.only(right: 20),
                            child:  Text('用礼金兑换', style:  TextStyle(color: Colors.redAccent),),
                          ),
                           Container(
                            child:  Text('送给TA', style:  TextStyle(color: Colors.white),),
                            alignment: Alignment(0, 0),
                            color: Colors.pink,
                            width: 50,
                            height: 25,
                          ),
                        ],
                      ),
                    ]
                )
              ]
          )
        ]
    );
  }

  Future<Null> _getMore() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
      await Future.delayed(Duration(seconds: 2), () {
        print('加载更多');
        setState(() {
          _shopList.addAll(
              [
                Model()
                  ..id = 1
                  ..title = '牛油果'
                  ..price = 45
                  ..img = 'images/timg.jpg'
                  ..peisong = '100'
                  ..protuct_img = 'images/timg.jpg'
                  ..show = '精选日本仙台和牛，烧制三分熟切片，淋秘制酱汁，配以新泻县鱼诏产越光米，鲜香嫩滑回味留甘，限量供应'
                  ..is_collection = false,

                Model()
                  ..id = 2
                  ..title = '百香果'
                  ..price = 10
                  ..img = 'images/timg2.jpg'
                  ..peisong = '100'
                  ..protuct_img = 'images/timg2.jpg'
                  ..show = '精选日本仙台和牛，烧制三分熟切片，淋秘制酱汁，配以新泻县鱼诏产越光米，鲜香嫩滑回味留甘，限量供应'
                  ..is_collection = false,

                Model()
                  ..id = 3
                  ..title = '花生'
                  ..price = 100
                  ..img = 'images/timg3.jpg'
                  ..peisong = '100'
                  ..protuct_img = 'images/timg3.jpg'
                  ..show = '精选日本仙台和牛，烧制三分熟切片，淋秘制酱汁，配以新泻县鱼诏产越光米，鲜香嫩滑回味留甘，限量供应'
                  ..is_collection = false,

                Model()
                  ..id = 4
                  ..title = '牛油果'
                  ..price = 50
                  ..img = 'images/timg.jpg'
                  ..peisong = '100'
                  ..protuct_img = 'images/timg.jpg'
                  ..show = '精选日本仙台和牛，烧制三分熟切片，淋秘制酱汁，配以新泻县鱼诏产越光米，鲜香嫩滑回味留甘，限量供应'
                  ..is_collection = false,

                Model()
                  ..id = 5
                  ..title = '牛油果'
                  ..price = 411
                  ..img = 'images/timg2.jpg'
                  ..peisong = '100'
                  ..protuct_img = 'images/timg2.jpg'
                  ..show = '精选日本仙台和牛，烧制三分熟切片，淋秘制酱汁，配以新泻县鱼诏产越光米，鲜香嫩滑回味留甘，限量供应'
                  ..is_collection = true,

                Model()
                  ..id = 6
                  ..title = '牛油果'
                  ..price = 600
                  ..img = 'images/timg.jpg'
                  ..peisong = '100'
                  ..protuct_img = 'images/timg.jpg'
                  ..show = '精选日本仙台和牛，烧制三分熟切片，淋秘制酱汁，配以新泻县鱼诏产越光米，鲜香嫩滑回味留甘，限量供应'
                  ..is_collection = false,
              ]
          );
          _page++;
          isLoading = false;
        });
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollController.dispose();
  }
}

//第二个页面
class SecondScreen extends StatefulWidget {
  @override
  final Model view; // 用来储存传递过来的值
  SecondScreen({required this.view}); // 本页面的构造器，接收传递过来的参数

  @override
  _SecondContent createState() =>  _SecondContent();

}

//第二个页面内容
class _SecondContent extends State<SecondScreen> {
  bool alreadySaved = false;

  @override
  void initState() {
    super.initState();
    alreadySaved = widget.view.is_collection??false;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.view.title??''),
        backgroundColor: Colors.brown,
      ),
      body:  Center(
        child:  Container(
            padding:  EdgeInsets.all(20.0),
            child:  Column(
              children: <Widget>[
                 Row(
                    children: <Widget>[
                       Container(
                        padding: const EdgeInsets.only(right: 20),
                        child:  Image(
                          image: AssetImage(widget.view.img??''),
                          width: 150,
                          height: 150,
                          fit: BoxFit.contain,
                        ),
                      ),
                       Column(
                          children: <Widget>[
                             Row(
                              children: <Widget>[
                                 Container(
                                  padding:  EdgeInsets.only(right: 15),
                                  child:  Text(
                                    '单价',
                                    style:  TextStyle(
                                        fontSize: 20,
                                        color: Color.fromRGBO(255, 0, 0, 1)
                                    ),
                                  ),
                                ),
                                 Container(
                                  child:  Text(
                                    '￥${widget.view.price}',
                                    style:  TextStyle(
                                        fontSize: 20,
                                        color: Color.fromRGBO(255, 0, 0, 1)
                                    ),),
                                  padding:  EdgeInsets.only(right: 20),
                                ),
                                 GestureDetector(
                                  child:  Container(
                                    child:  Icon(
                                      alreadySaved ? Icons.favorite : Icons.favorite_border,
                                      color: alreadySaved ? Colors.red : null,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      if (alreadySaved) {
                                        alreadySaved = false;
                                      } else {
                                        alreadySaved = true;
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                             Container(
                              child:  Text('配送范围：${widget.view.peisong}米', style:  TextStyle(fontSize: 15),),
                              padding:  EdgeInsets.only(top: 15, bottom: 20),
                            ),
                             Row(
                              children: <Widget>[
                                 Container(
                                  padding:  EdgeInsets.only(bottom: 10, right: 5, left: 5),
                                  child:   Text('当日午餐',
                                    style:  TextStyle(
                                        color: Color.fromARGB(100, 0, 0, 128)
                                    ),
                                  ),
                                ),
                                 Container(
                                  padding:  EdgeInsets.only(bottom: 10, right: 5, left: 5),
                                  child:  Text('当日晚餐',
                                      style:  TextStyle(
                                          color: Color.fromRGBO(96, 96, 96, 0.5)
                                      )
                                  ),
                                ),
                                 Container(
                                  padding:  EdgeInsets.only( bottom: 10, right: 5, left: 5),
                                  child:  Text('当日夜宵',
                                      style:  TextStyle(
                                          color: Color.fromRGBO(96, 96, 96, 0.5)
                                      )
                                  ),
                                ),
                              ],
                            ),
                          ]
                      )
                    ]
                ),
                 Container(
                  padding:  EdgeInsets.only(top: 10, bottom: 10),
                  alignment: Alignment.centerLeft,
                  child:   Text(
                    '美食介绍:',
                    style:  TextStyle(
                      fontSize: 20,
                      color: Color.fromRGBO(0, 0, 255, 1),
                    ),
                  ),
                ),
                 Text(widget.view.show??''),
                 Container(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  alignment: Alignment.centerLeft,
                  child: const  Text(
                      '产品图片:',
                      style:  TextStyle(
                        fontSize: 20,
                        color: Color.fromRGBO(0, 0, 255, 1),
                      ),
                      textAlign: TextAlign.left
                  ),
                ),

                 Row(
                  children: <Widget>[
                     Image(
                      image: AssetImage(widget.view.protuct_img??''),
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                     Image(
                      image: AssetImage(widget.view.protuct_img??''),
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
                 Row(
                  children: <Widget>[
                     Container(
                      padding:  EdgeInsets.only(top: 10, right: 30),
                      child:  ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, alreadySaved);
                        },
                        child:  Text('退出'),
                      ),
                    ),
                     Container(
                      padding:  EdgeInsets.only(top: 10, left: 30),
                      child:  ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, alreadySaved);
                        },
                        child:  Text('查看商家'),
                      ),
                    ),
                  ],
                ),
              ],
            )
        ),
      ),
    );
  }
}


