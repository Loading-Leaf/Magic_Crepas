import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_art/artproject/audio_provider.dart';
import 'package:ai_art/artproject/effect_utils.dart';
import 'package:ai_art/artproject/language_provider.dart';

class TutorialDetailPage extends StatefulWidget {
  final List<String> chapters;
  final int tutorialnumber;

  const TutorialDetailPage(
      {super.key, required this.tutorialnumber, required this.chapters});

  @override
  _TutorialDetailPageState createState() => _TutorialDetailPageState();
}

class _TutorialDetailPageState extends State<TutorialDetailPage> {
  int chapter = 1; // 現在の章を保持する変数

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    double fontsize_big = screenSize.width / 64;
    double fontsize = screenSize.width / 74.6;
    final audioProvider = Provider.of<AudioProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    List<String> chapters = [
      languageProvider.isHiragana ? "これはさいしょのがめんだよ" : "これは最初の画面だよ",
      "「AIでアートを作る」を押してみてね",
      "これは絵を作る画面だよ\n前に作った絵もあるよ",
      "絵を描くときは「お絵描きする」を押してね",
      "大きな紙とカラフルなパレットで絵を描くよ",
      "パレットから好きな色を選んで描いてみてね",
      "筆の大きさも変えられるよ",
      "間違えたら戻したり、やり直したりできるよ",
      "絵をこんな風に描けるよ\n背景を描くのがオススメだよ",
      "絵を描き終わったら「できたよ」を押してね",
      "描いた絵がここにあるよ",
      "次は写真を選んでみよう\n「写真を選ぶ」を押してね",
      "写真アプリから写真を選んだよ",
      "モードを変えてみよう\nモードによって写真を切り抜く方法が変わるよ",
      "このボタンを押すとそれぞれのモードの特徴が見られるよ",
      "それぞれのモードについて話すよ！\n「モードA」は絵の世界に入れるし、「モードB」は絵の中に物を呼び出せるんだよ！",
      "「モードA」は人がたくさんいる時やテーブルがある時にオススメ！",
      "「モードB」はおやつや小さい物が近くにある時にオススメ！\nでも、たくさん人がいる写真には向いていないよ",
      "「モードC」は背景以外をアートにしたい時にオススメ！",
      "「モードD」はおやつや小さい物をアートにしたい時にオススメ！",
      "「アートをつくる」で「モードA」のアートを作ろう！\n※ネットがつながっているところでやってね",
      "AIが絵を作っている間に、間違いさがしで遊ぼう",
      "音が鳴ったら絵が完成するよ！\n絵が完成すると、間違いさがしの答えも見れるよ",
      "音が鳴ったら絵が完成したよ！\n「完成した絵を見る」を押してね",
      "作った絵とお絵描きした絵が見られるよ",
      "作った絵を保存してみよう",
      "お絵描きした絵も保存してみよう",
      "これで遊び方は終わりだよ！\nお絵描き、楽しんでね！！！"
    ];

    return Scaffold(
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
                languageProvider.isHiragana ? 'あそびかた' : 'あそび方',
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
                        'assets/tutorial/' + chapter.toString() + '.png',
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
                            if (chapter >= 28) {
                              audioProvider.playSound("tap2.mp3");
                              Navigator.pushNamed(context, '/');
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
                          languageProvider.isHiragana ? 'すすむ' : '進む',
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
                              Navigator.pushNamed(context, '/');
                            } else {
                              audioProvider.playSound("tap1.mp3");
                              chapter -= 1; // 章を戻す
                            }
                          });
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 255, 67, 195),
                        ),
                        child: Text(
                          languageProvider.isHiragana ? 'もどる' : '戻る',
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
          ],
        ),
      ),
    );
  }
}
