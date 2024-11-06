import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class OutputPage extends StatefulWidget {
  const OutputPage({super.key});

  @override
  _OutputPageState createState() => _OutputPageState();
}

class _OutputPageState extends State<OutputPage> {
  Uint8List? outputImage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Uint8List) {
      outputImage = args;
    } else {
      print('No image data passed or incorrect type');
    }
  }

  Future<void> saveImage() async {
    if (outputImage == null) return;

    final result = await ImageGallerySaver.saveImage(
      outputImage!,
      quality: 100,
      name: 'output_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    final snackBar = SnackBar(
      content: Text(result['isSuccess'] ? '画像を保存しました！' : '画像の保存に失敗しました'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("完成した絵だよ！"),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Container(
                        height: 150,
                        width: 200,
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: outputImage != null
                              ? Image.memory(outputImage!) // 画像を表示
                              : Image.asset(
                                  'assets/output_style.png'), // デフォルト画像
                        ),
                      ),
                    ),
                  ],
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/');
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 255, 67, 195),
                      ),
                      child: Text(
                        '戻る',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  TextButton(
                    onPressed: saveImage, // 画像を保存するボタン
                    style: TextButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 255, 67, 195),
                    ),
                    child: Text(
                      '保存する',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ]),
              ],
            );
          },
        ),
      ),
    );
  }
}
