import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_art/artproject/audio_provider.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  _TutorialPageState createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  int chapter = 1; // 現在の章を保持する変数

  List<String> chapters = [
    "最初はこの画面だよ",
    "「AIでアートを作る」を押してね",
    "最初はこんな画面だよ\n前描いた絵があるよ",
    "絵を描くとき「お絵描きをする」を押してね",
    "大きい紙とパレットで絵を描くよ",
    "ここがパレットで色を選んで書いてね",
    "筆の大きさを変えれるよ",
    "絵を描き終わったら「できたよ」を押してね",
    "描いた絵があるよ",
    "次は写真を選んでみよう\n「写真を選ぶ」を押してね",
    "写真アプリから写真を選んだよ",
    "「アートをつくる」でアートを作ろう！",
    "作ってる間はまちがいさがしであそぼう",
    "絵ができたら「完成した絵を見る」を押してね",
    "作った絵とお絵描きした絵が出てくるよ",
    "作った絵を保存してみよう",
    "お絵描きした絵を保存してみよう",
    "これであそび方の話は終わりだよ！\nお絵描き楽しんでね！！！"
  ];
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    double fontsize_big = (screenSize.height ~/ 20).toDouble();
    double fontsize = (screenSize.height ~/ 29).toDouble();
    final audioProvider = Provider.of<AudioProvider>(context);
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(5.0),
            child: Text(
              'あそび方',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontsize_big,
              ),
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Padding(
              padding: EdgeInsets.all(5.0),
              child: Container(
                height: screenSize.width * 0.282,
                width: screenSize.width * 0.6,
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Image.asset(
                    'assets/tutorial/' + chapter.toString() + '.png',
                  ),
                ),
              ),
            ),
            Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              Container(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      if (chapter >= 18) {
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
                    '進む',
                    style: TextStyle(fontSize: fontsize, color: Colors.white),
                  ),
                ),
              ),
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
                    '戻る',
                    style: TextStyle(fontSize: fontsize, color: Colors.white),
                  ),
                ),
              ),
            ]),
          ]),
          Padding(
            padding: EdgeInsets.all(5.0),
            child: Text(chapters[chapter - 1],
                style: TextStyle(fontSize: fontsize)),
          ),
        ],
      ),
    );
  }
}