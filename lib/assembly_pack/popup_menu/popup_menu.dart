import 'package:flutter/material.dart';

enum ConferenceItem { AddMember, LockConference, ModifyLayout, TurnoffAll }

class PopupMenu extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PopupMenu弹出组件'),
        actions: <Widget>[
            PopupMenuButton(
              child: Center(
                child: Text('倍速'),
              ),
              offset: Offset(10, 10),
              itemBuilder: (BuildContext context) => [ //菜单项构造器
                const PopupMenuItem(//菜单项
                  value: ConferenceItem.AddMember,
                  child: Text('添加成员'),
                ),
                const PopupMenuItem(
                  value: ConferenceItem.LockConference,
                  child: Text('锁定会议'),
                ),
                const PopupMenuItem(
                  value: ConferenceItem.ModifyLayout,
                  child: Text('修改布局'),
                ),
                const PopupMenuItem(
                  value: ConferenceItem.TurnoffAll,
                  child: Text('挂断所有'),
                ),
              ],
            ),
        ],
      ),
      body: Container(

      ),
    );
  }
}