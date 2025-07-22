import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:provider/provider.dart'; // Provider のインポート
import 'package:ai_art/artproject/audio_provider.dart'; // AudioProvider のインポート
import 'package:ai_art/artproject/language_provider.dart';
import 'package:ai_art/artproject/modal_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:ai_art/artproject/effect_utils.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart'; // Import the necessary package
//import 'package:ai_art/artproject/ad_helper.dart'; // Import the AdHelper for Banner Ad
import 'package:photo_manager/photo_manager.dart';
import 'package:wifi_info_flutter/wifi_info_flutter.dart';
import 'dart:convert';

import 'dart:math' as math;
import 'dart:async';

import 'package:ai_art/artproject/gallery_database_helper.dart';
import 'package:intl/intl.dart';

import 'package:share_plus/share_plus.dart';
import 'package:flutter/scheduler.dart';
import 'dart:io' show Platform;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:ai_art/artproject/play_provider.dart';

int randomIntWithRange(int min, int max) {
  int value = math.Random().nextInt(max - min);
  return value + min;
}

class Circle {
  final Offset center;
  final double radius;
  final Color color;

  Circle(this.center, this.radius, this.color);
}

class CirclePainter extends CustomPainter {
  final List<Circle> circles;

  CirclePainter(this.circles);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke // 外枠のみ描画
      ..strokeWidth = 3.0; // 円の外枠の太さ

