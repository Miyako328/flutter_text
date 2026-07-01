import 'package:flutter/material.dart';

class DemoPage extends StatefulWidget{
  final Size size;

  const DemoPage(this.size, {Key? key}) : super(key: key);
  
  @override
  State<StatefulWidget> createState() => DemoPageState(size);
}

enum SlideDirection{
  left, right, up, down
}

class DemoPageState extends State<DemoPage> {

  final Size size;
  final double miniPageWidth;
  final double quarter;

  List<String> titles = [
    '最新','涨幅','涨跌','涨速','大单净量','总手','换手','量比'
  ];

  final double blockHeight = 40;


  //滑动方向
  late SlideDirection slideDirection;

  //底层横向滚动
  late ScrollController rightController;
  //ScrollController stockRowController;
  //控制左侧股票名称和右侧详情
  late ScrollController stockVerticalController;
  late ScrollController stockNameController;
  //tag
  late ScrollController tagController;
  //图标页
  ScrollController? chartController;
  //横向股票详情
  //ScrollController detailHorController;


  DemoPageState(this.size)
      : miniPageWidth = size.width/4*3,
        quarter = size.width/4;



  @override
  void initState() {

    rightController = ScrollController(
        initialScrollOffset: quarter*3
    );
    //stockRowController = ScrollController();
    stockVerticalController = ScrollController();
    stockNameController = ScrollController();
    chartController = ScrollController();
    tagController = ScrollController();
    //detailHorController = ScrollController();

    super.initState();
  }

  late Offset lastPos;

  void handleStart(DragStartDetails details){
    lastPos = details.globalPosition;

  }

  bool rightAnimated = false;
  bool chartShow = false;

