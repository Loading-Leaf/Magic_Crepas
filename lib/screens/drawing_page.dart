import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import "package:ai_art/artproject/drawing_database_helper.dart";

import 'dart:io'; // File クラスを使うためのインポート
import 'package:sqflite/sqflite.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import 'package:ai_art/artproject/audio_provider.dart';
import 'package:ai_art/artproject/effect_utils.dart';

class DrawingPage extends StatefulWidget {
  const DrawingPage({super.key});

  @override
  _DrawingPageState createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  List<Line> _undoneLines = []; // undoされた線を保持するリスト
  List<Line> _lines = []; // 描画する線のリスト
  Color _selectedColor = Colors.black; // 選択された色
  double _strokeWidth = 5.0; // 線の太さ
  List<Offset?> _currentLinePoints = []; // 現在の線の点
  GlobalKey _globalKey = GlobalKey(); // RepaintBoundary用のキー
  late Database _database; // late修飾子を使用
  final audioPlayer = AudioPlayer();
  bool isDrawing = false; // 描画中かどうかをトラックするフラグ

  @override
  void initState() {
    super.initState();
    _initializeDatabase(); // データベースの初期化を呼び出す
  }

  void _undo() {
    setState(() {
      if (_lines.isNotEmpty) {
        _undoneLines.add(_lines.removeLast());
      }
    });
  }

  void _redo() {
    setState(() {
      if (_undoneLines.isNotEmpty) {
        _lines.add(_undoneLines.removeLast());
      }
    });
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
    Size screenSize = MediaQuery.sizeOf(context);
    double fontsize = 16;
    final audioProvider = Provider.of<AudioProvider>(context);

    return Scaffold(
      body: GestureDetector(
        onTapUp: (details) {
          // タッチされた位置を取得
          Offset tapPosition = details.localPosition;
          // キラキラエフェクトを表示
          showSparkleEffect(context, tapPosition);
        },
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.height * 0.1), // 左辺だけに余白を追加
            ),
            Expanded(
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width *
                            0.1), // 左辺だけに余白を追加
                  ),
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
                                  if (!isDrawing) {
                                    audioProvider.playSound("drawing.mp3");
                                    isDrawing = true;
                                  }

                                  final RenderBox renderBox =
                                      context.findRenderObject() as RenderBox;
                                  final localPosition = renderBox
                                      .globalToLocal(details.globalPosition);
                                  // 左側の余白を考慮して座標補正
                                  final padding_left =
                                      MediaQuery.of(context).size.width * 0.1;
                                  final padding_top =
                                      MediaQuery.of(context).size.height * 0.1;
                                  final correctedPosition = Offset(
                                    localPosition.dx - padding_left,
                                    localPosition.dy - padding_top,
                                  );

