import 'package:flutter/material.dart';
import 'package:self_utils/utils/screen.dart';
import 'package:self_utils/widget/text_input_lock.dart';

class OtaUpdateWidget extends StatefulWidget {

  @override
  _OtaUpdateState createState() => _OtaUpdateState();
}

class _OtaUpdateState extends State<OtaUpdateWidget> {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text'),
      ),
      body: Container(
        height: 30,
        width: 200,
        alignment: Alignment.topCenter,
        decoration: BoxDecoration(
          border: Border.all(
            color: Color(0xE6797979),
            width: 1.0,
          ),
        ),
        child: TextFormField(
          maxLines: 1,keyboardType: TextInputType.multiline,
          onSaved: (String? value) {

          },
        ),
      ),
    );
  }
}