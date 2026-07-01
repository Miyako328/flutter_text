import 'package:flutter/material.dart';
import '../keyboard_controller.dart';

class SecurityKeyboardText extends StatefulWidget {
  final KeyboardController controller;

  SecurityKeyboardText({required this.controller});

  @override
  _SecurityKeyboardTextState createState() => _SecurityKeyboardTextState();
}

class _SecurityKeyboardTextState extends State<SecurityKeyboardText> {

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
                buildButton('A'),
                buildButton('B'),
                buildButton('C'),
                buildButton('D'),
                buildButton('E'),
                buildButton('F'),
                buildButton('G'),
                buildButton('H'),
                buildButton('I'),
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