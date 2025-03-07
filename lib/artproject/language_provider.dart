import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';

class LanguageProvider with ChangeNotifier {
  bool _isHiragana = true; // デフォルトはひらがな
  int _locallanguage = 1; //1:日本語, 2:英語

  bool get isHiragana => _isHiragana; // ひらがなか漢字かを取得
  int get locallanguage => _locallanguage; //言語を取得

  LanguageProvider() {
    _loadLanguage(); // 初期化時に設定を読み込む
    notifyListeners();
    _loadlocalLanguage();
    _initializeLanguage();
  }

  // 言語の初期化（デバイスの言語を考慮）
  Future<void> _initializeLanguage() async {
    final prefs = await SharedPreferences.getInstance();

    // 初回起動チェック（`locallanguage` が未設定ならデバイス言語を適用）
    if (!prefs.containsKey('locallanguage')) {
      String deviceLanguage = window.locale.languageCode; // デバイスの言語取得
      _locallanguage = (deviceLanguage == 'en') ? 2 : 1; // 英語なら2、日本語なら1
      await prefs.setInt('locallanguage', _locallanguage); // 初回のみ保存
    } else {
      _locallanguage = prefs.getInt('locallanguage') ?? 1; // 既存の設定を適用
    }

    // ひらがな設定もロード
    _isHiragana = prefs.getBool('isHiragana') ?? true; // デフォルトはひらがな

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

  // 言語を変更する
  void setlocalLanguage(int locallanguage) async {
    _locallanguage = locallanguage;
    notifyListeners(); // UI を更新
    _savelocalLanguage(locallanguage); // 設定を保存
  }

  // 設定を保存
  Future<void> _savelocalLanguage(int locallanguage) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('locallanguage', locallanguage);
  }

  // 設定を読み込む
  Future<void> _loadlocalLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _locallanguage = prefs.getInt('locallanguage') ?? 1; // デフォルトは日本語
    notifyListeners();
  }
}
