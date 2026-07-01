import 'dart:convert';

import 'package:flutter_text/assembly_pack/management/home_page/theme.dart';
import 'package:intl/intl.dart';
import 'package:flutter_text/assembly_pack/calendar/method.dart';
import 'package:flutter_text/init.dart';
import 'package:self_utils/init.dart';

class AddFormWidget extends StatefulWidget {
  DateTime time;
  void Function() refresh;

  AddFormWidget({Key? key, required this.time, required this.refresh})
      : super(key: key);

  @override
  State<AddFormWidget> createState() => _AddFormWidgetState();
}

class _AddFormWidgetState extends State<AddFormWidget> {
  GlobalKey<FormState> key = GlobalKey<FormState>();
  StreamSubscription<void>? _themeSubscription;
  bool isAdd = false;
  double _height = 50;

  String title = '';
  String desc = '';

  @override
  void initState() {
    _listenTheme();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AddFormWidget oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (widget.time != oldWidget.time) {
      _refresh();
    }
  }

  void _listenTheme() {
    _themeSubscription?.cancel();
    _themeSubscription = EventBusHelper.listen<EventBusM>((EventBusM event) {
      if (event.theme != '') {
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    _themeSubscription?.cancel();
    super.dispose();
  }

  void _onSave() {
    final FormState? form = key.currentState;
    if (form != null && form.validate()) {
      form.save();
      try {
        final Event event = Event(
          Utils.getStampId(),
          title,
          DateFormat('yyyy-MM-dd').format(widget.time),
          desc,
          EventType.normal.enumToString,
        );
        EventHelper.setEvents(event);
        widget.refresh.call();
        _refresh();
        Log.info(jsonEncode(event));
      } catch (err) {
        rethrow;
      }
    }
  }

  void _refresh() {
    key = GlobalKey<FormState>();
    isAdd = false;
    _height = 50;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _height,
      child: Container(
        margin: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          border: Border.all(
              color: (GlobalStore.theme == 'light'
                  ? HomeTheme.lightBorderLineColor
                  : HomeTheme.darkBorderLineColor)),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: isAdd
            ? Form(
                key: key,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              hintText: '标题',
                            ),
                            onSaved: (value) {
                              title = value ?? '';
                              setState(() {});
                            },
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _onSave();
                          },
                          child: const Text('添加'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _height = 50;
                            isAdd = !isAdd;
                            setState(() {});
                          },
                          child: const Text('关闭'),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Container(
                        child: TextFormField(
                          maxLines: 6,
                          decoration: const InputDecoration(
                            hintText: '内容',
                          ),
                          onSaved: (value) {
                            desc = value ?? '';
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : ListTile(
                onTap: () {
                  setState(() {
                    if (isAdd) {
                      _height = 50;
                    } else {
                      _height = 200;
                    }
                    isAdd = !isAdd;
                  });
                },
                title: const Text('add'),
              ),
      ),
    );
  }
}
