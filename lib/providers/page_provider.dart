import 'package:flutter/material.dart';

class PageProvider extends ChangeNotifier {
  int _page = 0;
  void setPage(int index) {
    _page = index;
    notifyListeners();
  }

  int get page => _page;
}
