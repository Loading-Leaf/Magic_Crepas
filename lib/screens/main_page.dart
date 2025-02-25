import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import "package:ai_art/artproject/terms_of_service.dart";
import 'package:audioplayers/audioplayers.dart';
import 'package:ai_art/artproject/audio_provider.dart';
import 'package:ai_art/artproject/effect_utils.dart';
import 'package:ai_art/artproject/language_provider.dart';

//import 'package:google_mobile_ads/google_mobile_ads.dart'; // Import the necessary package
//import 'package:ai_art/artproject/ad_helper.dart'; // Import the AdHelper for Banner Ad

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  /*
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    // Initialize the banner ad
    _bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: AdHelper.bannerAdUnitId,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          setState(() {
            _isBannerAdReady = false;
          });
          ad.dispose();
        },
      ),
      request: const AdRequest(),
    );
    _bannerAd.load();
  }

  @override
  void dispose() {
    super.dispose();
    _bannerAd.dispose();
  }*/

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
                              child: Image.asset('assets/title_logo_main.png'),
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
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(1.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        languageProvider.locallanguage == 2
                            ? "AI generates a new art with pictures and drawings🪄"
                            : languageProvider.isHiragana
                                ? 'AIがえとしゃしんであたらしいアートをつくってくれるよ🪄'
                                : 'AIが絵と写真で新しいアートを作ってくれるよ🪄',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontsize_big,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(3.0),
                            child: Container(
                              height: screenSize.width * 0.15, // 縦長の場合
                              width: screenSize.width * 0.6, // 縦長の場合

                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: Image.asset('assets/title_image.png'),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                                    languageProvider.locallanguage == 2
                                        ? "Generate Arts"
                                        : languageProvider.isHiragana
                                            ? 'AIでアートをつくる'
                                            : 'AIでアートを作る',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: fontsize,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Container(
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
                              SizedBox(height: 5),
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
                            ],
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.all(3.0),
                        child: Text(
                          languageProvider.isHiragana
                              ? 'すきなものとアートをあわせると？？？'
                              : '好きなものとアートを組み合わせると？？？',
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
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(width: screenSize.height * 0.1),
                            Container(
                              child: TextButton(
                                onPressed: () {
                                  audioProvider.playSound("tap1.mp3");
                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        TermsOfServiceDialog(),
                                  );
                                },
                                child: Text(
                                  '利用規約',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: fontsize,
                                    color:
                                        const Color.fromARGB(255, 255, 67, 195),
                                  ),
                                ),
                              ),
                            ),
                            // Display the banner ad next to the buttons
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
                                    color:
                                        const Color.fromARGB(255, 255, 67, 195),
                                  ),
                                ),
                              ),
                            ),
                            /*
                          if (_isBannerAdReady)
                            Container(
                              alignment: Alignment.center,
                              width: _bannerAd.size.width.toDouble(),
                              height: _bannerAd.size.height.toDouble(),
                              child: AdWidget(ad: _bannerAd),
                            ),*/
                          ],
                        ),
                        SizedBox(height: screenSize.height * 0.05),
                      ],
                    ),
                  ),
                ),
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
            languageProvider.isHiragana ? 'せってい' : '設定',
            style:
                TextStyle(fontWeight: FontWeight.bold, fontSize: fontsize_big),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  languageProvider.isHiragana ? 'おんりょうボタン' : '音量ボタン',
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
                        languageProvider.isHiragana ? 'おとなし🔈' : '音なし🔈',
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
                        languageProvider.isHiragana ? 'おとあり🔊' : '音あり🔊',
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
                languageProvider.isHiragana ? 'とじる' : '閉じる',
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
