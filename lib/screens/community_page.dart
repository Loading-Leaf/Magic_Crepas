import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import "package:ai_art/artproject/terms_of_service.dart";
import 'package:ai_art/artproject/audio_provider.dart';
import 'package:ai_art/artproject/effect_utils.dart';
import 'package:ai_art/artproject/language_provider.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    double fontsize_big = screenSize.width / 64;
    double fontsize = screenSize.width / 74.6;
    final audioProvider = Provider.of<AudioProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return PopScope(
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
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              child: TextButton(
                                onPressed: () {
                                  audioProvider.playSound("tap1.mp3");
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      Color.fromARGB(255, 255, 67, 195),
                                ),
                                child: Text(
                                  languageProvider.locallanguage == 2
                                      ? "Trending"
                                      : 'トレンド',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: fontsize,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                            Container(
                              child: TextButton(
                                onPressed: () {
                                  audioProvider.playSound("tap1.mp3");
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      Color.fromARGB(255, 255, 67, 195),
                                ),
                                child: Text(
                                  languageProvider.locallanguage == 2
                                      ? "Genre"
                                      : 'ジャンル',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: fontsize,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                            Container(
                              child: TextButton(
                                onPressed: () {
                                  audioProvider.playSound("tap1.mp3");
                                  Navigator.pushNamed(context, '/menu');
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      Color.fromARGB(255, 255, 67, 195),
                                ),
                                child: Text(
                                  languageProvider.locallanguage == 2
                                      ? "Back to Title"
                                      : languageProvider.isHiragana
                                          ? 'メニューにもどる'
                                          : 'メニューに戻る',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: fontsize,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ]),
                      Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            //コミュニティ
                            Text(
                              languageProvider.locallanguage == 2
                                  ? "Commynity"
                                  : 'コミュニティ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: fontsize,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                //ここに画面遷移などのイベントを書く。
                                audioProvider.playSound("tap1.mp3");
                              },
                              child: Padding(
                                padding: EdgeInsets.all(3.0),
                                child: Container(
                                  height: screenSize.height * 0.6, // 縦長の場合
                                  width: screenSize.width * 0.6, // 縦長の場合
                                  color: Colors.grey,
                                  child: FittedBox(
                                    fit: BoxFit.fill,
                                    child: Image.asset(
                                        'assets/ButtonImage/menu1_2.png'),
                                  ),
                                ),
                              ),
                            ),
                          ]),
                    ])))));
  }
}
