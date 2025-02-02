import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_art/artproject/audio_provider.dart';
import 'package:ai_art/artproject/effect_utils.dart';
import 'tutorial_detail_page.dart';
import 'package:ai_art/artproject/language_provider.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  _TutorialPageState createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    double fontsize_big = screenSize.width / 64;
    double fontsize = screenSize.width / 74.6;
    final audioProvider = Provider.of<AudioProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    int page = 1;

    List<String> chapters1 = [
      languageProvider.isHiragana ? "これはさいしょのがめんだよ" : "これは最初の画面だよ",
      languageProvider.isHiragana
          ? "「AIでアートをつくる」をおしてみてね"
          : "「AIでアートを作る」を押してみてね",
      languageProvider.isHiragana
          ? "これはえをつくるがめんだよ\nまえにつくったえもあるよ"
          : "これは絵を作る画面だよ\n前に作った絵もあるよ",
      languageProvider.isHiragana
          ? "えをかくときは「おえかきする」をおしてね"
          : "絵を描くときは「お絵描きする」を押してね",
      languageProvider.isHiragana
          ? "おおきなかみとカラフルなパレットでえをかくよ"
          : "大きな紙とカラフルなパレットで絵を描くよ",
      languageProvider.isHiragana
          ? "パレットからすきないろをえらんでかいてみてね"
          : "パレットから好きな色を選んで描いてみてね",
      languageProvider.isHiragana ? "ふでのおおきさもかえられるよ" : "筆の大きさも変えられるよ",
      languageProvider.isHiragana
          ? "まちがえたらもどしたり、やりなおしたりできるよ"
          : "間違えたら戻したり、やり直したりできるよ",
      languageProvider.isHiragana
          ? "えをこんなふうにかけるよ\nはいけいをかくのがおすすめだよ"
          : "絵をこんな風に描けるよ\n背景を描くのがオススメだよ",
      languageProvider.isHiragana
          ? "えをかきおわったら「できたよ」をおしてね"
          : "絵を描き終わったら「できたよ」を押してね",
      languageProvider.isHiragana ? "かいたえがここにあるよ" : "描いた絵がここにあるよ",
      languageProvider.isHiragana
          ? "つぎはしゃしんをえらんでみよう\n「しゃしんをえらぶ」をおしてね"
          : "次は写真を選んでみよう\n「写真を選ぶ」を押してね",
      languageProvider.isHiragana ? "しゃしんアプリからしゃしんをえらんだよ" : "写真アプリから写真を選んだよ",
      languageProvider.isHiragana
          ? "モードをかえてみよう\nモードによってしゃしんをきりぬくほうほうがかわるよ"
          : "モードを変えてみよう\nモードによって写真を切り抜く方法が変わるよ",
      languageProvider.isHiragana
          ? "このボタンをおすとそれぞれのモードのとくちょうがみられるよ"
          : "このボタンを押すとそれぞれのモードの特徴が見られるよ",
      languageProvider.isHiragana
          ? "それぞれのモードについてはなすよ！\n「モードA」はえのせかいにはいれるし、「モードB」はえのなかにものをよびだせるんだよ！"
          : "それぞれのモードについて話すよ！\n「モードA」は絵の世界に入れるし、「モードB」は絵の中に物を呼び出せるんだよ！",
      languageProvider.isHiragana
          ? "「モードA」はひとがたくさんいるときやテーブルがあるときにおすすめ！"
          : "「モードA」は人がたくさんいる時やテーブルがある時にオススメ！",
      languageProvider.isHiragana
          ? "「モードB」はおやつやちいさいものがちかくにあるときにおすすめ！\nでも、たくさんひとがいるしゃしんにはむいていないよ"
          : "「モードB」はおやつや小さい物が近くにある時にオススメ！\nでも、たくさん人がいる写真には向いていないよ",
      languageProvider.isHiragana
          ? "「モードC」ははいけいいがいをアートにしたいときにおすすめ！"
          : "「モードC」は背景以外をアートにしたい時にオススメ！",
      languageProvider.isHiragana
          ? "「モードD」はおやつやちいさいものをアートにしたいときにおすすめ！"
          : "「モードD」はおやつや小さい物をアートにしたい時にオススメ！",
      languageProvider.isHiragana
          ? "「アートをつくる」で「モードA」のアートをつくろう！\n※ネットがつながっているところでやってね"
          : "「アートをつくる」で「モードA」のアートを作ろう！\n※ネットがつながっているところでやってね",
      languageProvider.isHiragana
          ? "AIがえをつくっているあいだに、まちがいさがしであそぼう"
          : "AIが絵を作っている間に、間違いさがしで遊ぼう",
      languageProvider.isHiragana
          ? "おとがなったらえがかんせいするよ！\nえがかんせいすると、まちがいさがしのこたえもみれるよ"
          : "音が鳴ったら絵が完成するよ！\n絵が完成すると、間違いさがしの答えも見れるよ",
      languageProvider.isHiragana
          ? "おとがなったらえがかんせいしたよ！\n「かんせいしたえをみる」をおしてね"
          : "音が鳴ったら絵が完成したよ！\n「完成した絵を見る」を押してね",
      languageProvider.isHiragana
          ? "つくったえとおえかきしたえがみられるよ"
          : "作った絵とお絵描きした絵が見られるよ",
      languageProvider.isHiragana ? "つくったえをほぞんしてみよう" : "作った絵を保存してみよう",
      languageProvider.isHiragana ? "おえかきしたえもほぞんしてみよう" : "お絵描きした絵も保存してみよう",
      languageProvider.isHiragana
          ? "これであそびかたはおわりだよ！\nおえかき、たのしんでね！！！"
          : "これで遊び方は終わりだよ！\nお絵描き、楽しんでね！！！"
    ];

    void _undopage() {
      setState(() {
        if (page > 1) {
          page -= 1;
        }
      });
    }

    void _redopage() {
      setState(() {
        if (page < 2) {
          page += 1;
        }
      });
    }

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
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: page > 1 ? _undopage : null,
                  tooltip: 'left',
                  splashColor: Color.fromARGB(255, 255, 67, 195),
                  iconSize: MediaQuery.of(context).size.width / 28,
                ),
                Column(
                    mainAxisAlignment: MainAxisAlignment.center, // 中央寄せ
                    children: <Widget>[
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center, // 中央寄せ
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.all(3.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.black, width: 3),
                                      ),
                                      height: screenSize.width * 0.1175,
                                      width: screenSize.width * 0.25,
                                      child: FittedBox(
                                        fit: BoxFit.fill,
                                        child: Image.asset(
                                          'assets/tutorial/' +
                                              (page * 4 - 4).toString() +
                                              '.png',
                                        ),
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    child: Text(
                                      page == 1
                                          ? languageProvider.isHiragana
                                              ? 'ひととおりのやりかた'
                                              : '一通りのやりかた'
                                          : "シェア",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: fontsize,
                                          color: Colors.white),
                                    ),
                                    style: TextButton.styleFrom(
                                      backgroundColor:
                                          Color.fromARGB(255, 255, 67, 195),
                                    ),
                                    onPressed: () {
                                      audioProvider.playSound("tap1.mp3");
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              TutorialDetailPage(
                                                  tutorialnumber: 1,
                                                  chapters: chapters1),
                                        ),
                                      );
                                    },
                                  ),
                                ]),
                            Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center, // 中央寄せ
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.all(3.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.black, width: 3),
                                      ),
                                      height: screenSize.width * 0.1175,
                                      width: screenSize.width * 0.25,
                                      child: FittedBox(
                                        fit: BoxFit.fill,
                                        child: Image.asset(
                                          'assets/tutorial/' +
                                              (page * 4 - 3).toString() +
                                              '.png',
                                        ),
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    child: Text(
                                      page == 1
                                          ? languageProvider.isHiragana
                                              ? 'おえかき'
                                              : 'お絵描き'
                                          : 'ギャラリー',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: fontsize,
                                          color: Colors.white),
                                    ),
                                    style: TextButton.styleFrom(
                                      backgroundColor:
                                          Color.fromARGB(255, 255, 67, 195),
                                    ),
                                    onPressed: () {
                                      audioProvider.playSound("tap1.mp3");
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              TutorialDetailPage(
                                                  tutorialnumber: 1,
                                                  chapters: chapters1),
                                        ),
                                      );
                                    },
                                  ),
                                ]),
                          ]),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center, // 中央寄せ
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.all(3.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.black, width: 3),
                                      ),
                                      height: screenSize.width * 0.1175,
                                      width: screenSize.width * 0.25,
                                      child: FittedBox(
                                        fit: BoxFit.fill,
                                        child: Image.asset(
                                          'assets/tutorial/' +
                                              (page * 4 - 2).toString() +
                                              '.png',
                                        ),
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    child: Text(
                                      page == 1
                                          ? 'まちがいさがし'
                                          : languageProvider.isHiragana
                                              ? 'べつのモード'
                                              : '別のモード',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: fontsize,
                                          color: Colors.white),
                                    ),
                                    style: TextButton.styleFrom(
                                      backgroundColor:
                                          Color.fromARGB(255, 255, 67, 195),
                                    ),
                                    onPressed: () {
                                      audioProvider.playSound("tap1.mp3");
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              TutorialDetailPage(
                                                  tutorialnumber: 1,
                                                  chapters: chapters1),
                                        ),
                                      );
                                    },
                                  ),
                                ]),
                            Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center, // 中央寄せ
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.all(3.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.black, width: 3),
                                      ),
                                      height: screenSize.width * 0.1175,
                                      width: screenSize.width * 0.25,
                                      child: FittedBox(
                                        fit: BoxFit.fill,
                                        child: Image.asset(
                                          'assets/tutorial/' +
                                              (page * 4 - 1).toString() +
                                              '.png',
                                        ),
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    child: Text(
                                      page == 1
                                          ? languageProvider.isHiragana
                                              ? 'プロジェクトほぞん'
                                              : 'プロジェクト保存'
                                          : languageProvider.isHiragana
                                              ? 'せってい'
                                              : "設定",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: fontsize,
                                          color: Colors.white),
                                    ),
                                    style: TextButton.styleFrom(
                                      backgroundColor:
                                          Color.fromARGB(255, 255, 67, 195),
                                    ),
                                    onPressed: () {
                                      audioProvider.playSound("tap1.mp3");
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              TutorialDetailPage(
                                                  tutorialnumber: 1,
                                                  chapters: chapters1),
                                        ),
                                      );
                                    },
                                  ),
                                ]),
                          ]),
                    ]),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: page < 2 ? _redopage : null,
                  tooltip: 'right',
                  splashColor: Color.fromARGB(255, 255, 67, 195),
                  iconSize: MediaQuery.of(context).size.width / 28,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    audioProvider.playSound("tap1.mp3");
                    Navigator.pushNamed(context, '/');
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 67, 195),
                  ),
                  child: Text(
                    languageProvider.isHiragana ? 'とじる' : '閉じる',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: fontsize,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
