import 'package:flutter/material.dart';
import 'package:self_utils/utils/screen.dart';

class TextInputLock extends StatefulWidget {
  final FormFieldSetter<String> onSave;

  TextInputLock({required this.onSave});

  @override
  _TextInputLockState createState() => _TextInputLockState();
}

class _TextInputLockState extends State<TextInputLock> {
  bool onLock = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(
                maxHeight: 25,
                maxWidth: 200
            ),
            child: TextFormField(
              decoration: const InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
                border: InputBorder.none,
              ),
              readOnly: onLock,
              onSaved: widget.onSave,
            ),
          ),
          Positioned(top: 0, right: 0,child: Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(right: screenUtil.adaptive(5)),
            child: InkWell(
              onTap: () {
                onLock = !onLock;
                setState(() {});
              },
              child: Icon(
                onLock ? Icons.lock : Icons.lock_open,
                color: const Color(0xBF000000),
                size: 15,
              ),
            ),
          )),
        ],
      ),
    );
  }
}
