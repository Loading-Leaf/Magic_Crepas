import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_art/artproject/audio_provider.dart';
import 'package:ai_art/artproject/effect_utils.dart';
import 'package:ai_art/artproject/language_provider.dart';
import 'package:ai_art/artproject/modal_provider.dart';

class TutorialDetailPage extends StatefulWidget {
  final List<String> chapters;
  final int tutorialnumber;
  final String title;

  const TutorialDetailPage(
      {super.key,
      required this.tutorialnumber,
      required this.chapters,
      required this.title});

  @override
  _TutorialDetailPageState createState() => _TutorialDetailPageState();
}

class _TutorialDetailPageState extends State<TutorialDetailPage> {
  int chapter = 1; // 現在の章を保持する変数
  late int tutorialnum; // 修正: late を使用して初期化を遅延
  late List<String> chapters;
  late String tutorial_title;

  @override
  void initState() {
    super.initState();
    tutorialnum = widget.tutorialnumber; // 修正: widget. をつける
    chapters = widget.chapters;
    tutorial_title = widget.title;
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    double fontsize_big = screenSize.width / 64;
    double fontsize = screenSize.width / 74.6;
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // 中央寄せ
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(5.0),
                child: Text(
                  tutorial_title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontsize_big,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(3.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 3),
                      ),
                      height: screenSize.width * 0.2585,
                      width: screenSize.width * 0.55,
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Image.asset(
                          'assets/tutorial/' +
                              tutorialnum.toString() +
                              "/" +
                              chapter.toString() +
                              '.png',
                        ),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              if (chapter >= chapters.length) {
                                audioProvider.playSound("tap2.mp3");
                                Navigator.pushNamed(context, '/tutorial');
                              } else {
                                audioProvider.playSound("tap1.mp3");
                                chapter += 1; // 章を進める
                              }
                            });
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 255, 67, 195),
                          ),
                          child: Text(
                            languageProvider.isHiragana ? 'すすむ🔜' : '進む🔜',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: fontsize,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              if (chapter <= 1) {
                                audioProvider.playSound("tap1.mp3");
                                Navigator.pushNamed(context, '/tutorial');
                              } else {
                                audioProvider.playSound("tap1.mp3");
                                chapter -= 1; // 章を戻す
                              }
                            });
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 0, 81, 255),
                          ),
                          child: Text(
                            languageProvider.isHiragana ? 'もどる🔙' : '戻る🔙',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: fontsize,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              audioProvider.playSound("tap1.mp3");
                              Navigator.pushNamed(context, '/tutorial');
                            });
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 0, 81, 255),
                          ),
                          child: Text(
                            'やめる🔚',
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
                child: Text(chapters[chapter - 1],
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: fontsize)),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
