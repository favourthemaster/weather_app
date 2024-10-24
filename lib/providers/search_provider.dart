import 'package:flutter/material.dart';

class SearchProvider extends ChangeNotifier {
  String search = "";

  void setSearch(String s) {
    search = s;
    notifyListeners();
  }
}
