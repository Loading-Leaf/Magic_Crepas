import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import "package:ai_art/artproject/database_helper.dart";
import "package:ai_art/artproject/drawing_database_helper.dart";
import 'dart:typed_data';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:wifi_info_flutter/wifi_info_flutter.dart';
import 'dart:math' as math;
import 'package:ai_art/artproject/language_provider.dart';

import 'package:provider/provider.dart';
import 'package:ai_art/artproject/audio_provider.dart';
import 'package:ai_art/artproject/effect_utils.dart';
import 'package:ai_art/artproject/modal_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'dart:async'; // Timer を利用するために追加

int randomIntWithRange(int min, int max) {
  int value = math.Random().nextInt(max - min);
  return value + min;
}

class GeneratePage extends StatefulWidget {
  const GeneratePage({super.key});

  @override
  _GeneratePageState createState() => _GeneratePageState();
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

class _GeneratePageState extends State<GeneratePage> {
  List<Map<String, dynamic>> _images = []; // ここで _images を定義
  late Database _database; // late修飾子を使用
  File? image;
  bool isresult_exist = false; // 結果が存在するかどうかのフラグ→まちがいさがしで画面遷移と答えが見れるか判断するため
  @override
  List<int>? drawingImageData;
  int? is_photo_flag;
  bool showGenerateButton = false; // 絵ができたよボタンの表示制御用
  Uint8List? resultbytes2;

  String? wifiName; // Wi-Fi名を保存する変数
  int typeValue = 1;
  bool isipad = false;

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

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);

      // 描画データの設定（仮データ）
      String drawingData = 'your_drawing_data_here'; // 適切な描画データを設定

