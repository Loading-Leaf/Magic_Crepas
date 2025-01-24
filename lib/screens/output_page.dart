import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:provider/provider.dart'; // Provider のインポート
import 'package:ai_art/artproject/audio_provider.dart'; // AudioProvider のインポート
//import 'package:share/share.dart';
import 'package:http/http.dart' as http;
//import 'package:path_provider/path_provider.dart';
import 'package:ai_art/artproject/effect_utils.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart'; // Import the necessary package
//import 'package:ai_art/artproject/ad_helper.dart'; // Import the AdHelper for Banner Ad
import 'package:photo_manager/photo_manager.dart';
import 'package:wifi_info_flutter/wifi_info_flutter.dart';
import 'dart:convert';

import 'dart:math' as math;
import 'dart:async';

int randomIntWithRange(int min, int max) {
  int value = math.Random().nextInt(max - min);
  return value + min;
}

class OutputPage extends StatefulWidget {
  const OutputPage({super.key});

  @override
  _OutputPageState createState() => _OutputPageState();
}

class _OutputPageState extends State<OutputPage> {
  Uint8List? outputImage;
  Uint8List? drawingImageData;
  File? image;
  int typeValue = 1;
  String? wifiName;
  bool isresult_exist = false;

  Uint8List? resultbytes2;
  List<int>? photoBytes;
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

  Future<void> _getWifiName() async {
    try {
      String? wifi = await WifiInfo().getWifiName();
      setState(() {
        wifiName = wifi;
      });
    } on PlatformException catch (e) {
      print('Failed to get Wi-Fi name: $e');
      setState(() {
        wifiName = null; // Wi-Fi名が取得できなかった場合、nullをセット
      });
    }
  }

  // 状態監視を定期的に行うタイマー
  void _startResultCheckTimer() {
    Timer.periodic(Duration(seconds: 5), (timer) async {
      // 結果が準備できているか確認
      if (await _isResultReady()) {
        timer.cancel(); // タイマーを停止
        setState(() {
          isresult_exist = true;
        });
        _showResultDialog(); // 結果ダイアログを表示
      }
    });
  }

  // 結果が準備できているかを判定する関数（仮のロジックを実装）
  Future<bool> _isResultReady() async {
    // サーバーにリクエストを送る場合のコード例
    await Future.delayed(Duration(seconds: 1)); // サーバーリクエストのシミュレーション
    return isresult_exist; // 現在の isresult_exist の値を返す
  }

