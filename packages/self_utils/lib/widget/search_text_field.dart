import 'package:flutter/material.dart';

class SearchTextField extends StatefulWidget {

  @override
  _SearchTextFieldState createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  TextEditingController controller = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          Container(
            child: TextFormField(
              controller: controller,
              onSaved: (String? value) {

              },
            ),
          ),
          Positioned(child: Container()),
        ],
      ),
    );
  }
}