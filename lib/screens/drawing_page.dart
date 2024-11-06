import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import "package:ai_art/artproject/drawing_database_helper.dart";

import 'dart:io'; // File クラスを使うためのインポート
import 'package:sqflite/sqflite.dart';

class DrawingPage extends StatefulWidget {
  const DrawingPage({super.key});

  @override
  _DrawingPageState createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  List<Line> _lines = []; // 描画する線のリスト
  Color _selectedColor = Colors.black; // 選択された色
  double _strokeWidth = 5.0; // 線の太さ
  List<Offset?> _currentLinePoints = []; // 現在の線の点
  GlobalKey _globalKey = GlobalKey(); // RepaintBoundary用のキー
  late Database _database; // late修飾子を使用

  @override
  void initState() {
    super.initState();
    _initializeDatabase(); // データベースの初期化を呼び出す
  }

  Future<void> _initializeDatabase() async {
    try {
      _database = await DrawingDatabaseHelper.instance.database; // データベースを初期化
    } catch (e) {
      print('Error initializing database: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // 描画エリア
                Expanded(
                  child: Stack(
                    children: [
                      // RepaintBoundaryを追加
                      RepaintBoundary(
                        key: _globalKey, // スクリーンショットを取るためのキー
                        child: Container(
                          color: Colors.white,
                          child: GestureDetector(
                            onPanUpdate: (details) {
                              setState(() {
                                final RenderBox renderBox =
                                    context.findRenderObject() as RenderBox;
                                final localPosition = renderBox
                                    .globalToLocal(details.globalPosition);

                                if (localPosition.dx >= 0 &&
                                    localPosition.dx <=
                                        renderBox.size.width - 148 &&
                                    localPosition.dy >= 0 &&
                                    localPosition.dy <=
                                        renderBox.size.height - 80) {
                                  _currentLinePoints.add(localPosition);
                                }
                              });
                            },
                            onPanEnd: (details) {
                              setState(() {
                                _lines.add(Line(_currentLinePoints,
                                    _selectedColor, _strokeWidth));
                                _currentLinePoints = [];
                              });
                            },
                            child: CustomPaint(
                              size: Size(MediaQuery.of(context).size.width,
                                  MediaQuery.of(context).size.height * 0.8),
                              painter: DrawingPainter(_lines, _strokeWidth),
                            ),
                          ),
                        ),
                      ),
                      if (_currentLinePoints.isNotEmpty)
                        CustomPaint(
                          painter: DrawingPainter([
                            Line(_currentLinePoints, _selectedColor,
                                _strokeWidth)
                          ], _strokeWidth),
                        ),
                    ],
                  ),
                ),
                Column(children: [
                  // 色選択用のウィジェット
                  _buildColorPicker(),
                  _buildStrokePicker(),
                ]),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/generate');
                },
                style: TextButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 255, 67, 195),
                ),
                child: Text(
                  '戻る',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(width: 10), // スペースを追加
              TextButton(
                onPressed: () async {
                  await _takeScreenshot();
                  Navigator.pushNamed(context, '/generate');
                },
                style: TextButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 255, 67, 195),
                ),
                child: Text(
                  'アートを生成する',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _initDatabase() async {
    try {
      _database = await openDatabase(
        'genart_database.db',
        version: 2, // バージョンを上げる
        onCreate: (Database db, int version) async {
          await db.execute(
            'CREATE TABLE drawings (id INTEGER PRIMARY KEY AUTOINCREMENT, path TEXT NOT NULL, columnDrawing BLOB NOT NULL)', // BLOB型のカラムを追加
          );
        },
        onUpgrade: (Database db, int oldVersion, int newVersion) async {
          if (oldVersion < 2) {
            await db.execute(
              'ALTER TABLE drawings ADD COLUMN columnDrawing BLOB NOT NULL', // 新しいカラムを追加
            );
          }
        },
      );
    } catch (e) {
      print('Error opening database: $e');
    }
  }

// スクリーンショットを取得するメソッド
  Future<void> _takeScreenshot() async {
    await _initializeDatabase();

    // スクリーンショット取得処理...
    RenderRepaintBoundary boundary =
        _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData != null) {
      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // 画像をデバイスに保存
      final directory = await getApplicationDocumentsDirectory();
      final filename = 'image_${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = path.join(directory.path, filename);
      File file = File(filePath);
      await file.writeAsBytes(pngBytes);

      try {
        await DrawingDatabaseHelper.instance.insertDrawing(pngBytes);
        print('Drawing saved to database');
      } catch (e) {
        print('Error saving drawing: $e');
      }
    }
  }

  // 色を選択するためのウィジェット
  Widget _buildColorPicker() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _colorCircle(Colors.red),
              _colorCircle(Colors.orange),
              _colorCircle(Colors.yellow),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _colorCircle(Colors.lightGreen),
              _colorCircle(Colors.green),
              _colorCircle(Colors.lightBlue),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _colorCircle(Colors.blue),
              _colorCircle(Colors.purple),
              _colorCircle(Colors.pink),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _colorCircle(Colors.white),
              _colorCircle(Colors.black),
              _colorCircle(Colors.brown),
            ],
          ),
        ],
      ),
    );
  }

  // 色選択用のボタン
  Widget _colorCircle(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color; // 色を更新
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.0),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            width: _selectedColor == color ? 3 : 1,
            color: _selectedColor == color ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }

  // 太さを選択するためのウィジェット
  Widget _buildStrokePicker() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _strokeCircle(5.0),
              _strokeCircle(6.0),
              _strokeCircle(7.0),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _strokeCircle(8.0),
              _strokeCircle(9.0),
              _strokeCircle(10.0),
            ],
          ),
        ],
      ),
    );
  }

  // 色選択用のボタン
  // 太さを選択するためのウィジェット
  Widget _strokeCircle(double strokesize) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _strokeWidth = strokesize; // 太さを更新
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.0),
        width: 36, // 幅を36pxに設定
        height: 36, // 高さを36pxに設定
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          shape: BoxShape.rectangle, // 矩形の形状に変更
        ),
        child: Center(
          child: Container(
            width: strokesize,
            height: strokesize,
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
              border: Border.all(
                width: _strokeWidth == strokesize ? 3 : 1,
                color: _strokeWidth == strokesize ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 線を表現するクラス
class Line {
  List<Offset?> points;
  Color color;
  double strokeWidth; // Add strokeWidth property

  Line(this.points, this.color, this.strokeWidth);
}

// カスタムペインタークラス
class DrawingPainter extends CustomPainter {
  final List<Line> lines;
  final double strokeWidth;

  DrawingPainter(this.lines, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    for (Line line in lines) {
      Paint paint = Paint()
        ..color = line.color
        ..strokeCap = StrokeCap.round
        ..strokeWidth = line.strokeWidth;

      for (int i = 0; i < line.points.length - 1; i++) {
        if (line.points[i] != null && line.points[i + 1] != null) {
          canvas.drawLine(line.points[i]!, line.points[i + 1]!, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
