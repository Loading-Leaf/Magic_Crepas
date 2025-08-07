import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import "package:ai_art/artproject/terms_of_service.dart";
import 'package:ai_art/artproject/audio_provider.dart';
import 'package:ai_art/artproject/effect_utils.dart';
import 'package:ai_art/artproject/language_provider.dart';

class LessonColorPage extends StatefulWidget {
  const LessonColorPage({super.key});

  @override
  State<LessonColorPage> createState() => _LessonColorPageState();
}

class _LessonColorPageState extends State<LessonColorPage> {
  Color SelectedColor1 = Colors.white;
  Color SelectedColor2 = Colors.white;
  Color? MixedColor;
  int alpha = 255;

  //色1か色2が選ばれたときに設定
  bool select1 = true;
  bool select2 = false;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    double fontsize_big = screenSize.width / 64;
    double fontsize = screenSize.width / 74.6;
    final audioProvider = Provider.of<AudioProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    bool ismixed = false;

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
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                      Text(
                        languageProvider.locallanguage == 2
                            ? "Color Blender"
                            : 'カラーブレンド',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontsize,
                        ),
                      ),
                      Text(
                        languageProvider.locallanguage == 2
                            ? "Let's settig 2 colors on the palette🎨"
                            : languageProvider.isHiragana
                                ? 'パレットのよこにある2つのいろをせっていしてね🎨'
                                : 'パレットの横にある2つの色を選んでね🎨',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontsize,
                        ),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(mainAxisSize: MainAxisSize.min, children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            languageProvider.locallanguage == 2
                                                ? "Color 1"
                                                : languageProvider.isHiragana
                                                    ? 'いろ1'
                                                    : '色1',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: fontsize,
                                            ),
                                          ),
                                          _MixedSelectedColorCircle(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  20,
                                              1,
                                              setState),
                                        ]),
                                    Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            languageProvider.locallanguage == 2
                                                ? "Color 2"
                                                : languageProvider.isHiragana
                                                    ? 'いろ2'
                                                    : '色2',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: fontsize,
                                            ),
                                          ),
                                          _MixedSelectedColorCircle(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  20,
                                              2,
                                              setState),
                                        ]),
                                  ]),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          audioProvider.playSound("tap1.mp3");
                                          _mixColors(); //色を混ぜるための関数
                                        });

                                        ismixed = true; //色を混ぜた場合のフラグ
                                      },
                                      style: TextButton.styleFrom(
                                        backgroundColor:
                                            Color.fromARGB(255, 255, 67, 195),
                                      ),
                                      child: Text(
                                        languageProvider.locallanguage == 2
                                            ? "Blend"
                                            : languageProvider.isHiragana
                                                ? 'いろをまぜる'
                                                : '色を混ぜる',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: fontsize,
                                            color: Colors.white),
                                      ),
                                    ),
                                    //色を混ぜた時に表示
                                    //以下のボタンは
                                    if (ismixed == true) ...[
                                      SizedBox(width: 10),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            audioProvider.playSound("tap1.mp3");

                                            ismixed = false;
                                          });
                                        },
                                        style: TextButton.styleFrom(
                                          backgroundColor:
                                              Color.fromARGB(255, 0, 204, 255),
                                        ),
                                        child: Text(
                                          languageProvider.locallanguage == 2
                                              ? "Try again"
                                              : languageProvider.isHiragana
                                                  ? 'やりなおす'
                                                  : 'やり直す',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: fontsize,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ]
                                  ]),
                              if (ismixed == true) ...[
                                Text(
                                  languageProvider.locallanguage == 2
                                      ? "Blended color"
                                      : languageProvider.isHiragana
                                          ? 'まぜたいろ'
                                          : '混ぜた色',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: fontsize,
                                  ),
                                ),
                                //混ぜた色を追加
                                Container(
                                  width: MediaQuery.of(context).size.width / 20,
                                  height:
                                      MediaQuery.of(context).size.width / 20,
                                  decoration: BoxDecoration(
                                    color: MixedColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: 1,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ]),
                            Column(mainAxisSize: MainAxisSize.min, children: [
                              Text(
                                languageProvider.locallanguage == 2
                                    ? "Palette"
                                    : 'パレット',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: fontsize,
                                    color: Colors.black),
                              ),
                              //色を混ぜる用のパレット
                              _buildMixedColorPicker(
                                  MediaQuery.of(context).size.width / 20,
                                  select1,
                                  select2,
                                  setState),
                            ]),
                            //Flutterのelementの影響でモーダルを閉じた後、パレットに即時新たな色が表示されないので以下の文言を追加
                            Text(
                              languageProvider.locallanguage == 2
                                  ? "If you blend colors, let's tap 'OK'!\n Next, if you select colors, \nblended color appears🎨\nYou can make 6 colors😊"
                                  : languageProvider.isHiragana
                                      ? 'いろをまぜたら\n「これでOK」をおして、\nパレットのいろをえらんだら\nまぜたいろがでてくるよ🎨\n6しょくつくれるよ😊'
                                      : '色を混ぜたら\n「これでOK」を押して、\nパレットの色を選んだら\n混ぜた色が出てくるよ🎨\n6色作れるよ😊',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: fontsize,
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
                        ],
                      )
                    ])))));
  }

  void _mixColors() {
    // RGB の値を取得
    int r1 = SelectedColor1.red;
    int g1 = SelectedColor1.green;
    int b1 = SelectedColor1.blue;

    int r2 = SelectedColor2.red;
    int g2 = SelectedColor2.green;
    int b2 = SelectedColor2.blue;

    // RGB の加重平均
    int mixedR = ((r1 + r2) / 2).round();
    int mixedG = ((g1 + g2) / 2).round();
    int mixedB = ((b1 + b2) / 2).round();

    // 新しい色を作成
    MixedColor = Color.fromARGB(alpha, mixedR, mixedG, mixedB);
  }

  //混ぜた色を設定するためのパレット
  Widget _buildMixedColorPicker(
      double size, bool select1, bool select2, Function setState) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MixedColorCircle(Color.fromARGB(255, 244, 67, 54), size, select1,
                  select2, setState),
              _MixedColorCircle(Color.fromARGB(255, 255, 152, 0), size, select1,
                  select2, setState),
              _MixedColorCircle(Color.fromARGB(255, 248, 181, 0), size, select1,
                  select2, setState),
            ],
          ),
          SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MixedColorCircle(Color.fromARGB(255, 255, 235, 59), size,
                  select1, select2, setState),
              _MixedColorCircle(Color.fromARGB(255, 139, 195, 74), size,
                  select1, select2, setState),
              _MixedColorCircle(Color.fromARGB(255, 76, 175, 80), size, select1,
                  select2, setState),
            ],
          ),
          SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MixedColorCircle(Color.fromARGB(255, 3, 169, 244), size, select1,
                  select2, setState),
              _MixedColorCircle(Color.fromARGB(255, 0, 30, 255), size, select1,
                  select2, setState),
              _MixedColorCircle(Color.fromARGB(255, 156, 39, 176), size,
                  select1, select2, setState),
            ],
          ),
          SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MixedColorCircle(Color.fromARGB(255, 255, 130, 171), size,
                  select1, select2, setState),
              _MixedColorCircle(Color.fromARGB(255, 254, 220, 189), size,
                  select1, select2, setState),
              _MixedColorCircle(Color.fromARGB(255, 255, 255, 255), size,
                  select1, select2, setState),
            ],
          ),
          SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MixedColorCircle(Color.fromARGB(255, 125, 125, 125), size,
                  select1, select2, setState),
              _MixedColorCircle(Color.fromARGB(255, 0, 0, 0), size, select1,
                  select2, setState),
              _MixedColorCircle(Color.fromARGB(255, 121, 85, 72), size, select1,
                  select2, setState),
            ],
          ),
          SizedBox(height: 3),
        ],
      ),
    );
  }

  //色1,2で混ぜた色を設定する。
  Widget _MixedColorCircle(
      Color color, double size, bool select1, bool select2, Function setState) {
    final audioProvider = Provider.of<AudioProvider>(context);
    return GestureDetector(
      onTap: () {
        setState(() {
          audioProvider.playSound("tap1.mp3");
          if (select1 == true) {
            SelectedColor1 = color; // 色を更新
          } else if (select2 == true) {
            SelectedColor2 = color; // 色を更新
          }
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.0),
        width: size,
        height: size,
        decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              width: (select1 && SelectedColor1 == color) ||
                      (select2 && SelectedColor2 == color)
                  ? 3
                  : 1,
              color: (select1 && SelectedColor1 == color) ||
                      (select2 && SelectedColor2 == color)
                  ? Colors.black
                  : Colors.grey,
            )),
      ),
    );
  }

  Widget _MixedSelectedColorCircle(double size, int selectnum, setState) {
    final audioProvider = Provider.of<AudioProvider>(context);
    //色1,2のコンポーネントを合わせるために選択された色を設定する変数を使用
    Color? selectedColor = (selectnum == 1) ? SelectedColor1 : SelectedColor2;
    return GestureDetector(
      onTap: () {
        setState(() {
          audioProvider.playSound("tap1.mp3");
          if (selectnum == 1) {
            select1 = true;
            select2 = false;
          } else if (selectnum == 2) {
            select1 = false;
            select2 = true;
          }
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.0),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: selectedColor,
          shape: BoxShape.circle,
          border: Border.all(
            width: (selectnum == 1 && select1) || (selectnum == 2 && select2)
                ? 3
                : 1,
            color: (selectnum == 1 && select1) || (selectnum == 2 && select2)
                ? Colors.black
                : Colors.grey,
          ),
        ),
      ),
    );
  }
}