  void handleEnd(DragEndDetails details){

    if(slideDirection == SlideDirection.left || slideDirection == SlideDirection.right){
      if(!rightAnimated &&rightController.offset != 0 && rightController.offset < quarter *3){
        if((quarter*3 - rightController.offset) > quarter/2 && details.velocity.pixelsPerSecond.dx > 500){
          rightAnimated = true;
          rightController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.ease)
              .then((value){
            rightAnimated = false;
            setState(() {
              chartShow = true;
            });
          });
        }else{
          rightAnimated = true;
          rightController.animateTo(quarter*3, duration: Duration(milliseconds: 50), curve: Curves.ease)
              .then((value){
            rightAnimated = false;
            setState(() {
              chartShow = false;
            });
          });
        }
      }
    }
  }

  void handleUpdate(DragUpdateDetails details){

    if((details.globalPosition.dx - lastPos.dx).abs() > (details.globalPosition.dy - lastPos.dy).abs()){
      ///横向滑动
      if(details.globalPosition.dx > lastPos.dx){
        //向右
        slideDirection = SlideDirection.right;
      }else{
        //向左
        slideDirection = SlideDirection.left;
      }

    }else{
      ///纵向
      if(details.globalPosition.dy > lastPos.dy){
        //向下
        slideDirection = SlideDirection.down;
      }else{
        //向上
        slideDirection = SlideDirection.up;
      }
    }
    double disV = (details.globalPosition.dy - lastPos.dy).abs();
    double disH = (details.globalPosition.dx - lastPos.dx).abs();

    switch(slideDirection){
      case SlideDirection.left:
        if(rightController.offset < rightController.position.maxScrollExtent){
          rightController.jumpTo(rightController.offset + disH);
          if(!chartShow){
            tagController.jumpTo(tagController.offset + disH);
          }
        }
        break;
      case SlideDirection.right:
        if(rightController.offset > quarter*3){
          if((rightController.offset - disH) < quarter*3){
            rightController.jumpTo(quarter*3);
          }else{
            rightController.jumpTo(rightController.offset - disH);
            if(!chartShow){
              tagController.jumpTo(tagController.offset - disH);
            }
          }

        }else if(rightController.offset != 0 && rightController.offset <= quarter*3){
          rightController.jumpTo(rightController.offset - disH/3);
        }


        break;
      case SlideDirection.up:

        if(stockVerticalController.offset < stockVerticalController.position.maxScrollExtent){
          stockVerticalController.jumpTo(stockVerticalController.offset+disV);
          stockNameController.jumpTo(stockNameController.offset+disV);
          chartController?.jumpTo(stockNameController.offset+disV);
        }

        break;
      case SlideDirection.down:
        if(stockVerticalController.offset > stockVerticalController.position.minScrollExtent){
          stockVerticalController.jumpTo(stockVerticalController.offset-disV);
          stockNameController.jumpTo(stockNameController.offset-disV);
          chartController?.jumpTo(stockNameController.offset-disV);
        }
        break;
    }
    lastPos = details.globalPosition;
  }


  @override
  Widget build(BuildContext context) {
    //debugPrint('${MediaQuery.of(context).size}');
    return Material(
      child: GestureDetector(
        onPanStart: handleStart,
        onPanEnd: handleEnd,
        onPanUpdate: handleUpdate,
        child: Container(
          padding: MediaQuery.of(context).padding,
          color: Colors.white,
          width: size.width,
          height: 200,
          child: Stack(
            children: <Widget>[
              ///bottom part
              buildBottomPart(size),
              ///left top
              Container(
                color: Colors.white,
                alignment: Alignment.center,
                width: quarter,height: blockHeight,
                child: Text('编辑',style: TextStyle(color: Colors.black),),
              ),
              ///right top detail tag
              Positioned(
                left: quarter,
                child: buildTags(),
              ),
              ///left stock name
              buildStockName(size),


            ],
          ),
        ),
      ),
    );
  }

  Widget buildTags(){
    return Container(
      width: quarter*3, height: blockHeight,
      child: chartShow ?
      Row(
        children: <Widget>[
          Container(width: quarter*2,height: blockHeight,alignment: Alignment.center,
            child: Text('分时图'),),
          Container(width: quarter*1,height: blockHeight,alignment: Alignment.center,
            child: Text('涨幅'),),
        ],
      )
          : ListView(
        controller: tagController,
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: List.generate(titles.length, (index){
          return Container(
            color: Colors.white,
            width: quarter,height: blockHeight,
            alignment: Alignment.center,
            child: Text('${titles[index]}'),
          );
        }),
      ),
    );
  }

  Widget buildBottomPart(Size size){
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: rightController,
      physics: NeverScrollableScrollPhysics(),
      child: Container(
        margin: EdgeInsets.only(top: blockHeight),
        padding: EdgeInsets.only(left: quarter),
        width: quarter*4+titles.length*quarter,height: size.height,
        child: Row(
          children: <Widget>[
            ///left
            Container(
              width: miniPageWidth,height: size.height,
              color: Colors.red,
              child: buildLeftDetail(),
            ),
            ///right
            Container(
              width: titles.length*quarter,height: size.height,
              color: Colors.blue,
              child: buildStockDetail(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLeftDetail(){
    return ListView.builder(
      controller: chartController,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(0),
      itemCount: 50,
      itemBuilder: (ctx,index){
        return Container(
          width: quarter * 3,height: blockHeight,
          child: Row(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                color: Colors.lightBlueAccent,
                width: quarter,height: blockHeight,
                child: Text('分时图'),
              )
            ],
          ),
        );
      },
    );
  }

  Widget buildStockDetail(){
    return ListView.builder(
      controller: stockVerticalController,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(0),
      itemCount: 50,
      itemBuilder: (ctx,index){
        return Container(
          width: quarter * titles.length,height: blockHeight,
          child: stockDetail(index),
        );
      },
    );
  }

  Widget stockDetail(int index){
    return ListView(
      //controller: detailHorController,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.all(0),
      scrollDirection: Axis.horizontal,
      children: List.generate(titles.length, (index){
        return Container(
          color: index % 2 == 0 ? Colors.yellow : Colors.purple,
          width:quarter,height: blockHeight,
          alignment: Alignment.center,
          child: Text('$index.2%'),);
      }),
    );
  }

  Widget buildStockName(Size size){
    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(top: blockHeight),
      width: quarter,height: size.height - blockHeight,
      child: ListView.builder(
          controller: stockNameController,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(0),
          itemCount: 50,
          itemBuilder: (ctx,index){
            return Container(
              width:quarter,height: blockHeight,
              alignment: Alignment.center,
              child: Text('No.600$index'),);
          }),
    );
  }


  void logInfo(String title,String info){
    debugPrint('$title ------ $info');
  }

}