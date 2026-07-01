import 'package:flutter/material.dart';

enum ViewState { Done, Busy }

class BaseModel extends ChangeNotifier {
  bool disposed = false;

  ViewState _state = ViewState.Done;

  ViewState get state => _state;

  void setState(ViewState viewState) {
    _state = viewState;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    disposed = true;
  }

  @override
  void notifyListeners() {
    if (!disposed) {
      super.notifyListeners();
    }
  }
}