  // 結果ダイアログを表示する関数
  void _showResultDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('絵ができたよー', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('まちがいさがしの答えも見れるよー',
              style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 255, 67, 195),
              ),
              child: Text(
                'OK',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showWaitDialog() {
    Size screenSize = MediaQuery.sizeOf(context);
    double fontsize_big = screenSize.width / 64;
    double fontsize = screenSize.width / 74.6;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('ちょっとまってね！！！',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontsize_big,
              )),
          content: Text('まだできてないよー',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontsize,
              )),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 255, 67, 195),
              ),
              child: Text(
                'OK',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: fontsize,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDialog(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    double fontsize = screenSize.width / 74.6;
    String random_num = randomIntWithRange(1, 7).toString();
    int is_answer = 1;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return Dialog(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '絵ができるまで楽しいまちがいさがしで遊んでね',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontsize,
                      ),
                    ),
                    Text(
                      'まちがいは3つあるよ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontsize,
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Container(
                            height: screenSize.width * 0.25,
                            width: screenSize.width * 0.25,
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: Image.asset('assets/difference/original/' +
                                  random_num +
                                  '.png'),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Container(
                            height: screenSize.width * 0.25,
                            width: screenSize.width * 0.25,
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: Image.asset('assets/difference/' +
                                  (is_answer == 1 ? 'joke/' : 'answer/') +
                                  random_num +
                                  '.png'),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Container(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  audioProvider.playSound("tap1.mp3");
                                  if (isresult_exist == true) {
                                    setState(() {
                                      is_answer = is_answer == 1 ? 2 : 1;
                                    });
                                  } else {
                                    _showWaitDialog();
                                  }
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      Color.fromARGB(255, 255, 67, 195),
                                ),
                                child: Text(
                                  is_answer == 1 ? '答えを見る' : 'もとの絵を見る',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: fontsize,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  if (isresult_exist == true) {
                                    audioProvider.playSound("established.mp3");
                                    Navigator.pushNamed(
                                      context,
                                      '/output',
                                      arguments: {
                                        'outputImage': resultbytes2,
                                        'drawingImageData': Uint8List.fromList(
                                            drawingImageData!),
                                        'ImageData': photoBytes,
                                      },
                                    );
                                  } else {
                                    audioProvider.playSound("tap1.mp3");
                                    _showWaitDialog();
                                  }
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      Color.fromARGB(255, 255, 67, 195),
                                ),
                                child: Text(
                                  '完成した絵を見る',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: fontsize,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _getWifiName();
    _startResultCheckTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      outputImage = args['outputImage'];
      drawingImageData = args['drawingImageData'];
      image = args["ImageData"];
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

  /*

  Future<void> shareImages(Uint8List image1, Uint8List image2) async {
    final directory = await getApplicationDocumentsDirectory();
    final box = context.findRenderObject() as RenderBox?; // ここで null チェックを行います
    if (box == null) {
      // RenderBoxが取得できない場合はエラーを表示
      final snackBar = SnackBar(content: Text('座標の取得に失敗しました。再試行してください。'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    // 画面上での位置を取得
    Rect rect = box.localToGlobal(Offset.zero) & box.size;

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
        await Share.shareFiles(
          [
            outputImagePath,
            drawingImagePath,
          ],
          text: '写真とお絵描きからこんな絵ができたよ！\n#まじっくくれぱす #思い出',
          sharePositionOrigin: rect, // ここで座標を設定
        );
      } else {
        final snackBar = SnackBar(content: Text('画像の共有に失敗しました。再試行してください。'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      final snackBar = SnackBar(content: Text('画像の共有中にエラーが発生しました: $e'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }*/

  Widget typelists(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);
    double fontsize = screenSize.width / 74.6;
    return DropdownButton(
      items: [
        DropdownMenuItem(
          value: 1,
          child: Text('モードA',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontsize,
              )),
        ),
        DropdownMenuItem(
          value: 2,
          child: Text('モードB',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontsize,
              )),
        ),
        DropdownMenuItem(
          value: 3,
          child: Text('モードC',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontsize,
              )),
        ),
        DropdownMenuItem(
          value: 4,
          child: Text('モードD',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontsize,
              )),
        ),
      ],
      value: typeValue,
      onChanged: (int? value) {
        setState(() {
          typeValue = value!;
        });
      },
    );
  }

  void _showmodesDialog(BuildContext context, AudioProvider audioProvider) {
    Size screenSize = MediaQuery.sizeOf(context);
    double fontsize_big = screenSize.width / 64;
    double fontsize = screenSize.width / 74.6;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            '別のモードを使う',
            style:
                TextStyle(fontWeight: FontWeight.bold, fontSize: fontsize_big),
          ),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(2.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 3),
                  ),
                  height: screenSize.width * 0.235,
                  width: screenSize.width * 0.50,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Image.asset(
                      'assets/modes.png',
                    ),
                  ),
                ),
              ),
              Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    typelists(context),
                    SizedBox(height: 5),
                    TextButton(
                      onPressed: () async {
                        if (wifiName != null) {
                          audioProvider.playSound("tap1.mp3");
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Wi-Fiつながってないよ')),
                          );
                          return; // 早期リターン
                        }
                        audioProvider.playSound("tap2.mp3");
                        List<int> photoBytes = image!.readAsBytesSync();
                        String base64Image = base64Encode(photoBytes);
                        String base64Drawing =
                            base64Encode(Uint8List.fromList(drawingImageData!));
                        String body = json.encode({
                          'post_photo': base64Image,
                          'post_drawing': base64Drawing,
                          'photo_type': typeValue,
                        });
                        Uri url = Uri.parse(
                            'https://imakoh.pythonanywhere.com/generate_arts');
                        //192.168.68.58
                        _showDialog(context);
                        final response = await http.post(
                          url,
                          body: body,
                          headers: {'Content-Type': 'application/json'},
                        );

                        /// base64 -> file
                        if (response.statusCode == 200) {
                          audioProvider.playSound("generated.mp3");
                          final data = json.decode(response.body);
                          String resultimageBase64 = data['result'];

                          // バイトのリストに変換
                          Uint8List resultbytes =
                              base64Decode(resultimageBase64);

                          // バイトから画像を生成
                          if (resultbytes.isNotEmpty) {
                            setState(() {
                              isresult_exist = true;
                              resultbytes2 = resultbytes;
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('作ったアートが空だよ')),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('アート生成に失敗したよ')),
                          );
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 255, 67, 195),
                      ),
                      child: Text(
                        'もう一度試す',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: fontsize,
                            color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 5),
                    TextButton(
                      onPressed: () {
                        audioProvider.playSound("tap1.mp3");
                        Navigator.pop(context);
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
                  ]),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    double fontsize = screenSize.width / 74.6;
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                    Container(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          audioProvider.playSound("tap1.mp3");
                          _showmodesDialog(context, audioProvider);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 255, 67, 195),
                        ),
                        child: Text(
                          '別のモードを使う',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: fontsize,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    /*
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
                    ),*/
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
