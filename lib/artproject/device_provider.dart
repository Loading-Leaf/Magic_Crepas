import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io' show Platform;
import 'package:provider/provider.dart';
import 'package:ai_art/artproject/language_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceProvider with ChangeNotifier {
  String _yourPlatform = ""; // 使用している端末名
  int _deviceNumber = 0; // 1: タブレット, 2: スマホ, 3: その他
  int get deviceNumber => _deviceNumber;
  String get yourPlatform => _yourPlatform; // 使用している端末名を取得

  final LanguageProvider languageProvider;

  DeviceProvider({required this.languageProvider}) {
    checkDevice();
    _loaddevice();
  }

  // 設定を読み込む
  Future<void> checkDevice() async {
    final deviceInfo = DeviceInfoPlugin();
    int locallanguage = languageProvider.locallanguage;
    final prefs = await SharedPreferences.getInstance();

    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      if (iosInfo.model.toLowerCase().contains("ipad")) {
        _yourPlatform = locallanguage == 2 ? "Tablet" : "タブレット";
        _deviceNumber = 1;
        await prefs.setInt('deviceNumber', _deviceNumber);
      } else {
        _yourPlatform = locallanguage == 2 ? "Phone" : "スマホ";
        _deviceNumber = 2;
        await prefs.setInt('deviceNumber', _deviceNumber);
      }
    } else if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.systemFeatures
              .contains("android.hardware.type.television") ||
          androidInfo.systemFeatures.contains("android.hardware.type.watch") ||
          androidInfo.systemFeatures
              .contains("android.hardware.type.automotive")) {
        _yourPlatform = locallanguage == 2 ? "Other" : "その他";
        _deviceNumber = 3;
        await prefs.setInt('deviceNumber', _deviceNumber);
      } else if (androidInfo.model.toLowerCase().contains("tablet") ||
          androidInfo.product.toLowerCase().contains("tablet")) {
        _yourPlatform = locallanguage == 2 ? "Tablet" : "タブレット";
        _deviceNumber = 1;
        await prefs.setInt('deviceNumber', _deviceNumber);
      } else {
        _yourPlatform = locallanguage == 2 ? "Phone" : "スマホ";
        _deviceNumber = 2;
        await prefs.setInt('deviceNumber', _deviceNumber);
      }
    }

    notifyListeners();
  }

  Future<void> _loaddevice() async {
    final prefs = await SharedPreferences.getInstance();
    _deviceNumber = prefs.getInt('deviceNumber') ?? 1; // デフォルトはタブレット
    notifyListeners();
  }
}