                                  if (correctedPosition.dx >= 0 &&
                                      correctedPosition.dx <=
                                          renderBox.size.width -
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.35 &&
                                      correctedPosition.dy >= 0 &&
                                      correctedPosition.dy <=
                                          renderBox.size.height -
                                              MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.35) {
                                    _currentLinePoints.add(correctedPosition);
                                  }
                                });
                              },
                              onPanEnd: (details) {
                                setState(() {
                                  audioProvider.pauseAudio();
                                  isDrawing = false;
                                  _lines.add(Line(_currentLinePoints,
                                      _selectedColor, _strokeWidth));
                                  _currentLinePoints = [];
                                  _undoneLines.clear();
                                });
                              },
                              child: CustomPaint(
                                size: Size(
                                    MediaQuery.of(context).size.width * 0.65,
                                    MediaQuery.of(context).size.height * 0.65),
                                painter: DrawingPainter(
                                    _lines,
                                    _currentLinePoints,
                                    _strokeWidth,
                                    _selectedColor),
                              ),
                            ),
                          ),
                        ),
                        if (_currentLinePoints.isNotEmpty)
                          CustomPaint(
                            painter: DrawingPainter([], _currentLinePoints,
                                _strokeWidth, _selectedColor),
                          ),
                      ],
                    ),
                  ),
                  Column(children: [
                    SizedBox(height: screenSize.height * 0.05),
                    // 色選択用のウィジェット
                    Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Text('パレット',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: fontsize)),
                    ),
                    _buildColorPicker(MediaQuery.of(context).size.height / 13),
                    Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Text('筆の大きさ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: fontsize)),
                    ),
                    _buildStrokePicker(MediaQuery.of(context).size.height / 13),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.undo),
                          onPressed: _lines.isNotEmpty ? _undo : null,
                          tooltip: 'Undo',
                          splashColor: Color.fromARGB(255, 255, 67, 195),
                          iconSize: MediaQuery.of(context).size.height / 13,
                        ),
                        IconButton(
                          icon: Icon(Icons.redo),
                          onPressed: _undoneLines.isNotEmpty ? _redo : null,
                          tooltip: 'Redo',
                          splashColor: Color.fromARGB(255, 255, 67, 195),
                          iconSize: MediaQuery.of(context).size.height / 13,
                        ),
                      ],
                    ),
                  ]),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    audioProvider.playSound("tap1.mp3");
                    Navigator.pushNamed(context, '/generate');
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
                SizedBox(width: 10), // スペースを追加
                TextButton(
                  onPressed: () async {
                    await _takeScreenshot();
                    audioProvider.playSound("tap2.mp3");
                    Navigator.pushNamed(context, '/generate');
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 255, 67, 195),
                  ),
                  child: Text(
                    'できたよ',
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
  Widget _buildColorPicker(double size) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _colorCircle(Colors.red, size),
              _colorCircle(Colors.orange, size),
              _colorCircle(Colors.yellow, size),
            ],
          ),
          SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _colorCircle(Colors.lightGreen, size),
              _colorCircle(Colors.green, size),
              _colorCircle(Colors.lightBlue, size),
            ],
          ),
          SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _colorCircle(Color.fromARGB(255, 0, 30, 255), size),
              _colorCircle(Colors.purple, size),
              _colorCircle(Color.fromARGB(255, 255, 130, 171), size),
            ],
          ),
          SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _colorCircle(Colors.white, size),
              _colorCircle(Colors.black, size),
              _colorCircle(Colors.brown, size),
            ],
          ),
          SizedBox(height: 3),
        ],
      ),
    );
  }

  // 色選択用のボタン
  Widget _colorCircle(Color color, double size) {
    final audioProvider = Provider.of<AudioProvider>(context);
    return GestureDetector(
      onTap: () {
        setState(() {
          audioProvider.playSound("tap1.mp3");
          _selectedColor = color; // 色を更新
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.0),
        width: size,
        height: size,
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
  Widget _buildStrokePicker(double size) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _strokeCircle(3.0, size),
              _strokeCircle(5.0, size),
              _strokeCircle(7.0, size),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _strokeCircle(9.0, size),
              _strokeCircle(11.0, size),
              _strokeCircle(13.0, size),
            ],
          ),
        ],
      ),
    );
  }

  // 色選択用のボタン
  // 太さを選択するためのウィジェット
  Widget _strokeCircle(double strokesize, double size) {
    final audioProvider = Provider.of<AudioProvider>(context);
    return GestureDetector(
      onTap: () {
        setState(() {
          audioProvider.playSound("tap1.mp3");
          _strokeWidth = strokesize; // 太さを更新
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.0),
        width: size, // 幅を36pxに設定
        height: size, // 高さを36pxに設定
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
  final List<Offset?> currentLinePoints; // 新たに追加
  final double strokeWidth;
  final Color lineColor; // 色を追加

  DrawingPainter(
      this.lines, this.currentLinePoints, this.strokeWidth, this.lineColor);

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
    if (currentLinePoints.isNotEmpty) {
      Paint paint = Paint()
        ..color = lineColor // 一時的に黒で描画（動的に変更することも可能）
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth;

      for (int i = 0; i < currentLinePoints.length - 1; i++) {
        if (currentLinePoints[i] != null && currentLinePoints[i + 1] != null) {
          canvas.drawLine(
              currentLinePoints[i]!, currentLinePoints[i + 1]!, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
