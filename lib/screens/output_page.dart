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

import 'package:ai_art/artproject/gallery_database_helper.dart';
import 'package:intl/intl.dart';

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
  Uint8List outputImage = Uint8List(0);
  Uint8List drawingImageData = Uint8List(0);
  File? image;
  int typeValue = 1;
  String? wifiName;
  bool isresult_exist = false;
  String outputimage_title = "";
  int? emotion_num;
  String? your_emotions;
  List<String> emotions = [
    "うれしい",
    "たのしい",
    "おもしろい",
    "きもちいい",
    "しあわせ",
    "なつかしい",
    "ほっとする",
    "わくわくする",
    "かんどうする",
    "つかれた",
    "むかつく",
    "かなしい",
    "くやしい",
    "こわい",
    "さびしい"
  ];
  String Detail_emotion = "";

  Uint8List? resultbytes2;
  List<int>? photoBytes;
  int? is_photo_flag;

  String formattedDate = "";

  String getFormattedDate() {
    DateTime now = DateTime.now();
    return DateFormat('yyyy/M/d HH:mm').format(now);
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

  void _savemodal(BuildContext context, AudioProvider audioProvider) {
    Size screenSize = MediaQuery.sizeOf(context);
    double fontsize_big = screenSize.width / 64;
    double fontsize = screenSize.width / 74.6;
    int screen_num = 1;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(
                'プロジェクトを保存',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: fontsize_big),
              ),
              content: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (screen_num == 1) ...[
                      Text(
                        "作品タイトルを入力して",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: fontsize),
                      ),
                      TextField(
                        onChanged: (value) {
                          outputimage_title = value;
                        },
                        style: TextStyle(fontSize: fontsize),
                        decoration: InputDecoration(
                          labelText: '作品名', // ラベル
                          labelStyle: TextStyle(fontSize: fontsize),
                        ),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text("作った絵だよ！",
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
                                        _showImageModal(
                                            context,
                                            AssetImage(
                                                'assets/output_style.png'));
                                      }
                                    },
                                    child: Container(
                                      height: (screenSize.width ~/ 6.948)
                                          .toDouble(),
                                      width: (screenSize.width ~/ 5.208)
                                          .toDouble(),
                                      child: FittedBox(
                                        fit: BoxFit.fill,
                                        child: outputImage != null
                                            ? Image.memory(
                                                outputImage!) // 画像を表示
                                            : Image.asset(
                                                'assets/output_style.png'), // デフォルト画像
                                      ),
                                    ),
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
                                  child: GestureDetector(
                                    onTap: () {
                                      if (drawingImageData != null) {
                                        // 画像が存在する場合、タップしてモーダルを表示
                                        _showImageModal(context,
                                            MemoryImage(drawingImageData!));
                                      } else {
                                        // デフォルト画像の場合
                                        _showImageModal(context,
                                            AssetImage('assets/content.png'));
                                      }
                                    },
                                    child: Container(
                                      height: (screenSize.width ~/ 6.948)
                                          .toDouble(),
                                      width: (screenSize.width ~/ 5.208)
                                          .toDouble(),
                                      child: FittedBox(
                                        fit: BoxFit.fill,
                                        child: drawingImageData != null
                                            ? Image.memory(
                                                drawingImageData!) // 画像を表示
                                            : Image.asset(
                                                'assets/content.png'), // デフォルト画像
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ]),
                    ] else if (screen_num == 2) ...[
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5, // 5列
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 8.0,
                              childAspectRatio: 2, // ボタンの横幅を調整
                            ),
                            itemCount: emotions.length,
                            itemBuilder: (context, index) {
                              bool isSelected = emotion_num == index;

                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isSelected
                                      ? Color.fromARGB(255, 255, 67, 195)
                                      : Colors.white,
                                  foregroundColor:
                                      isSelected ? Colors.white : Colors.black,
                                  side: BorderSide(
                                      color: Color.fromARGB(255, 255, 67, 195),
                                      width: 1.5),
                                ),
                                onPressed: () {
                                  setState(() {
                                    emotion_num = index;
                                    your_emotions = emotions[index];
                                  });
                                },
                                child: Text(
                                  emotions[index],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 14),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ] else if (screen_num == 3) ...[
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "さらに感じた気持ちを教えて",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontsize),
                            ),
                            TextField(
                              onChanged: (value) {
                                outputimage_title = value;
                              },
                              style: TextStyle(fontSize: fontsize),
                              decoration: InputDecoration(
                                labelText: 'なにかあったら描いてね～', // ラベル
                                labelStyle: TextStyle(fontSize: fontsize),
                              ),
                            ),
                          ]),
                    ],
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      TextButton(
                        onPressed: () {
                          audioProvider.playSound("tap1.mp3");
                          if (screen_num == 1) {
                            Navigator.pop(context);
                          } else {
                            screen_num -= 1;
                          }
                          ;
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 255, 67, 195),
                        ),
                        child: Text(
                          '戻る',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: fontsize,
                              color: Colors.white),
                        ),
                      ),
                      SizedBox(width: 20),
                      TextButton(
                        onPressed: () async {
                          if (screen_num == 3) {
                            if (outputImage == false) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Cannot save project: Missing image data')),
                              );
                              return;
                            }
                            formattedDate = getFormattedDate();
                            saveToGalleryDB();
                            Navigator.pop(context);
                            audioProvider.playSound("established.mp3");
                          } else if (screen_num == 1 &&
                              outputimage_title.length != 0) {
                            screen_num += 1;
                            audioProvider.playSound("tap1.mp3");
                          } else if (screen_num == 2 && emotion_num != null) {
                            screen_num += 1;
                            audioProvider.playSound("tap1.mp3");
                          }
                          ;
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 255, 67, 195),
                        ),
                        child: Text(
                          '進む',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: fontsize,
                              color: Colors.white),
                        ),
                      ),
                    ]),
                  ]));
        });
  }

  void _showmodesDialog(BuildContext context, AudioProvider audioProvider) {
    Size screenSize = MediaQuery.sizeOf(context);
    double fontsize_big = screenSize.width / 64;
    double fontsize = screenSize.width / 74.6;
    List<String> buttonLabels = ['モードA', 'モードB', 'モードC', 'モードD'];
    List<int> photoTypes = [1, 2, 3, 4];

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
                    Column(
                      children: List.generate(buttonLabels.length, (index) {
                        return Column(
                          children: [
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
                                backgroundColor:
                                    Color.fromARGB(255, 255, 67, 195),
                              ),
                              child: Text(
                                buttonLabels[index],
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存に成功しました')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存に失敗しました')),
        );
      }
    } catch (e) {
      print('Error saving to gallery DB: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('エラーが発生しました: $e')),
      );
    }
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
                          child: GestureDetector(
                            onTap: () {
                              if (drawingImageData != null) {
                                // 画像が存在する場合、タップしてモーダルを表示
                                _showImageModal(
                                    context, MemoryImage(drawingImageData!));
                              } else {
                                // デフォルト画像の場合
                                _showImageModal(
                                    context, AssetImage('assets/content.png'));
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
                    SizedBox(width: 20),
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
                    SizedBox(width: 20),
                    Container(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () async {
                          audioProvider.playSound("tap1.mp3");
                          if (outputImage == false) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Cannot save project: Missing image data')),
                            );
                            return;
                          }

                          _savemodal(context, audioProvider);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 255, 67, 195),
                        ),
                        child: Text(
                          'プロジェクトを保存する',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: fontsize,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ]),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
