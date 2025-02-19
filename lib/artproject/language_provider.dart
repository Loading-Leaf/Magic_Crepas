import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  bool _isHiragana = false; // デフォルトはひらがな

  bool get isHiragana => _isHiragana; // ひらがなか漢字かを取得

  LanguageProvider() {
    _loadLanguage(); // 初期化時に設定を読み込む
    notifyListeners();
  }

  // 言語を変更する
  void setLanguage(bool isHiragana) async {
    _isHiragana = isHiragana;
    notifyListeners(); // UI を更新
    _saveLanguage(isHiragana); // 設定を保存
  }

  // 設定を保存
  Future<void> _saveLanguage(bool isHiragana) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isHiragana', isHiragana);
  }

  // 設定を読み込む
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _isHiragana = prefs.getBool('isHiragana') ?? true; // デフォルトはひらがな
    notifyListeners();
  }
}
