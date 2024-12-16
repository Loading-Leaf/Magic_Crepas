import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import "package:ai_art/artproject/terms_of_service.dart";
import 'package:audioplayers/audioplayers.dart';
import 'package:ai_art/artproject/audio_provider.dart';
import 'package:ai_art/artproject/effect_utils.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    double fontsize_big = 20;
    double fontsize = 14;
    final url = Uri.parse('https://forms.gle/JAR2RYDkzbzFwdei6');
    final audioProvider = Provider.of<AudioProvider>(context);

    return Scaffold(
      body: GestureDetector(
        onTapUp: (details) {
          // タッチされた位置を取得
          Offset tapPosition = details.localPosition;
          // キラキラエフェクトを表示
          showSparkleEffect(context, tapPosition);
        },
        child: SizedBox.expand(
          // SizedBox.expandで全画面をタップ対象にする
          child: Column(
            children: <Widget>[
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Padding(
                  padding: EdgeInsets.all(10.0), // ここでPaddingを追加
                  child: Container(
                    alignment: Alignment.centerLeft, // 左寄せ
                    child: Container(
                      height: screenSize.height * 0.15,
                      width: screenSize.width * 0.20,
                      child: Image.asset('assets/title_logo_main.png'),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0), // ここでPaddingを追加
                  child: Container(
                    child: TextButton(
                      onPressed: () {
                        audioProvider.playSound("tap1.mp3");
                        _showSettingsDialog(context, audioProvider);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 255, 67, 195),
                      ),
                      child: Text(
                        '設定',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: fontsize,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ]),
              Padding(
                padding: EdgeInsets.all(1.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 均等に配置
                  children: [
                    Text(
                      'AIが絵と写真で新しいアートを作ってくれるよ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontsize_big,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center, // 中央に配置
                      children: [
                        Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Container(
                            height: screenSize.width * 0.22,
                            width: screenSize.width * 0.72,
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: Image.asset('assets/title_image.png'),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center, // 縦の間隔も均等に
                          children: [
                            Container(
                              child: TextButton(
                                onPressed: () {
                                  audioProvider.playSound("tap1.mp3");
                                  Navigator.pushNamed(context, '/generate');
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      Color.fromARGB(255, 255, 67, 195),
                                ),
                                child: Text(
                                  'AIでアートを作る',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: fontsize,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                            SizedBox(height: 10), // ボタン間のスペース
                            Container(
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
                                  'あそび方',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: fontsize,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Text(
                        '好きなものとアートを組み合わせると？？？',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontsize,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter, // 画面の下部に配置
                  child: Column(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: screenSize.height * 0.1),
                        Container(
                          child: TextButton(
                            onPressed: () {
                              audioProvider.playSound("tap1.mp3");
                              // 利用規約モーダルを表示
                              showDialog(
                                context: context,
                                builder: (context) => TermsOfServiceDialog(),
                              );
                            },
                            child: Text(
                              '利用規約',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: fontsize,
                                color: const Color.fromARGB(255, 255, 67, 195),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          child: TextButton(
                            onPressed: () {
                              audioProvider.playSound("tap1.mp3");
                              launchUrl(url);
                            },
                            child: Text(
                              'お問い合わせ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: fontsize,
                                color: const Color.fromARGB(255, 255, 67, 195),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenSize.height * 0.05),
                  ]),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context, AudioProvider audioProvider) {
    double fontsize_big = 40;
    double fontsize = 14;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            '設定',
            style:
                TextStyle(fontWeight: FontWeight.bold, fontSize: fontsize_big),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '音量調整ボタン',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: fontsize),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      audioProvider.setVolume(0.0); // 音量を0に設定
                      audioProvider.playSound("tap1.mp3");
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 255, 67, 195),
                    ),
                    child: Text(
                      '音量 0%',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontsize,
                          color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      audioProvider.setVolume(0.5); // 音量を50%に設定
                      audioProvider.playSound("tap1.mp3");
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 255, 67, 195),
                    ),
                    child: Text(
                      '音量 50%',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontsize,
                          color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      audioProvider.setVolume(1.0); // 音量を100%に設定
                      audioProvider.playSound("tap1.mp3");
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 255, 67, 195),
                    ),
                    child: Text(
                      '音量 100%',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontsize,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
              Text(
                '年齢設定ボタン',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: fontsize),
              ),
              Text(
                '準備中です',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: fontsize),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // ダイアログを閉じる
              },
              style: TextButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 255, 67, 195),
              ),
              child: Text(
                '閉じる',
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
