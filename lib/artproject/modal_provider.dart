import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_art/artproject/audio_provider.dart';
import 'package:ai_art/artproject/language_provider.dart';

//写真選択
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // File クラスを使うためのインポート
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import "package:ai_art/artproject/drawing_database_helper.dart";
import "package:ai_art/artproject/drawing_gallery_database_helper.dart";
import 'dart:typed_data';
import 'dart:ui' as ui;

class WifiDisconnectDialog extends StatelessWidget {
  const WifiDisconnectDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // 利用規約の内容（例）
    final audioProvider = Provider.of<AudioProvider>(context);

    Size screenSize = MediaQuery.sizeOf(context);
    double fontsize_big = screenSize.width / 64;
    double fontsize = screenSize.width / 74.6;
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    return AlertDialog(
      title: Text(
        languageProvider.locallanguage == 2
            ? "Failed to generate due to wifi error😭"
            : languageProvider.isHiragana
                ? 'wifiがきれてえのさくせいしっぱいしたよ😭'
                : 'wifiがきれて絵の作成失敗したよ😭',
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: fontsize,
            color: Colors.black),
      ),
      content: Text(""),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            audioProvider.playSound("tap1.mp3");
            Navigator.pushNamed(context, '/');
          },
          style: TextButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 255, 67, 195),
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
                  color: Colors.white)),
        ),
      ],
    );
  }
}

class SomethingDisconnectDialog extends StatefulWidget {
  final String message1;
  final String message2;
  final String message3;

  const SomethingDisconnectDialog({
    super.key,
    required this.message1,
    required this.message2,
    required this.message3,
  });

  @override
  _SomethingDisconnectDialogState createState() =>
      _SomethingDisconnectDialogState();
}

class _SomethingDisconnectDialogState extends State<SomethingDisconnectDialog> {
  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    Size screenSize = MediaQuery.sizeOf(context);
    double fontsize = screenSize.width / 74.6;

    return AlertDialog(
      title: Text(
        languageProvider.locallanguage == 2
            ? widget.message3
            : languageProvider.isHiragana
                ? widget.message1
                : widget.message2,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: fontsize,
            color: Colors.black),
      ),
      content: const SizedBox.shrink(),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            audioProvider.playSound("tap1.mp3");
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 255, 67, 195),
          ),
          child: Text(
              languageProvider.locallanguage == 2
                  ? "Close"
                  : languageProvider.isHiragana
                      ? 'とじる'
                      : '閉じる',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: fontsize,
                  color: Colors.white)),
        ),
      ],
    );
  }
}

//お絵描きするためのモード
class DrawingmodeDialog extends StatefulWidget {
  final String message1;
  final String message2;
  final String message3;

  const DrawingmodeDialog({
    super.key,
    required this.message1,
    required this.message2,
    required this.message3,
  });

  @override
  _DrawingmodeDialogState createState() => _DrawingmodeDialogState();
}

class _DrawingmodeDialogState extends State<DrawingmodeDialog> {
  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    Size screenSize = MediaQuery.sizeOf(context);
    double fontsize = screenSize.width / 74.6;
    double tile_size = screenSize.height * 0.4;

