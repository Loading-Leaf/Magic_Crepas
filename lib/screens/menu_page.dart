import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import "package:ai_art/artproject/terms_of_service.dart";
import 'package:ai_art/artproject/audio_provider.dart';
import 'package:ai_art/artproject/effect_utils.dart';
import 'package:ai_art/artproject/language_provider.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    double fontsize_big = screenSize.width / 64;
    double fontsize = screenSize.width / 74.6;
    final url = Uri.parse(
        'https://forms.gle/JAR2RYDkzbzFwdei6'); //バグや疑問点などの指摘の際にformを準備
    final audioProvider = Provider.of<AudioProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return PopScope(
      // ここを追加
      canPop: false, // false で無効化
      child: Scaffold(
        body: GestureDetector(
          onTapUp: (details) {
            // タッチされた位置を取得
            Offset tapPosition = details.localPosition;
            // キラキラエフェクトを表示
            showSparkleEffect(context, tapPosition);
          },
          child: SizedBox.expand(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 10),
                        //画面の中央にまじっくくれぱすの画像を添付
                        Padding(
                          padding: EdgeInsets.all(7.0),
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              height: screenSize.height * 0.15 * 0.75,
                              width: screenSize.width * 0.20 * 0.75,
                              child: Image.asset(
                                  languageProvider.locallanguage == 2
                                      ? 'assets/title_logo_main_en.png'
                                      : 'assets/title_logo_main.png'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(7.0),
                          child: Container(
                            child: TextButton(
                              onPressed: () {
                                audioProvider.playSound("tap1.mp3");
                                _showSettingsDialog(
                                    context, audioProvider, languageProvider);
                              },
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(255, 255, 67, 195),
                              ),
                              child: Text(
                                languageProvider.locallanguage == 2
                                    ? "Settings"
                                    : languageProvider.isHiragana
                                        ? 'せってい'
                                        : '設定',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: fontsize,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Padding(
                          padding: EdgeInsets.all(7.0),
                          child: Container(
                            child: TextButton(
                              onPressed: () {
                                audioProvider.playSound("tap1.mp3");
                                Navigator.pushNamed(context, '/gallery');
                              },
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(255, 255, 67, 195),
                              ),
                              child: Text(
                                languageProvider.locallanguage == 2
                                    ? "Gallery"
                                    : languageProvider.isHiragana
                                        ? 'ギャラリーをみる'
                                        : 'ギャラリーを見る',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: fontsize,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Padding(
                          padding: EdgeInsets.all(7.0),
                          child: Container(
                            child: TextButton(
                              onPressed: () {
                                audioProvider.playSound("tap1.mp3");
                                Navigator.pushNamed(context, '/tutorial');
                              },
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(255, 0, 164, 14),
                              ),
                              child: Text(
                                languageProvider.locallanguage == 2
                                    ? "Tutorial"
                                    : languageProvider.isHiragana
                                        ? 'あそびかたをみる'
                                        : 'あそび方を見る',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: fontsize,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                  ],
                ),
                Container(
                  child: TextButton(
                    onPressed: () {
                      audioProvider.playSound("tap1.mp3");
                      Navigator.pushNamed(context, '/generate');
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 255, 67, 195),
                    ),
                    child: Text(
                      languageProvider.locallanguage == 2
                          ? "Generate arts"
                          : languageProvider.isHiragana
                              ? 'アートをつくる'
                              : 'アートを作る',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontsize,
                          color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 5),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //設定用のダイアログ(音声と仮名読み)
  void _showSettingsDialog(BuildContext context, AudioProvider audioProvider,
      LanguageProvider languageProvider) {
    double fontsize_big = 20;
    double fontsize = 12;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            languageProvider.locallanguage == 2
                ? "Settings"
                : languageProvider.isHiragana
                    ? 'せってい'
                    : '設定',
            style:
                TextStyle(fontWeight: FontWeight.bold, fontSize: fontsize_big),
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
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: fontsize),
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
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: fontsize),
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
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: fontsize),
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
      },
    );
  }
}