    for (var circle in circles) {
      paint.color = circle.color;
      canvas.drawCircle(circle.center, circle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class OutputPage extends StatefulWidget {
  const OutputPage({super.key});

  @override
  _OutputPageState createState() => _OutputPageState();
}

class _OutputPageState extends State<OutputPage> {
  Uint8List outputImage = Uint8List(0); //生成した後の画像
  Uint8List drawingImageData = Uint8List(0); //描画した絵
  File? image; //端末の写真アプリで選んだ写真
  String? wifiName; //Wifiが切れた時の処理を施す
  bool isresult_exist = false; //結果があるかないか表示
  String outputimage_title = ""; //ギャラリーの保存する際のタイトル
  int? emotion_num; //以下のemotionsで保存する際に使用する配列番号
  String? your_emotions; //String型として感情を保存する際に使用

  String Detail_emotion = ""; //詳しい気持ち

  Uint8List? resultbytes2;
  List<int>? photoBytes;
  int? is_photo_flag;

  String formattedDate = "";

  String your_platform = ""; //使用している端末
  bool isipad = false; //iPadかどうか
  String getFormattedDate() {
    DateTime now = DateTime.now();
    return DateFormat('yyyy/M/d HH:mm').format(now);
  }

  Future<void> checkDevice() async {
    final deviceInfo = DeviceInfoPlugin();
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    //保存時、それぞれの端末ごとに文言を変更
    //例えばiPhoneの場合は「スマホ」,iPadの場合は「アイパッド」と表示
    //使用する場面は「○○に保存」と記載するボタンで使用
    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      setState(() {
        if (iosInfo.model.toLowerCase().contains("ipad")) {
          your_platform =
              languageProvider.locallanguage == 2 ? "Tablet" : "タブレット";
        } else {
          your_platform = languageProvider.locallanguage == 2 ? "Phone" : "スマホ";
        }
      });
    } else if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      setState(() {
        if (androidInfo.systemFeatures
                .contains("android.hardware.type.television") ||
            androidInfo.systemFeatures
                .contains("android.hardware.type.watch") ||
            androidInfo.systemFeatures
                .contains("android.hardware.type.automotive")) {
          your_platform = languageProvider.locallanguage == 2 ? "Other" : "その他";
        } else if (androidInfo.model.toLowerCase().contains("tablet") ||
            androidInfo.product.toLowerCase().contains("tablet")) {
          your_platform =
              languageProvider.locallanguage == 2 ? "Tablet" : "タブレット";
        } else {
          your_platform = languageProvider.locallanguage == 2 ? "Phone" : "スマホ";
        }
      });
    }
  }

  Future<void> shareImages(BuildContext context, Uint8List image1,
      Uint8List image2, LanguageProvider languageProvider) async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      final outputImagePath =
          '${directory.path}/output_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final drawingImagePath =
          '${directory.path}/drawing_image_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await File(outputImagePath).writeAsBytes(image1);
      await File(drawingImagePath).writeAsBytes(image2);

      final files = <XFile>[XFile(outputImagePath), XFile(drawingImagePath)];

      // UIフレームの描画後にRenderBoxを取得
      SchedulerBinding.instance.addPostFrameCallback((_) {
        final mediaQuery = MediaQuery.of(context);

        //iPadでシェアする際、場所を設定しないとshare_plusが使えなくなる
        //sharePositionOriginで画面の位置を設定しないと右下に表示されて画面上にシェアするUIが表示されない
        //中央に設置する際、画面の3分の1の座標に設置
        Rect sharePositionOrigin = Rect.fromCenter(
          center: Offset(mediaQuery.size.width / 3, mediaQuery.size.height / 3),
          width: 200,
          height: 200,
        );
        Share.shareXFiles(
          files,
          text: languageProvider.locallanguage == 2
              ? "I created this art from photos and drawings!\n#Magic Craypas #Memory"
              : '写真とお絵描きからこんなアートができたよ！\n#まじっくくれぱす #思い出',
          subject: languageProvider.locallanguage == 2
              ? "Generated Art via MagicCraypas\n"
              : 'まじっくくれぱすで作った絵',
          sharePositionOrigin: sharePositionOrigin,
        ).then((_) async {
          // 共有後に一時ファイルを削除
          await File(outputImagePath).delete();
          await File(drawingImagePath).delete();
        });
      });
    } catch (e) {
      final snackBar = SnackBar(
        content: Text('画像の共有中にエラーが発生しました: $e'),
        duration: Duration(seconds: 3),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

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
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    final audioProvider = Provider.of<AudioProvider>(context);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
              languageProvider.locallanguage == 2
                  ? "The art is ready😄"
                  : languageProvider.isHiragana
                      ? 'えができたよ😄'
                      : '絵ができたよ😄',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(
              languageProvider.locallanguage == 2
                  ? "You can see the generated art😊"
                  : languageProvider.isHiragana
                      ? 'まちがいさがしのこたえもみれるよ😊'
                      : 'まちがいさがしの答えも見れるよ😊',
              style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            TextButton(
              onPressed: () {
                audioProvider.playSound("tap1.mp3");
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

    final audioProvider = Provider.of<AudioProvider>(context);
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
              languageProvider.locallanguage == 2
                  ? "Wait a moment💦"
                  : 'ちょっとまってね💦',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontsize_big,
              )),
          content: Text(
              languageProvider.locallanguage == 2
                  ? "It's not ready yet💦"
                  : 'まだできてないよ💦',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontsize,
              )),
          actions: [
            TextButton(
              onPressed: () {
                audioProvider.playSound("tap1.mp3");
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
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    double fontsize = screenSize.width / 74.6;
    String random_num = randomIntWithRange(1, 13).toString();
    int is_answer = 1;
    List<Circle> _circles = []; // 円を保持するリスト
    List<List<Circle>> _undoStack = [];
    List<List<Circle>> _redoStack = [];
    String machigaicount = "";
    int machigaitotal = 0;
    if (int.parse(random_num) < 7) {
      machigaicount = "3";
      machigaitotal = 3;
    } else if ((13 > int.parse(random_num)) && (int.parse(random_num) >= 7)) {
      machigaicount = "5";
      machigaitotal = 5;
    }
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return Dialog(
              child: Container(
                width: screenSize.width * 0.9,
                height: screenSize.height * 0.95,
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      languageProvider.locallanguage == 2
                          ? "Let's have fun playing spot the differences until you complete the picture✨"
                          : languageProvider.isHiragana
                              ? 'えができるまでたのしいまちがいさがしであそんでね✨'
                              : '絵ができるまで楽しいまちがいさがしで遊んでね✨',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontsize,
                      ),
                    ),
                    Text(
                      languageProvider.locallanguage == 2
                          ? "There are $machigaicount differences!"
                          : languageProvider.isHiragana
                              ? 'まちがいは$machigaicountつあるよ～'
                              : 'まちがいは$machigaicountつあるよ～',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontsize,
                      ),
                    ),
                    Text(
                      languageProvider.locallanguage == 2
                          ? "Tap differences in right image👆"
                          : languageProvider.isHiragana
                              ? 'みぎのえのまちがいをみつけたらタッチしてね👆'
                              : '右の絵のまちがいを見つけたらタッチしてね👆',
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
                            height: isipad == true
                                ? screenSize.width * 0.35
                                : screenSize.width * 0.25,
                            width: isipad == true
                                ? screenSize.width * 0.35
                                : screenSize.width * 0.25,
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
                            height: isipad == true
                                ? screenSize.width * 0.35
                                : screenSize.width * 0.25,
                            width: isipad == true
                                ? screenSize.width * 0.35
                                : screenSize.width * 0.25,
                            child: GestureDetector(
                              onTapUp: (details) {
                                if (_circles.length >= machigaitotal) return;

                                setState(() {
                                  double dx = details.localPosition.dx;
                                  double dy = details.localPosition.dy;

                                  _undoStack
                                      .add(List.from(_circles)); // 変更前の状態を保存
                                  _circles.add(Circle(Offset(dx, dy), 10.0,
                                      Colors.red)); // 円を追加
                                  _redoStack.clear(); // redoをクリア
                                });
                              },
                              child: Stack(
                                children: [
                                  Image.asset(
                                    'assets/difference/' +
                                        (is_answer == 1 ? 'joke/' : 'answer/') +
                                        random_num +
                                        '.png',
                                    fit: BoxFit.fill,
                                  ),
                                  CustomPaint(
                                    size: isipad == true
                                        ? Size(screenSize.width * 0.35,
                                            screenSize.width * 0.35)
                                        : Size(screenSize.width * 0.25,
                                            screenSize.width * 0.25),
                                    painter: CirclePainter(_circles), // 円を描画
                                  ),
                                ],
                              ),
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
                                  is_answer == 1
                                      ? languageProvider.locallanguage == 2
                                          ? "Watch answer"
                                          : languageProvider.isHiragana
                                              ? 'こたえをみる'
                                              : '答えを見る'
                                      : languageProvider.locallanguage == 2
                                          ? "Watch original"
                                          : languageProvider.isHiragana
                                              ? 'もとのえをみる'
                                              : 'もとの絵を見る',
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
                                        'ImageData': image,
                                        "is_photo_flag": is_photo_flag,
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
                                  languageProvider.locallanguage == 2
                                      ? "Watch the generated art"
                                      : languageProvider.isHiragana
                                          ? 'かんせいしたえをみる'
                                          : '完成した絵を見る',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: fontsize,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.undo),
                                  onPressed: _circles.isNotEmpty
                                      ? () {
                                          setState(() {
                                            _redoStack.add(List.from(_circles));
                                            _circles = List.from(
                                                _undoStack.removeLast());
                                          });
                                        }
                                      : null,
                                ),
                                IconButton(
                                  icon: Icon(Icons.redo),
                                  onPressed: _redoStack.isNotEmpty
                                      ? () {
                                          setState(() {
                                            _undoStack.add(List.from(_circles));
                                            _circles = List.from(
                                                _redoStack.removeLast());
                                          });
                                        }
                                      : null,
                                ),
                              ],
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
    checkDevice();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      outputImage = args['outputImage'];
      drawingImageData = args['drawingImageData'];
      image = args["ImageData"];
      is_photo_flag = args["is_photo_flag"];
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

      showDialog(
        context: context,
        builder: (context) => SomethingDisconnectDialog(
          message1: result['isSuccess']
              ? 'つくったえをほぞんしたよ😊'
              : 'つくったえのほぞんにしっぱいしたよ😭\nおとうさんとおかあさんにはなして、\nいっしょにせっていをかくにんしてね⚙️',
          message2: result['isSuccess']
              ? '作った絵を保存したよ😊'
              : '作った絵の保存に失敗しました😭\n設定を確認してください⚙️',
          message3: result['isSuccess']
              ? 'Success to save😊'
              : 'Failed to save😭\nPlease check settings⚙️',
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => const SomethingDisconnectDialog(
          message1:
              'しゃしんライブラリへのアクセスができないよ😢\nおとうさんとおかあさんにはなして、\nいっしょにせっていをかくにんしてね⚙️',
          message2: '写真ライブラリへのアクセスが許可されていません😢\n設定を確認してください⚙️',
          message3: 'Failed to access😢\nPlease check settings⚙️',
        ),
      );
      /*
      // 権限が拒否された場合、警告メッセージを表示
      final snackBar = SnackBar(
        content: Text('写真ライブラリへのアクセスが許可されていません。設定を確認してください。'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      */
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

      /*

      final snackBar = SnackBar(
        content:
            Text(result['isSuccess'] ? 'お絵描きした絵を保存しました！' : 'お絵描きした絵の保存に失敗しました'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      */
      showDialog(
        context: context,
        builder: (context) => SomethingDisconnectDialog(
          message1: result['isSuccess']
              ? 'おえかきしたえをほぞんしたよ😊'
              : 'おえかきしたえのほぞんにしっぱいしたよ😭\nおとうさんとおかあさんにはなして、\nいっしょにせっていをかくにんしてね⚙️',
          message2: result['isSuccess']
              ? 'お絵描きした絵を保存したよ😊'
              : 'お絵描きした絵の保存に失敗しました😭\n設定を確認してください⚙️',
          message3: result['isSuccess']
              ? 'Success to save😊'
              : 'Failed to save😭\nPlease check settings⚙️',
        ),
      );
      audioProvider.playSound("established.mp3");
    } else {
      // 権限が拒否された場合、警告メッセージを表示
      showDialog(
        context: context,
        builder: (context) => const SomethingDisconnectDialog(
          message1:
              'しゃしんライブラリへのアクセスができないよ😢\nおとうさんとおかあさんにはなして、\nいっしょにせっていをかくにんしてね⚙️',
          message2: '写真ライブラリへのアクセスが許可されていません😢\n設定を確認してください⚙️',
          message3: 'Failed to access😢\nPlease check settings⚙️',
        ),
      );
    }
  }

  void _showImageModal(BuildContext context, ImageProvider image) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent, // 背景を透明に
          child: InteractiveViewer(
            child: Image(image: image), // ここでタップした画像を表示
          ),
        );
      },
    );
  }

  void _savemodal(BuildContext context, AudioProvider audioProvider,
      LanguageProvider languageProvider) {
    Size screenSize = MediaQuery.sizeOf(context);
    double fontsize_big = screenSize.width / 64;
    double fontsize = screenSize.width / 74.6;
    int screen_num = 0; // 初期値を設定

    //設定した感情
    List<String> emotions = [
      languageProvider.locallanguage == 2 ? "Happy😁" : "うれしい😁",
      languageProvider.locallanguage == 2 ? "Fun😄" : "たのしい😄",
      languageProvider.locallanguage == 2 ? "Interesting😆" : "おもしろい😆",
      languageProvider.locallanguage == 2 ? "Exciting🥰" : "きもちいい🥰",
      languageProvider.locallanguage == 2 ? "Happiness😍" : "しあわせ😍",
      languageProvider.locallanguage == 2 ? "Nostalgic😊" : "なつかしい😊",
      languageProvider.locallanguage == 2 ? "Relieved🙂" : "ほっとする🙂",
      languageProvider.locallanguage == 2 ? "Excited😋" : "わくわくする😋",
      languageProvider.locallanguage == 2 ? "Moved😂" : "かんどうする😂",
      languageProvider.locallanguage == 2 ? "Tired😪" : "つかれた😪",
      languageProvider.locallanguage == 2 ? "Annoyed😠" : "むかつく😠",
      languageProvider.locallanguage == 2 ? "Sad😭" : "かなしい😭",
      languageProvider.locallanguage == 2 ? "Frustrated😢" : "くやしい😢",
      languageProvider.locallanguage == 2 ? "Scared😱" : "こわい😱",
      languageProvider.locallanguage == 2 ? "Lonely😨" : "さびしい😨"
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          // StatefulBuilderを追加
          builder: (context, setState) {
            double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
            bool isKeyboardVisible = keyboardHeight > 0;

            // setStateを提供する
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                width: screenSize.width * 0.8,
                height: screenSize.height * 0.9,
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      languageProvider.locallanguage == 2
                          ? "Save to Gallery"
                          : languageProvider.isHiragana
                              ? 'ギャラリーにほぞん'
                              : 'ギャラリーに保存',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: fontsize_big),
                    ),
                    if (screen_num == 0) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Text(
                                languageProvider.locallanguage == 2
                                    ? "Generated Art"
                                    : languageProvider.isHiragana
                                        ? "つくったえ"
                                        : "作った絵",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: fontsize),
                              ),
                              Padding(
                                padding: EdgeInsets.all(10.0),
                                child: GestureDetector(
                                  onTap: () {
                                    if (outputImage != null) {
                                      _showImageModal(
                                          context, MemoryImage(outputImage!));
                                    } else {
                                      _showImageModal(
                                          context,
                                          AssetImage(
                                              'assets/output_style.png'));
                                    }
                                  },
                                  child: Container(
                                    height:
                                        (screenSize.width ~/ 6.948).toDouble(),
                                    width:
                                        (screenSize.width ~/ 5.208).toDouble(),
                                    child: FittedBox(
                                      fit: BoxFit.fill,
                                      child: outputImage != null
                                          ? Image.memory(outputImage!)
                                          : Image.asset(
                                              'assets/output_style.png'),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: screenSize.width * 0.1),
                          Column(
                            children: [
                              Text(
                                languageProvider.locallanguage == 2
                                    ? "Drawing"
                                    : languageProvider.isHiragana
                                        ? "おえかきしたえ"
                                        : "お絵描きした絵",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: fontsize),
                              ),
                              Padding(
                                padding: EdgeInsets.all(10.0),
                                child: GestureDetector(
                                  onTap: () {
                                    if (drawingImageData != null) {
                                      _showImageModal(context,
                                          MemoryImage(drawingImageData!));
                                    } else {
                                      _showImageModal(context,
                                          AssetImage('assets/content.png'));
                                    }
                                  },
                                  child: Container(
                                    height:
                                        (screenSize.width ~/ 6.948).toDouble(),
                                    width:
                                        (screenSize.width ~/ 5.208).toDouble(),
                                    child: FittedBox(
                                      fit: BoxFit.fill,
                                      child: drawingImageData != null
                                          ? Image.memory(drawingImageData!)
                                          : Image.asset('assets/content.png'),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ] else if (screen_num == 1) ...[
                      TextField(
                        onChanged: (value) {
                          outputimage_title = value;
                        },
                        style: TextStyle(fontSize: fontsize),
                        decoration: InputDecoration(
                          labelText: languageProvider.locallanguage == 2
                              ? "Let’s write the title✍"
                              : languageProvider.isHiragana
                                  ? 'さくひんタイトルをいれてね✍'
                                  : '作品タイトルを入力してね✍',
                          labelStyle: TextStyle(fontSize: fontsize),
                        ),
                        maxLength: 20, // 最大文字数を20に設定
                      ),
                    ] else if (screen_num == 2) ...[
                      Text(
                        languageProvider.locallanguage == 2
                            ? "Let’s choose the emotion when you draw😊"
                            : languageProvider.isHiragana
                                ? 'えをかいたときのきもちをえらんでね😊'
                                : '絵を描いた時の気持ちを選んでね😊',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: fontsize_big),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (rowIndex) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (colIndex) {
                              int index = rowIndex * 5 + colIndex;
                              String emotion = emotions[index];

                              return Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: TextButton(
                                  onPressed: () async {
                                    setState(() {
                                      your_emotions = emotion;
                                      screen_num += 1;
                                      audioProvider.playSound("tap1.mp3");
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: your_emotions == emotion
                                        ? Color.fromARGB(
                                            255, 255, 67, 195) // 選択されたらピンク
                                        : const Color.fromARGB(
                                            255, 199, 198, 198), // 未選択ならグレー

                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                  ),
                                  child: Text(
                                    emotions[index],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: fontsize,
                                      color: your_emotions == emotion
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          );
                        }),
                      )
                    ] else if (screen_num == 3) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextField(
                            onChanged: (value) {
                              setState(() {
                                Detail_emotion = value;
                              });
                            },
                            style: TextStyle(fontSize: fontsize),
                            decoration: InputDecoration(
                              labelText: languageProvider.locallanguage == 2
                                  ? "Let’s write your detail emotion✍"
                                  : languageProvider.isHiragana
                                      ? 'さらにかんじたきもちがあったらかいてね✍'
                                      : 'さらに感じた気持ちがあったら書いてね✍',
                              labelStyle: TextStyle(fontSize: fontsize),
                            ),
                            maxLength: 40,
                          ),
                        ],
                      ),
                    ],
                    if (!isKeyboardVisible) // キーボードが表示されていないときのみ表示
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              audioProvider.playSound("tap1.mp3");
                              if (screen_num == 0) {
                                Navigator.pop(context);
                              } else {
                                setState(() {
                                  // StatefulBuilderのsetStateを使用
                                  screen_num -= 1;
                                });
                              }
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 0, 204, 255),
                            ),
                            child: Text(
                              languageProvider.locallanguage == 2
                                  ? "Back"
                                  : languageProvider.isHiragana
                                      ? 'もどる'
                                      : '戻る',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontsize,
                                  color: Colors.white),
                            ),
                          ),
                          SizedBox(width: 20),
                          TextButton(
                            onPressed: () async {
                              if (screen_num == 3 &&
                                  Detail_emotion.length < 40) {
                                if (outputImage == false) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('保存することができませんでした😭'),
                                    ),
                                  );
                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        SomethingDisconnectDialog(
                                      message1: 'ほぞんすることができませんでした😭',
                                      message2: "保存することができませんでした😭",
                                      message3: "Failed to save😭",
                                    ),
                                  );
                                } else {
                                  formattedDate = getFormattedDate();
                                  saveToGalleryDB();
                                  Navigator.pop(context);
                                  audioProvider.playSound("established.mp3");
                                }
                              } else if (screen_num == 0) {
                                setState(() {
                                  // StatefulBuilderのsetStateを使用
                                  screen_num += 1;
                                });
                                audioProvider.playSound("tap1.mp3");
                              } else if (screen_num == 1 &&
                                  (outputimage_title.length >= 0 ||
                                      outputimage_title.length <= 20)) {
                                setState(() {
                                  // StatefulBuilderのsetStateを使用
                                  screen_num += 1;
                                });
                                audioProvider.playSound("tap1.mp3");
                              } else if (screen_num == 2 &&
                                  your_emotions != null) {
                                setState(() {
                                  // StatefulBuilderのsetStateを使用
                                  screen_num += 1;
                                });
                                audioProvider.playSound("tap1.mp3");
                              }
                            },
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  Color.fromARGB(255, 255, 67, 195),
                            ),
                            child: Text(
                              languageProvider.locallanguage == 2
                                  ? "Next"
                                  : languageProvider.isHiragana
                                      ? 'すすむ'
                                      : '進む',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontsize,
                                  color: Colors.white),
                            ),
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

  void _showmodesDialog(BuildContext context, AudioProvider audioProvider,
      LanguageProvider languageProvider) {
    Size screenSize = MediaQuery.sizeOf(context);
    double fontsize_big = screenSize.width / 64;
    double fontsize = screenSize.width / 74.6;
    List<String> buttonLabels = [
      languageProvider.locallanguage == 2 ? "Mode A" : 'モードA',
      languageProvider.locallanguage == 2 ? "Mode B" : 'モードB',
      languageProvider.locallanguage == 2 ? "Mode C" : 'モードC',
      languageProvider.locallanguage == 2 ? "Mode D" : 'モードD'
    ];
    List<int> photoTypes = [1, 2, 3, 4];
    final playProvider = Provider.of<PlayProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            languageProvider.locallanguage == 2
                ? "Try another mode"
                : languageProvider.isHiragana
                    ? 'べつのモードをつかう'
                    : '別のモードを使う',
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
                      languageProvider.locallanguage == 2
                          ? 'assets/modes_en.png'
                          : 'assets/modes.png',
                    ),
                  ),
                ),
              ),
              Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: List.generate(buttonLabels.length, (index) {
                        return Column(
                          children: [
                            TextButton(
                              onPressed: () async {
                                _getWifiName();
                                if (wifiName != null) {
                                  audioProvider.playSound("tap1.mp3");
                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        const SomethingDisconnectDialog(
                                      message1: 'Wi-Fiがつながっていないよ💦',
                                      message2: 'Wi-Fiがつながっていないよ💦',
                                      message3: "Wi-Fi isn't connected💦",
                                    ),
                                  );
                                  return; // 早期リターン
                                } else if (image == null ||
                                    drawingImageData == null) {
                                  audioProvider.playSound("tap1.mp3");
                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        const SomethingDisconnectDialog(
                                      message1: 'しゃしんとえをえらんでね💦',
                                      message2: '写真と絵を選んでね💦',
                                      message3:
                                          'Let’s select a photo and a drawing💦',
                                    ),
                                  );

                                  return; // 早期リターン
                                }
                                audioProvider.playSound("tap2.mp3");
                                Navigator.pop(context);
                                List<int> photoBytes = image!.readAsBytesSync();
                                String base64Image = base64Encode(photoBytes);
                                String base64Drawing = base64Encode(
                                    Uint8List.fromList(drawingImageData!));
                                String body = json.encode({
                                  'post_photo': base64Image,
                                  'post_drawing': base64Drawing,
                                  'photo_type': photoTypes[index],
                                  'is_photo_flag': is_photo_flag,
                                });
                                Uri url = Uri.parse(
                                    'https://imakoh.pythonanywhere.com/generate_arts2');
                                _showDialog(context);
                                final response = await http.post(
                                  url,
                                  body: body,
                                  headers: {'Content-Type': 'application/json'},
                                );
                                playProvider.generateCount--; // 生成回数をカウント

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
                                    showDialog(
                                      context: context,
                                      builder: (context) =>
                                          const SomethingDisconnectDialog(
                                        message1: 'つくったえがないよ😢',
                                        message2: '作った絵がないよ😢',
                                        message3: 'No generated art😢',
                                      ),
                                    );
                                  }
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        WifiDisconnectDialog(),
                                  );
                                }
                              },
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(255, 255, 67, 195),
                              ),
                              child: Text(
                                buttonLabels[index] + "",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontsize,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                          ],
                        );
                      }),
                    ),
                    TextButton(
                      onPressed: () {
                        audioProvider.playSound("tap1.mp3");
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 0, 204, 255),
                      ),
                      child: Text(
                        languageProvider.locallanguage == 2
                            ? "Back"
                            : languageProvider.isHiragana
                                ? 'とじる'
                                : '閉じる',
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

  Future<void> saveToGalleryDB() async {
    try {
      if (drawingImageData == null || image == null) {
        throw Exception('Required images are not available');
      }

      // photoBytes が null の場合も許容する
      List<int> photoBytes = image!.readAsBytesSync();
      Map<String, dynamic> drawingData = {
        'drawingimage': drawingImageData,
        'photoimage': photoBytes, // null でも可
        'outputimage': outputImage,
        'title': outputimage_title,
        'emotion': your_emotions, // null でも可
        'detailemotion': Detail_emotion,
        'time': formattedDate,
      };

      int result =
          await GalleryDatabaseHelper.instance.insertDrawing(drawingData);

      if (result > 0) {
        showDialog(
          context: context,
          builder: (context) => const SomethingDisconnectDialog(
            message1: 'プロジェクトをほぞんしたよ😄',
            message2: 'プロジェクトを保存したよ😄',
            message3: "Success to save😄",
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => const SomethingDisconnectDialog(
            message1: 'ほぞんにしっぱいしたよ😢おとうさんとおかあさんにはなしてね⚙️',
            message2: '保存に失敗しました😢',
            message3: "Failed to save😢",
          ),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => const SomethingDisconnectDialog(
          message1: 'エラーがはっせいしたよ😭\nお問い合わせformを使ってください。',
          message2: 'エラーが発生しました😭\nお問い合わせformを使ってください。',
          message3: "Error has occurred😭 Please use the contact form.",
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
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
                          Text(
                              languageProvider.locallanguage == 2
                                  ? "Generated art"
                                  : languageProvider.isHiragana
                                      ? "つくったえ"
                                      : "作った絵",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontsize)),
                          Padding(
                            padding: EdgeInsets.all(10.0),
                            child: GestureDetector(
                              onTap: () {
                                if (outputImage != null) {
                                  // 画像が存在する場合、タップしてモーダルを表示
                                  _showImageModal(
                                      context, MemoryImage(outputImage!));
                                } else {
                                  // デフォルト画像の場合
                                  _showImageModal(context,
                                      AssetImage('assets/output_style.png'));
                                }
                              },
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
                          ),
                          TextButton(
                            onPressed: () {
                              saveImage();
                            }, // 画像を保存するボタン
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  Color.fromARGB(255, 255, 67, 195),
                            ),
                            child: Text(
                              languageProvider.locallanguage == 2
                                  ? "Save to $your_platform"
                                  : languageProvider.isHiragana
                                      ? your_platform + 'にほぞんする'
                                      : your_platform + 'に保存する',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontsize,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: screenSize.width * 0.05),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                              languageProvider.locallanguage == 2
                                  ? "Drawing"
                                  : languageProvider.isHiragana
                                      ? "おえかきしたえ"
                                      : "お絵描きした絵",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontsize)),
                          Padding(
                            padding: EdgeInsets.all(10.0),
                            child: GestureDetector(
                              onTap: () {
                                if (drawingImageData != null) {
                                  // 画像が存在する場合、タップしてモーダルを表示
                                  _showImageModal(
                                      context, MemoryImage(drawingImageData!));
                                } else {
                                  // デフォルト画像の場合
                                  _showImageModal(context,
                                      AssetImage('assets/content.png'));
                                }
                              },
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
                          ),
                          TextButton(
                            onPressed: () {
                              saveDrawing();
                            }, // 画像を保存するボタン
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  Color.fromARGB(255, 255, 67, 195),
                            ),
                            child: Text(
                              languageProvider.locallanguage == 2
                                  ? "Save to $your_platform"
                                  : languageProvider.isHiragana
                                      ? your_platform + 'にほぞんする'
                                      : your_platform + 'に保存する',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontsize,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () async {
                                audioProvider.playSound("tap1.mp3");
                                if (outputImage == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Cannot save project: Missing image data')),
                                  );
                                  return;
                                }

                                _savemodal(
                                    context, audioProvider, languageProvider);
                              },
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(255, 255, 67, 195),
                              ),
                              child: Text(
                                languageProvider.locallanguage == 2
                                    ? "Save to Gallery"
                                    : languageProvider.isHiragana
                                        ? 'ギャラリーにほぞんする'
                                        : 'ギャラリーに保存する',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: fontsize,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                audioProvider.playSound("tap1.mp3");
                                _showmodesDialog(
                                    context, audioProvider, languageProvider);
                              },
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(255, 255, 67, 195),
                              ),
                              child: Text(
                                languageProvider.locallanguage == 2
                                    ? "Try another mode"
                                    : languageProvider.isHiragana
                                        ? 'べつのモードをつかう'
                                        : '別のモードを使う',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: fontsize,
                                    color: Colors.white),
                              ),
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
                            backgroundColor: Color.fromARGB(255, 0, 204, 255),
                          ),
                          child: Text(
                            languageProvider.locallanguage == 2
                                ? "Back to Home"
                                : languageProvider.isHiragana
                                    ? 'ホームにもどる'
                                    : 'ホームに戻る',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: fontsize,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      Container(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            audioProvider.playSound("tap1.mp3");
                            if (outputImage != null &&
                                drawingImageData != null) {
                              shareImages(
                                  context,
                                  outputImage!,
                                  drawingImageData!,
                                  languageProvider); // 両方の画像をシェアする
                            }
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 255, 67, 195),
                          ),
                          child: Text(
                            languageProvider.locallanguage == 2
                                ? "Share"
                                : 'シェアする',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: fontsize,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ]),
                    SizedBox(height: 20),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
