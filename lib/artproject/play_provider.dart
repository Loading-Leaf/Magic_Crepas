import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayProvider with ChangeNotifier {
  int generateCount = 0;
  int get getGenerateCount => generateCount;
  DateTime lastGenerateDate =
      DateTime.now().toUtc().add(Duration(hours: 9)); // JST

  PlayProvider() {
    _checkAndResetCount();
    //_Play();
  }

  Future<void> _checkAndResetCount() async {
    final prefs = await SharedPreferences.getInstance();
    DateTime nowJST = DateTime.now().toUtc().add(Duration(hours: 9));
    if (lastGenerateDate.day != nowJST.day ||
        lastGenerateDate.month != nowJST.month ||
        lastGenerateDate.year != nowJST.year) {
      generateCount = 0;
      await prefs.setInt('getGenerateCount', generateCount);
      lastGenerateDate = nowJST;
    }
    notifyListeners();
  }

  Future<void> _Play() async {
    final prefs = await SharedPreferences.getInstance();
    generateCount++;
    await prefs.setInt('getGenerateCount', generateCount);
    notifyListeners();
  }
}
