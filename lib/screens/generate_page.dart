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

class GeneratePage extends StatefulWidget {
  const GeneratePage({super.key});

  @override
  _GeneratePageState createState() => _GeneratePageState();
}

class _GeneratePageState extends State<GeneratePage> {
  List<Map<String, dynamic>> _images = []; // ここで _images を定義
  late Database _database; // late修飾子を使用
  File? image;
  bool isresult_exist = false;
  @override
  List<int>? drawingImageData;
  bool showGenerateButton = false; // 絵ができたよボタンの表示制御用
  Uint8List? resultbytes2;
  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);

      // ここで描画データを設定する
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
          drawingImageData =
              List<int>.from(drawings.last['drawing']); // 描画データを取得
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
  }

  void _showDialog(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    showDialog<void>(
      context: context,
      barrierDismissible: false, // (追加)ユーザーがモーダルを閉じないようにする
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('絵ができるまでまってね'),
                Text('楽しいまちがいさがしゲームで遊んでね'),
                SizedBox(height: 20),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Container(
                      height: screenSize.height * 0.50,
                      width: screenSize.height * 0.50,
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Image.asset('assets/difference/original/1.png'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Container(
                      height: screenSize.height * 0.50,
                      width: screenSize.height * 0.50,
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Image.asset('assets/difference/joke/1.png'),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        if (isresult_exist == true) {
                          Navigator.pushNamed(context, '/output',
                              arguments: resultbytes2);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('まだできてないよー')),
                          );
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 255, 67, 195),
                      ),
                      child: Text(
                        '完成した絵を見る',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ),
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

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
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
                        Text("選んだ写真"),
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Container(
                            // 画面のサイズに基づいて縮小したサイズで表示
                            height: 150,
                            width: 200,
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: image != null || _images.isNotEmpty
                                  ? Image.file(image ??
                                      File(_images[_images.length - 1]
                                          ['path'])) // 選択された画像またはDBから取得した画像を表示
                                  : Image.asset(
                                      'assets/style.jpg'), // どちらもない場合はデフォルト画像を表示
                            ),
                          ),
                        ),
                      ],
                    ),
                    // 2つ目の画像
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text("お絵描きした絵"),
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Container(
                            // 画面のサイズに基づいて縮小したサイズで表示
                            height: 150,
                            width: 150,
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: drawingImageData != null
                                  ? Image.memory(Uint8List.fromList(
                                      drawingImageData!)) // SQLiteから取得した描画データを表示
                                  : Image.asset(
                                      'assets/content.jpg'), // それ以外はデフォルト画像を表示
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
                                Navigator.pushNamed(context, '/drawing');
                              },
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(255, 255, 67, 195),
                              ),
                              child: Text(
                                'お絵描きをする',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                pickImage();
                              },
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(255, 255, 67, 195),
                              ),
                              child: Text(
                                '写真を選ぶ',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ])
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
                  Container(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () async {
                        if (image == null || drawingImageData == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('写真と絵を選択してね')),
                          );
                          return; // 早期リターン
                        }
                        List<int> photoBytes = image!.readAsBytesSync();
                        //base64にエンコード
                        String base64Image = base64Encode(photoBytes);
                        String base64Drawing =
                            base64Encode(Uint8List.fromList(drawingImageData!));
                        String body = json.encode({
                          'post_photo': base64Image,
                          'post_drawing': base64Drawing,
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
                          final data = json.decode(response.body);
                          String resultimageBase64 = data['result'];

                          // バイトのリストに変換
                          Uint8List resultbytes =
                              base64Decode(resultimageBase64);
                          // バイトから画像を生成
                          if (resultbytes.isNotEmpty) {
                            isresult_exist = true;
                            resultbytes2 = resultbytes;
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
                        'アートを作る',
                        style: TextStyle(color: Colors.white),
                      ),
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
