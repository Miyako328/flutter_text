import 'package:flutter/material.dart';

import 'base_model.dart';

class TextModel extends BaseModel {
  int _count = 0;

  int get count => _count;

  void addCount() {
    _count++;
    notifyListeners();
  }
}


class UserModel extends BaseModel {

}