    return AlertDialog(
      title: Text(
        languageProvider.locallanguage == 2
            ? widget.message3
            : languageProvider.isHiragana
                ? widget.message1
                : widget.message2,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: fontsize,
            color: Colors.black),
      ),
      content: const SizedBox.shrink(),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            audioProvider.playSound("tap1.mp3");
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 255, 67, 195),
          ),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          //ここに画面遷移などのイベントを書く。
                          audioProvider.playSound("tap1.mp3");
                          Navigator.pushNamed(context, '/drawing');
                        },
                        child: Padding(
                          padding: EdgeInsets.all(3.0),
                          child: Container(
                            height: tile_size, // 縦長の場合
                            width: tile_size, // 縦長の場合
                            color: Colors.grey,
                            child: FittedBox(
                              fit: BoxFit.fill,
                              // child: Image.asset('assets/title_image.png'),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          //ここに画面遷移などのイベントを書く。
                          audioProvider.playSound("tap1.mp3");
                          Navigator.pushNamed(context, '/drawing');
                        },
                        child: Padding(
                          padding: EdgeInsets.all(3.0),
                          child: Container(
                            height: tile_size, // 縦長の場合
                            width: tile_size, // 縦長の場合
                            color: Colors.grey,
                            child: FittedBox(
                              fit: BoxFit.fill,
                              // child: Image.asset('assets/title_image.png'),
                            ),
                          ),
                        ),
                      ),
                      //ギャラリー
                      GestureDetector(
                        onTap: () {
                          //ここに画面遷移などのイベントを書く。
                          audioProvider.playSound("tap1.mp3");
                          Navigator.pushNamed(context, '/drawing');
                        },
                        child: Padding(
                          padding: EdgeInsets.all(3.0),
                          child: Container(
                            height: tile_size, // 縦長の場合
                            width: tile_size, // 縦長の場合
                            color: Colors.grey,
                            child: FittedBox(
                              fit: BoxFit.fill,
                              // child: Image.asset('assets/title_image.png'),
                            ),
                          ),
                        ),
                      ),
                    ]),
                Text(
                    languageProvider.locallanguage == 2
                        ? "Close"
                        : languageProvider.isHiragana
                            ? 'とじる'
                            : '閉じる',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontsize,
                        color: Colors.white)),
              ]),
        ),
      ],
    );
  }
}

//お絵描きするためのモード
class DrawingselectDialog extends StatefulWidget {
  final String message1;
  final String message2;
  final String message3;

  const DrawingselectDialog({
    super.key,
    required this.message1,
    required this.message2,
    required this.message3,
  });

  @override
  _DrawingselectDialogState createState() => _DrawingselectDialogState();
}

class _DrawingselectDialogState extends State<DrawingselectDialog> {
  late Database _database; // late修飾子を使用
  File? image;

  Future<void> _initializeDatabase() async {
    try {
      _database = await DrawingDatabaseHelper.instance.database; // データベースを初期化
    } catch (e) {
      print('Error initializing database: $e');
    }
  }

  late Future<List<Map<String, dynamic>>> _drawingsFuture;

  @override
  void initState() {
    super.initState();
    _drawingsFuture = DrawingGalleryDatabaseHelper.instance.fetchDrawings();
  }

  _DrawingSelectDialog() {
    Size screenSize = MediaQuery.sizeOf(context);
    double fontsize = screenSize.width / 74.6;
    final audioProvider = Provider.of<AudioProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    double imageWidth = screenSize.width / 6 - 10;
    double imageHeight = imageWidth;

    showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (BuildContext context, setState) {
            return Dialog(
                child: Container(
                    width: screenSize.width * 0.8,
                    height: screenSize.height * 0.9,
                    padding: const EdgeInsets.all(10.0),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(
                        languageProvider.locallanguage == 2
                            ? "Drawings"
                            : '今まで描いた絵',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontsize,
                        ),
                      ),
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: _drawingsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            print(snapshot.data);
                            return Text('Error: ${snapshot.error}');
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Text('まだないよ😢');
                          } else {
                            List<Map<String, dynamic>> drawings =
                                snapshot.data!;
                            return Expanded(
                              child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 5,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                                itemCount: drawings.length,
                                itemBuilder: (context, index) {
                                  final outputImagePath = drawings[index]
                                      ['drawingimage'] as String?;
                                  print(outputImagePath);

                                  if (outputImagePath == null) {
                                    return Container(
                                      color: Colors.grey,
                                      child: const Center(
                                          child: Text("Invalid Image")),
                                    );
                                  }
                                  final outputImageFile = File(outputImagePath);
                                  return GestureDetector(
                                    onTap: () async {
                                      audioProvider.playSound("tap2.mp3");
                                      Uint8List pngBytes =
                                          await outputImageFile.readAsBytes();
                                      await DrawingDatabaseHelper.instance
                                          .insertDrawing(pngBytes, 2);
                                      Navigator.of(context).pop();
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        outputImageFile,
                                        width: imageWidth,
                                        height: imageHeight,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }
                        },
                      ),
                    ])));
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    Size screenSize = MediaQuery.sizeOf(context);
    double fontsize = screenSize.width / 74.6;
    double tile_size = screenSize.height * 0.4;

