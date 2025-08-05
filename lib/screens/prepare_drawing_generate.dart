import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import "package:ai_art/artproject/terms_of_service.dart";
import 'package:ai_art/artproject/audio_provider.dart';
import 'package:ai_art/artproject/effect_utils.dart';
import 'package:ai_art/artproject/language_provider.dart';
import 'package:ai_art/artproject/device_provider.dart';
import "package:ai_art/screens/drawing_page.dart";

class preparePage extends StatefulWidget {
  const preparePage({super.key});

  @override
  State<preparePage> createState() => _preparePageState();
}

class _preparePageState extends State<preparePage> {
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    double fontsize_big = screenSize.width / 64;
    double fontsize = screenSize.width / 74.6;
    double tile_size = screenSize.height * 0.6;

    final audioProvider = Provider.of<AudioProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final deviceProvider = Provider.of<DeviceProvider>(context);

    return PopScope(
      canPop: false, // false で無効化
      child: Scaffold(
        body: GestureDetector(
          onTap: () {
            audioProvider.playSound("tap1.mp3");
            Navigator.pushNamed(context, '/menu');
          },
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
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          //ここに画面遷移などのイベントを書く。
                          audioProvider.playSound("tap1.mp3");
                          Navigator.pushNamed(context, '/generate');
                        },
                        child: Padding(
                          padding: EdgeInsets.all(3.0),
                          child: Container(
                            height: tile_size, // 縦長の場合
                            width: tile_size, // 縦長の場合
                            color: Colors.grey,
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child:
                                  Image.asset('assets/ButtonImage/menu1_1.png'),
                            ),
                          ),
                        ),
                      ),
                      //お絵描きをする
                      GestureDetector(
                        onTap: () {
                          //ここに画面遷移などのイベントを書く。
                          audioProvider.playSound("tap1.mp3");
                          MaterialPageRoute(
                            builder: (context) => DrawingPage(drawing_mode: 2),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.all(3.0),
                          child: Container(
                            height: tile_size, // 縦長の場合
                            width: tile_size, // 縦長の場合
                            color: Colors.grey,
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child:
                                  Image.asset('assets/ButtonImage/menu1_2.png'),
                            ),
                          ),
                        ),
                      ),
                    ]),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 10),
                    Container(
                      child: TextButton(
                        onPressed: () {
                          audioProvider.playSound("tap1.mp3");
                          Navigator.pushNamed(context, '/menu');
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 255, 67, 195),
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
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
