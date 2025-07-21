import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import "package:ai_art/artproject/terms_of_service.dart";
import 'package:ai_art/artproject/audio_provider.dart';
import 'package:ai_art/artproject/effect_utils.dart';
import 'package:ai_art/artproject/language_provider.dart';
import 'package:ai_art/artproject/device_provider.dart';

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
    final deviceProvider = Provider.of<DeviceProvider>(context);

    return PopScope(
      // ここを追加
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
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
                      Padding(
                        padding: EdgeInsets.all(3.0),
                        child: Container(
                          height: screenSize.width * 0.225, // 縦長の場合
                          width: screenSize.width * 0.9, // 縦長の場合

                          child: FittedBox(
                            fit: BoxFit.fill,
                            child: Image.asset('assets/title_image.png'),
                          ),
                        ),
                      ),
                      Text(
                        languageProvider.locallanguage == 2
                            ? "Tap to Start"
                            : 'タップしてスタート',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: fontsize,
                            color: Colors.black),
                      ),
                      // Text(deviceProvider.deviceNumber.toString(),
                      //     style: TextStyle(
                      //         fontWeight: FontWeight.bold,
                      //         fontSize: fontsize,
                      //         color: Colors.black)), //デバイス確認用
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
                                  languageProvider.locallanguage == 2
                                      ? "Terms of Service"
                                      : languageProvider.isHiragana
                                          ? 'りようきやく'
                                          : '利用規約',
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
                                  languageProvider.locallanguage == 2
                                      ? "Contact form"
                                      : languageProvider.isHiragana
                                          ? 'おといあわせ'
                                          : 'お問い合わせ',
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
}