      await DatabaseHelper.instance.insert({
        'selectedphoto': Uint8List(0),
        'photo': image.path,
        'drawing': drawingData // 描画データを渡す
      });
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future<void> checkDevice() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      setState(() {
        if (iosInfo.model.toLowerCase().contains("ipad")) {
          isipad = true;
        }
      });
    }
  }

  Future<void> loadImages() async {
    try {
      final photos = await DatabaseHelper.instance.fetchDrawings();
      if (photos.isEmpty) {
        print('No drawings found');
        return;
      }
      //print(drawings);
      setState(() {
        // データがnullの場合のチェックを追加
        _images = photos.map((drawing) {
          String path = drawing['photo'] ?? ''; // nullの場合は空文字
          Uint8List drawingData =
              drawing['selectedphoto'] ?? Uint8List(0); // nullの場合は空のUint8List
          return {'path': path, 'selectedphoto': drawingData};
        }).toList();
      });
      print(_images[_images.length - 1]);

      // 最後に保存した描画データをセット
      if (_images.isNotEmpty) {
        drawingImageData = _images.last['drawing']; // 最後の画像を使用
        setState(() {
          image = File(_images[_images.length - 1]['path']);
          if (_images.length > 1) {
            DatabaseHelper.instance.clearNonIdColumns(_images.length);
          }
        });
      }

      //print(_images.length);
      //print(_images);
    } catch (e) {
      print('Error loading images: $e');
    }
  }

  Future<void> loadDrawings() async {
    try {
      final drawings = await DrawingDatabaseHelper.instance.fetchDrawings();
      if (drawings.isEmpty) {
        print('No drawings found');
        return;
      }

      setState(() {
        if (drawings.isNotEmpty) {
          is_photo_flag = drawings.last["is_photo_flag"];
          drawingImageData =
              List<int>.from(drawings.last['drawing']); // 描画データを取得
          if (drawings.length > 1) {
            DrawingDatabaseHelper.instance.clearNonIdColumns(drawings.length);
          }
        }
      });
    } catch (e) {
      print('Error loading drawings: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeDatabase(); // データベースの初期化を呼び出す
    loadImages(); // 初期化時に画像を読み込む
    loadDrawings(); // 描画データを読み込む
    _getWifiName();
    _startResultCheckTimer();
    checkDevice();
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
          title: Text(languageProvider.isHiragana ? 'えができたよ😄' : '絵ができたよ😄',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(
              languageProvider.isHiragana
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
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('ちょっとまってね💦',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontsize_big,
              )),
          content: Text('まだできてないよ💦',
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
    double fontsize = screenSize.width / 74.6;
    String random_num = randomIntWithRange(1, 13).toString();
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    int is_answer = 1;
    List<Circle> _circles = []; // 円を保持するリスト
    List<List<Circle>> _undoStack = [];
    List<List<Circle>> _redoStack = [];

    String machigaicount = "";
    int machigaitotal = 0;
    if (int.parse(random_num) < 7) {
      machigaicount = "3";
      machigaitotal = 3;
    } else if (int.parse(random_num) >= 7) {
      machigaicount = "5";
      machigaitotal = 5;
    }

    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

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
                      languageProvider.isHiragana
                          ? 'えができるまでたのしいまちがいさがしであそんでね✨'
                          : '絵ができるまで楽しいまちがいさがしで遊んでね✨',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontsize,
                      ),
                    ),
                    Text(
                      languageProvider.isHiragana
                          ? 'まちがいは' + machigaicount + 'つあるよ～'
                          : 'まちがいは' + machigaicount + 'つあるよ～',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontsize,
                      ),
                    ),
                    Text(
                      languageProvider.isHiragana
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
                                      ? languageProvider.isHiragana
                                          ? 'こたえをみる'
                                          : '答えを見る'
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
                                  languageProvider.isHiragana
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

  Future<void> _initializeDatabase() async {
    try {
      _database = await DatabaseHelper.instance.database; // データベースを初期化
    } catch (e) {
      print('Error initializing database: $e');
    }
  }

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
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'モードについて',
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
          ),
        );
      },
    );
  }

  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    double fontsize = screenSize.width / 74.6;
    final audioProvider = Provider.of<AudioProvider>(context);
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 1つ目の画像
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                                languageProvider.isHiragana
                                    ? "えらんだしゃしん"
                                    : "選んだ写真",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: fontsize)),
                            //Text(_images.length.toString()), //結局格納すらできていない
                            Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Container(
                                // 画面のサイズに基づいて縮小したサイズで表示
                                height: (screenSize.width ~/ 5.79).toDouble(),
                                width: (screenSize.width ~/ 4.34).toDouble(),
                                child: FittedBox(
                                  fit: BoxFit.fill,
                                  child: image != null
                                      ? Image.file(image ??
                                          File(_images[_images.length - 1][
                                              'path'])) // 選択された画像またはDBから取得した画像を表示
                                      : Image.asset(
                                          'assets/style.png'), // どちらもない場合はデフォルト画像を表示
                                ),
                              ),
                            ),
                          ],
                        ),
                        // 2つ目の画像
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                                languageProvider.isHiragana
                                    ? "おえかきしたえ"
                                    : "お絵描きした絵",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: fontsize)),
                            Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Container(
                                // 画面のサイズに基づいて縮小したサイズで表示
                                height: (screenSize.width ~/ 5.79).toDouble(),
                                width: (screenSize.width ~/ 5.79).toDouble(),
                                child: FittedBox(
                                  fit: BoxFit.fill,
                                  child: drawingImageData != null
                                      ? Image.memory(Uint8List.fromList(
                                          drawingImageData!)) // SQLiteから取得した描画データを表示
                                      : Image.asset(
                                          'assets/content.png'), // それ以外はデフォルト画像を表示
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    audioProvider.playSound("tap1.mp3");
                                    Navigator.pushNamed(context, '/drawing');
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor:
                                        Color.fromARGB(255, 255, 67, 195),
                                  ),
                                  child: Text(
                                    languageProvider.isHiragana
                                        ? 'おえかきをする'
                                        : 'お絵描きをする',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: fontsize,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Container(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    audioProvider.playSound("tap2.mp3");
                                    pickImage();
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor:
                                        Color.fromARGB(255, 255, 67, 195),
                                  ),
                                  child: Text(
                                    languageProvider.isHiragana
                                        ? 'しゃしんをえらぶ'
                                        : '写真を選ぶ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: fontsize,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              typelists(context),
                              SizedBox(height: 5),
                              Container(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    audioProvider.playSound("tap1.mp3");
                                    _showmodesDialog(context, audioProvider);
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor:
                                        Color.fromARGB(255, 255, 67, 195),
                                  ),
                                  child: Text(
                                    'モードについて',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: fontsize,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            ]),
                      ],
                    ),
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
                            languageProvider.isHiragana ? 'ホームにもどる' : 'ホームに戻る',
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
                                ),
                              );

                              return; // 早期リターン
                            }
                            audioProvider.playSound("tap2.mp3");

                            List<int> photoBytes = image!.readAsBytesSync();
                            //base64にエンコード
                            String base64Image = base64Encode(photoBytes);
                            String base64Drawing = base64Encode(
                                Uint8List.fromList(drawingImageData!));
                            print(typeValue);
                            String body = json.encode({
                              'post_photo': base64Image,
                              'post_drawing': base64Drawing,
                              'photo_type': typeValue,
                              'is_photo_flag': is_photo_flag,
                            });
                            Uri url = Uri.parse(
                                'https://imakoh.pythonanywhere.com/generate_arts2');
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
                              is_photo_flag = data["is_photo_flag"];

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
                                  ),
                                );
                              }
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) => WifiDisconnectDialog(),
                              );
                            }
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 255, 67, 195),
                          ),
                          child: Text(
                            languageProvider.isHiragana ? 'アートをつくる' : 'アートを作る',
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
