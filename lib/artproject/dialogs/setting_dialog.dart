import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import "package:ai_art/artproject/terms_of_service.dart";
import 'package:ai_art/artproject/audio_provider.dart';
import 'package:ai_art/artproject/effect_utils.dart';
import 'package:ai_art/artproject/language_provider.dart';

class SettingDialog extends StatefulWidget {
  const SettingDialog({super.key});

  @override
  _SettingDialogState createState() => _SettingDialogState();
}

class _SettingDialogState extends State<SettingDialog> {
  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);

    Size screenSize = MediaQuery.sizeOf(context);
    double fontsize_big = screenSize.width / 64;
    double fontsize = screenSize.width / 74.6;
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    return AlertDialog(
      title: Text(
        languageProvider.locallanguage == 2
            ? "Settings"
            : languageProvider.isHiragana
                ? 'せってい'
                : '設定',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontsize_big),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              languageProvider.locallanguage == 2
                  ? "Volume button"
                  : languageProvider.isHiragana
                      ? 'おんりょうボタン'
                      : '音量ボタン',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontsize),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      audioProvider.setVolume(0.0);
                      audioProvider.playSound("tap1.mp3");
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 255, 67, 195),
                  ),
                  child: Text(
                    languageProvider.locallanguage == 2
                        ? "Mute🔈"
                        : languageProvider.isHiragana
                            ? 'おとなし🔈'
                            : '音なし🔈',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontsize,
                        color: Colors.white),
                  ),
                ),
                SizedBox(width: 10),
                TextButton(
                  onPressed: () {
                    setState(() {
                      audioProvider.setVolume(1.0);
                      audioProvider.playSound("tap1.mp3");
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 255, 67, 195),
                  ),
                  child: Text(
                    languageProvider.locallanguage == 2
                        ? "Sound🔊"
                        : languageProvider.isHiragana
                            ? 'おとあり🔊'
                            : '音あり🔊',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontsize,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
            Text(
              languageProvider.locallanguage == 2
                  ? "Language button"
                  : languageProvider.isHiragana
                      ? "げんごボタン"
                      : '言語ボタン',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontsize),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      languageProvider.setlocalLanguage(1);
                      audioProvider.playSound("tap1.mp3");
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 255, 67, 195),
                  ),
                  child: Text(
                    languageProvider.locallanguage == 2
                        ? "Japanese"
                        : languageProvider.isHiragana
                            ? 'にほんご'
                            : "日本語",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontsize,
                        color: Colors.white),
                  ),
                ),
                SizedBox(width: 10),
                TextButton(
                  onPressed: () {
                    setState(() {
                      languageProvider.setlocalLanguage(2);
                      audioProvider.playSound("tap1.mp3");
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 255, 67, 195),
                  ),
                  child: Text(
                    languageProvider.locallanguage == 2
                        ? "English"
                        : languageProvider.isHiragana
                            ? 'えいご'
                            : "英語",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontsize,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
            if (languageProvider.locallanguage == 1) ...[
              Text(
                '漢字・ひらがなカタカナボタン',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: fontsize),
              ),
              //languageProviderにisHiraganaという変数を準備
              //「ひらがなカタカナ」と選択されたらtrueと返す→全ての文字がひらがなカタカナのみになる
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        languageProvider.setLanguage(true);
                        audioProvider.playSound("tap1.mp3");
                      });
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 255, 67, 195),
                    ),
                    child: Text(
                      'ひらがなカタカナ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontsize,
                          color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        languageProvider.setLanguage(false);
                        audioProvider.playSound("tap1.mp3");
                      });
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 255, 67, 195),
                    ),
                    child: Text(
                      '漢字',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontsize,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            audioProvider.playSound("tap1.mp3");
            Navigator.pop(context);
          },
          style: TextButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 0, 204, 255),
          ),
          child: Text(
            languageProvider.locallanguage == 2
                ? "Close"
                : languageProvider.isHiragana
                    ? 'とじる'
                    : '閉じる',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontsize,
                color: Colors.white),
          ),
        ),
      ],
    );
  }
}