    return AlertDialog(
        title: Text(
          languageProvider.locallanguage == 2
              ? widget.message3
              : languageProvider.isHiragana
                  ? widget.message1
                  : widget.message2,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontsize,
              color: Colors.black),
        ),
        content: const SizedBox.shrink(),
        actions: <Widget>[
          Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      //お絵描きギャラリーから選ぶ
                      GestureDetector(
                        onTap: () {
                          //ここに画面遷移などのイベントを書く。
                          audioProvider.playSound("tap1.mp3");
                          Navigator.of(context).pop(true);
                          _DrawingSelectDialog();
                        },
                        child: Padding(
                          padding: EdgeInsets.all(3.0),
                          child: Container(
                            height: tile_size, // 縦長の場合
                            width: tile_size, // 縦長の場合
                            color: Colors.grey,
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: Image.asset(
                                  'assets/ButtonImage/menu1_1_1.png'),
                            ),
                          ),
                        ),
                      ),
                      //リアルアートから選ぶ
                      GestureDetector(
                        onTap: () {
                          //ここに画面遷移などのイベントを書く。
                          audioProvider.playSound("tap2.mp3");
                          Navigator.of(context).pop(true); // ←値を返す
                          pickAndProcessImage();
                        },
                        child: Padding(
                          padding: EdgeInsets.all(3.0),
                          child: Container(
                            height: tile_size, // 縦長の場合
                            width: tile_size, // 縦長の場合
                            color: Colors.grey,
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: Image.asset(
                                  'assets/ButtonImage/menu1_1_2.png'),
                            ),
                          ),
                        ),
                      ),
                      //お絵描きをしてから絵を使う
                      GestureDetector(
                        onTap: () {
                          //ここに画面遷移などのイベントを書く。
                          audioProvider.playSound("tap1.mp3");
                          Navigator.of(context).pop(true); // ←値を返す
                          Navigator.pushNamed(context, '/drawing',
                              arguments: {"drawing_mode": 1});
                        },
                        child: Padding(
                          padding: EdgeInsets.all(3.0),
                          child: Container(
                            height: tile_size, // 縦長の場合
                            width: tile_size, // 縦長の場合
                            color: Colors.grey,
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: Image.asset(
                                  'assets/ButtonImage/menu1_1_3.png'),
                            ),
                          ),
                        ),
                      ),
                    ]),
                TextButton(
                  onPressed: () {
                    audioProvider.playSound("tap1.mp3");
                    Navigator.of(context).pop(false); // ←値を返す
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
              ]),
        ]);
  }

  // 画像を処理する関数
  Future<void> pickAndProcessImage() async {
    try {
      // 画像をギャラリーから選択
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final imageFile = File(image.path);

      // ファイルをバイト配列に変換
      Uint8List pngBytes = await imageFile.readAsBytes();

      // デバイスに保存
      final directory = await getApplicationDocumentsDirectory();
      final filename = 'image_${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = path.join(directory.path, filename);
      await File(filePath).writeAsBytes(pngBytes);

      // データベースの初期化と保存
      await _initializeDatabase();

      try {
        await DrawingDatabaseHelper.instance.insertDrawing(pngBytes, 1);
        setState(() {
          _drawingsFuture =
              DrawingGalleryDatabaseHelper.instance.fetchDrawings();
          this.image = imageFile;
        });
        Navigator.pushNamed(context, '/generate');
      } catch (e) {
        print('Error saving drawing: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('データベースへの保存中にエラーが発生しました: $e')),
        );
      }

      // UI更新のための状態管理
      setState(() => this.image = imageFile);
    } catch (e) {
      print('Error processing image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('画像の処理中にエラーが発生しました: $e')),
      );
    }
  }
}
