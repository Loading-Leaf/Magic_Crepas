import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:provider/provider.dart'; // Provider のインポート
import 'package:ai_art/artproject/audio_provider.dart'; // AudioProvider のインポート
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ai_art/artproject/effect_utils.dart';

class OutputPage extends StatefulWidget {
  const OutputPage({super.key});

  @override
  _OutputPageState createState() => _OutputPageState();
}

class _OutputPageState extends State<OutputPage> {
  Uint8List? outputImage;
  Uint8List? drawingImageData;

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
    final audioProvider = Provider.of<AudioProvider>(context);
    if (outputImage == null) return;

    final result = await ImageGallerySaver.saveImage(
      outputImage!,
      quality: 100,
      name: 'output_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    final snackBar = SnackBar(
      content: Text(result['isSuccess'] ? '作った絵を保存しました！' : '作った絵の保存に失敗しました'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    audioProvider.playSound("established.mp3");
  }

  Future<void> saveDrawing() async {
    final audioProvider = Provider.of<AudioProvider>(context);
    if (drawingImageData == null) return;

    final result = await ImageGallerySaver.saveImage(
      drawingImageData!,
      quality: 100,
      name: 'drawing_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    final snackBar = SnackBar(
      content: Text(result['isSuccess'] ? '絵を保存しました！' : '絵の保存に失敗しました'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    audioProvider.playSound("established.mp3");
  }

  Future<void> shareImages(Uint8List image1, Uint8List image2) async {
    // ファイルを保存するディレクトリを取得
    final directory = await getApplicationDocumentsDirectory();

    // ファイルパスの指定
    final outputImagePath =
        '${directory.path}/output_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final drawingImagePath =
        '${directory.path}/drawing_image_${DateTime.now().millisecondsSinceEpoch}.jpg';

    // 画像データをファイルに書き込み
    File(outputImagePath)..writeAsBytesSync(image1);
    File(drawingImagePath)..writeAsBytesSync(image2);

    // ファイルをシェア
    await Share.shareXFiles(
      [
        XFile(outputImagePath),
        XFile(drawingImagePath),
      ],
      text: '写真とお絵描きからこんな絵ができたよ！\n#まじっくくれぱす #思い出',
    );
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
                            height: (screenSize.height ~/ 2.74).toDouble(),
                            width: (screenSize.height ~/ 2.055).toDouble(),
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
                            height: (screenSize.height ~/ 2.74).toDouble(),
                            width: (screenSize.height ~/ 2.055).toDouble(),
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
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
