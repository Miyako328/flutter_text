import 'package:flutter/material.dart';
import 'package:self_utils/utils/array_helper.dart';

class GroupListModel {
  String? title;
  List<String>? children;
}

class GroupListWidget extends StatefulWidget {
  final List<GroupListModel>? list;

  const GroupListWidget({Key? key, this.list});

  @override
  State<StatefulWidget> createState() {
    return _GroupListState();
  }
}

class _GroupListState extends State<GroupListWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: widget.list?.length ?? 0,
        itemBuilder: (BuildContext context, int index) {
          final GroupListModel? groupListModel =
              ArrayHelper.get(widget.list, index);
          return _LevelOneListWidget(
            item: groupListModel,
          );
        });
  }
}

class _LevelOneListWidget extends StatefulWidget {
  final GroupListModel? item;

  const _LevelOneListWidget({this.item});

  @override
  State<StatefulWidget> createState() {
    return _LevelOneListState();
  }
}

class _LevelOneListState extends State<_LevelOneListWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpand = false;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        lowerBound: 0.0,
        upperBound: 0.25,
        vsync: this,
        duration: const Duration(milliseconds: 400));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 14, right: 14, top: 28, bottom: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              if (_animationController.isCompleted) {
                _isExpand = false;
                _animationController.reverse();
              } else {
                _isExpand = true;
                _animationController.reset();
                _animationController.forward();
              }
              setState(() {});
            },
            child: Row(
              children: [
                Container(
                  child: Text('${widget.item?.title ?? ''}'),
                ),
                RotationTransition(
                  turns: _animationController,
                  child: const Icon(Icons.arrow_right),
                )
              ],
            ),
          ),
          _levelTwoListWidget(),
        ],
      ),
    );
  }

  Widget _levelTwoListWidget() {
    if (_isExpand == false) {
      return Container();
    }
    return ListView.builder(
        shrinkWrap: true,
        itemCount: widget.item?.children?.length ?? 0,
        itemBuilder: (BuildContext context, int index) {
          final String? text = ArrayHelper.get(widget.item?.children, index);
          return Container(
            child: Text('$text'),
          );
        });
  }
}
