import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:provider/provider.dart'; // Provider のインポート
import 'package:ai_art/artproject/audio_provider.dart'; // AudioProvider のインポート
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ai_art/artproject/effect_utils.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart'; // Import the necessary package
//import 'package:ai_art/artproject/ad_helper.dart'; // Import the AdHelper for Banner Ad
import 'package:photo_manager/photo_manager.dart';

class OutputPage extends StatefulWidget {
  const OutputPage({super.key});

  @override
  _OutputPageState createState() => _OutputPageState();
}

class _OutputPageState extends State<OutputPage> {
  Uint8List? outputImage;
  Uint8List? drawingImageData;
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
  }
  */

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      outputImage = args['outputImage'];
      drawingImageData = args['drawingImageData'];
    } else {
      print('No image data passed or incorrect type');
    }
  }

  Future<void> saveImage() async {
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);

    if (outputImage == null) return;

    // 写真ライブラリの権限を確認・リクエスト
    final PermissionState permission =
        await PhotoManager.requestPermissionExtend();
    if (permission.isAuth) {
      // 権限が許可されている場合、画像を保存
      final result = await ImageGallerySaverPlus.saveImage(
        outputImage!,
        quality: 100,
        name: 'output_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final snackBar = SnackBar(
        content: Text(result['isSuccess'] ? '作った絵を保存しました！' : '作った絵の保存に失敗しました'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      audioProvider.playSound("established.mp3");
    } else {
      // 権限が拒否された場合、警告メッセージを表示
      final snackBar = SnackBar(
        content: Text('写真ライブラリへのアクセスが許可されていません。設定を確認してください。'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> saveDrawing() async {
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);

    if (drawingImageData == null) return;

    // 写真ライブラリの権限を確認・リクエスト
    final PermissionState permission =
        await PhotoManager.requestPermissionExtend();
    if (permission.isAuth) {
      // 権限が許可されている場合、画像を保存
      final result = await ImageGallerySaverPlus.saveImage(
        drawingImageData!,
        quality: 100,
        name: 'drawing_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final snackBar = SnackBar(
        content:
            Text(result['isSuccess'] ? 'お絵描きした絵を保存しました！' : 'お絵描きした絵の保存に失敗しました'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      audioProvider.playSound("established.mp3");
    } else {
      // 権限が拒否された場合、警告メッセージを表示
      final snackBar = SnackBar(
        content: Text('写真ライブラリへのアクセスが許可されていません。設定を確認してください。'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> shareImages(Uint8List image1, Uint8List image2) async {
    final directory = await getApplicationDocumentsDirectory();

    final outputImagePath =
        '${directory.path}/output_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final drawingImagePath =
        '${directory.path}/drawing_image_${DateTime.now().millisecondsSinceEpoch}.jpg';

    try {
      // ファイルを保存
      await File(outputImagePath).writeAsBytes(image1);
      await File(drawingImagePath).writeAsBytes(image2);

      // ファイルの存在を確認
      bool outputImageExists = await File(outputImagePath).exists();
      bool drawingImageExists = await File(drawingImagePath).exists();

      if (outputImageExists && drawingImageExists) {
        // シェアボタンの位置を取得
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final position = renderBox.localToGlobal(Offset.zero); // グローバル座標で位置を取得

        await Share.shareXFiles(
          [
            XFile(outputImagePath),
            XFile(drawingImagePath),
          ],
          text: '写真とお絵描きからこんな絵ができたよ！\n#まじっくくれぱす #思い出',
          sharePositionOrigin: position & renderBox.size, // 位置情報を渡す
        );
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$position, $renderBox.size")));
      } else {
        final snackBar = SnackBar(content: Text('画像の共有に失敗しました。再試行してください。'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      final snackBar = SnackBar(content: Text('画像の共有中にエラーが発生しました: $e'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    double fontsize = 14;
    final audioProvider = Provider.of<AudioProvider>(context);
    return Scaffold(
      body: GestureDetector(
        onTapUp: (details) {
          // タッチされた位置を取得
          Offset tapPosition = details.localPosition;
          // キラキラエフェクトを表示
          showSparkleEffect(context, tapPosition);
        },
        child: Center(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text("作った絵だよ！",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: fontsize)),
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Container(
                            height: (screenSize.width ~/ 5.79).toDouble(),
                            width: (screenSize.width ~/ 4.34).toDouble(),
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: outputImage != null
                                  ? Image.memory(outputImage!) // 画像を表示
                                  : Image.asset(
                                      'assets/output_style.png'), // デフォルト画像
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            saveImage();
                          }, // 画像を保存するボタン
                          style: TextButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 255, 67, 195),
                          ),
                          child: Text(
                            '作った絵を保存する',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: fontsize,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: screenSize.width * 0.1),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text("お絵描きした絵だよ！",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: fontsize)),
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Container(
                            height: (screenSize.width ~/ 5.79).toDouble(),
                            width: (screenSize.width ~/ 4.34).toDouble(),
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: drawingImageData != null
                                  ? Image.memory(drawingImageData!) // 画像を表示
                                  : Image.asset(
                                      'assets/content.png'), // デフォルト画像
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            saveDrawing();
                          }, // 画像を保存するボタン
                          style: TextButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 255, 67, 195),
                          ),
                          child: Text(
                            'お絵描きした絵を保存する',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: fontsize,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ]),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          audioProvider.playSound("tap1.mp3");
                          Navigator.pushNamed(context, '/');
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 255, 67, 195),
                        ),
                        child: Text(
                          'ホームに戻る',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: fontsize,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(width: 20), // スペースを追加
                    Container(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          audioProvider.playSound("tap1.mp3");
                          if (outputImage != null && drawingImageData != null) {
                            shareImages(
                                outputImage!, drawingImageData!); // 両方の画像をシェアする
                          }
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 67, 180, 255),
                        ),
                        child: Text(
                          'シェアする',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: fontsize,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ]),
                  /*
                  if (_isBannerAdReady)
                    Container(
                      alignment: Alignment.center,
                      width: _bannerAd.size.width.toDouble(),
                      height: _bannerAd.size.height.toDouble(),
                      child: AdWidget(ad: _bannerAd),
                    ),*/
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
