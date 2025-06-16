import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';

class DeviceProvider with ChangeNotifier {
  String your_platform = ""; //使用している端末
  bool isipad = false; //iPadかどうか

  Future<void> checkDevice() async {
    final deviceInfo = DeviceInfoPlugin();

    //保存時、それぞれの端末ごとに文言を変更
    //例えばiPhoneの場合は「スマホ」,iPadの場合は「アイパッド」と表示
    //使用する場面は「○○に保存」と記載するボタンで使用
    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      setState(() {
        if (iosInfo.model.toLowerCase().contains("ipad")) {
          your_platform =
              languageProvider.locallanguage == 2 ? "Tablet" : "タブレット";
        } else {
          your_platform = languageProvider.locallanguage == 2 ? "Phone" : "スマホ";
        }
      });
    } else if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      setState(() {
        if (androidInfo.systemFeatures
                .contains("android.hardware.type.television") ||
            androidInfo.systemFeatures
                .contains("android.hardware.type.watch") ||
            androidInfo.systemFeatures
                .contains("android.hardware.type.automotive")) {
          your_platform = languageProvider.locallanguage == 2 ? "Other" : "その他";
        } else if (androidInfo.model.toLowerCase().contains("tablet") ||
            androidInfo.product.toLowerCase().contains("tablet")) {
          your_platform =
              languageProvider.locallanguage == 2 ? "Tablet" : "タブレット";
        } else {
          your_platform = languageProvider.locallanguage == 2 ? "Phone" : "スマホ";
        }
      });
    }
  }
}
