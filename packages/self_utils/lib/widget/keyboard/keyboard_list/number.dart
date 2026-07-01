import 'package:flutter/material.dart';

import '../keyboard_controller.dart';

class SecurityKeyboardNumber extends StatefulWidget {
  final KeyboardController controller;

  SecurityKeyboardNumber({required this.controller});

  @override
  _SecurityKeyboardNumberState createState() => _SecurityKeyboardNumberState();
}

class _SecurityKeyboardNumberState extends State<SecurityKeyboardNumber> {

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
        style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black,
            fontSize: 23.0),
        child: Container(
          height: MediaQuery.of(context).size.height / 3 / 2 * 2,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            color: Color(0xffafafaf),
          ),
          child: GridView.count(
              childAspectRatio: 2 / 1,
              mainAxisSpacing: 0.5,
              crossAxisSpacing: 0.5,
              padding: const EdgeInsets.all(0.0),
              crossAxisCount: 3,
              children: <Widget>[
                buildButton('1'),
                buildButton('2'),
                buildButton('3'),
                buildButton('4'),
                buildButton('5'),
                buildButton('6'),
                buildButton('7'),
                buildButton('8'),
                buildButton('9'),
                Container(
                  color: const Color(0xFFd3d6dd),
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    child: const Center(
                      child: Icon(Icons.expand_more),
                    ),
                    onTap: () {
                      widget.controller.doneAction();
                    },
                  ),
                ),
                buildButton('0'),
                Container(
                  color: const Color(0xFFd3d6dd),
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    child: const Center(
                      child: Text('X'),
                    ),
                    onTap: () {
                      widget.controller.deleteOne();
                    },
                  ),
                ),
              ]),
        ));
  }


  Widget buildButton(String title, {String? value}) {
    return Container(
      color: Colors.white,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        child: Center(
          child: Text(title),
        ),
        onTap: () {
          widget.controller.addText(value ?? title);
        },
      ),
    );
  }
}