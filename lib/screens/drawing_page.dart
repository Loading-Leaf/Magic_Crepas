import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import "package:ai_art/artproject/drawing_database_helper.dart";
import 'package:image_picker/image_picker.dart';

import 'dart:io'; // File クラスを使うためのインポート
import 'package:sqflite/sqflite.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import 'package:ai_art/artproject/audio_provider.dart';
import 'package:ai_art/artproject/effect_utils.dart';
import 'dart:async';

import 'dart:math' as math;

class DrawingPage extends StatefulWidget {
  const DrawingPage({super.key});

  @override
  _DrawingPageState createState() => _DrawingPageState();
}

// スプレーポイントを表現するクラスを追加
class SprayPoints {
  List<Offset> points;
  Color color;
  double density; // スプレーの密度

  SprayPoints(this.points, this.color, this.density);
}

class _DrawingPageState extends State<DrawingPage> {
  List<Line> _undoneLines = []; // undoされた線を保持するリスト
  List<Line> _lines = []; // 描画する線のリスト
  List<SprayPoints> _undoneSprayPoints = []; // スプレーのundo用配列
  List<SprayPoints> _sprayPoints = []; // スプレーのundo用配列
  Color _selectedColor = Colors.black; // 選択された色
  bool _isSprayMode = false; // スプレーモードのフラグ
  double _sprayDensity = 20.0; // スプレーの密度

  double _strokeWidth = 5.0; // 線の太さ
  File? image;
  List<Offset?> _currentLinePoints = []; // 現在の線の点
  List<Offset> _currentSprayPoints = []; // 現在のスプレーの点

  GlobalKey _globalKey = GlobalKey(); // RepaintBoundary用のキー
  late Database _database; // late修飾子を使用
  final audioPlayer = AudioPlayer();
  bool isDrawing = false; // 描画中かどうかをトラックするフラグ
  // タイマーを追加
  Timer? _sprayTimer;

  @override
  void initState() {
    super.initState();
    _initializeDatabase(); // データベースの初期化を呼び出す
  }

  @override
  void dispose() {
    _sprayTimer?.cancel();
    super.dispose();
  }

  void _undo() {
    setState(() {
      if (_lines.isNotEmpty || _sprayPoints.isNotEmpty) {
        if (_lines.isNotEmpty &&
            (_sprayPoints.isEmpty ||
                _lines.last.points.last!.dy >
                    _sprayPoints.last.points.last.dy)) {
          _undoneLines.add(_lines.removeLast());
        } else if (_sprayPoints.isNotEmpty) {
          _undoneSprayPoints.add(_sprayPoints.removeLast());
        }
      }
    });
  }

  void _redo() {
    setState(() {
      if (_undoneLines.isNotEmpty || _undoneSprayPoints.isNotEmpty) {
        if (_undoneLines.isNotEmpty &&
            (_undoneSprayPoints.isEmpty ||
                _undoneLines.last.points.last!.dy >
                    _undoneSprayPoints.last.points.last.dy)) {
          _lines.add(_undoneLines.removeLast());
        } else if (_undoneSprayPoints.isNotEmpty) {
          _sprayPoints.add(_undoneSprayPoints.removeLast());
        }
      }
    });
  }

  void _addSprayPoints(Offset center) {
    final random = math.Random();
    final points = <Offset>[];

    for (int i = 0; i < _sprayDensity; i++) {
      final radius = _strokeWidth * random.nextDouble();
      final angle = 2 * math.pi * random.nextDouble();
      final dx = radius * math.cos(angle);
      final dy = radius * math.sin(angle);
      points.add(Offset(center.dx + dx, center.dy + dy));
    }

    _currentSprayPoints.addAll(points);
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
                              onPanStart: (details) {
                                if (_isSprayMode) {
                                  _sprayTimer = Timer.periodic(
                                      Duration(milliseconds: 50), (_) {
                                    setState(() {
                                      final RenderBox renderBox = context
                                          .findRenderObject() as RenderBox;
                                      final localPosition =
                                          renderBox.globalToLocal(
                                              details.globalPosition);
                                      _addSprayPoints(localPosition);
                                    });
                                  });
                                }
                              },
                              onPanUpdate: (details) {
                                setState(() {
                                  if (!isDrawing) {
                                    audioProvider.playSound("drawing.mp3");
                                    isDrawing = true;
                                  }

                                  if (_isSprayMode) {
                                    final RenderBox renderBox =
                                        context.findRenderObject() as RenderBox;
                                    final localPosition = renderBox
                                        .globalToLocal(details.globalPosition);
                                    _addSprayPoints(localPosition);
                                  } else {
                                    final RenderBox renderBox =
                                        context.findRenderObject() as RenderBox;
                                    final localPosition = renderBox
                                        .globalToLocal(details.globalPosition);
                                    // 左側の余白を考慮して座標補正
                                    final padding_left =
                                        MediaQuery.of(context).size.width * 0.1;
                                    final padding_top =
                                        MediaQuery.of(context).size.height *
                                            0.1;
                                    final correctedPosition = Offset(
                                      localPosition.dx - padding_left,
                                      localPosition.dy - padding_top - 20,
                                    );

                                    if (correctedPosition.dx >= -20 &&
                                        correctedPosition.dx <=
                                            renderBox.size.width -
                                                MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.4 +
                                                20 &&
                                        correctedPosition.dy >= -20 &&
                                        correctedPosition.dy <=
                                            renderBox.size.height -
                                                MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.4 +
                                                20) {
                                      _currentLinePoints.add(correctedPosition);
                                    }
                                  }
                                });
                              },
                              onPanEnd: (details) {
                                setState(() {
                                  if (_isSprayMode &&
                                      _currentSprayPoints.isNotEmpty) {
                                    _sprayPoints.add(SprayPoints(
                                        List.from(_currentSprayPoints),
                                        _selectedColor,
                                        _sprayDensity));
                                    _currentSprayPoints.clear();
                                  } else {
                                    audioProvider.pauseAudio();
                                    isDrawing = false;
                                    _lines.add(Line(_currentLinePoints,
                                        _selectedColor, _strokeWidth));
                                    _currentLinePoints = [];
                                  }
                                  _undoneLines.clear();
                                  _undoneSprayPoints.clear();
                                });
                              },
                              child: CustomPaint(
                                size: Size(
                                    MediaQuery.of(context).size.width * 0.6,
                                    MediaQuery.of(context).size.height * 0.6),
                                painter: DrawingPainter(
                                  _lines,
                                  _currentLinePoints,
                                  _sprayPoints,
                                  _currentSprayPoints,
                                  _strokeWidth,
                                  _selectedColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (_currentLinePoints.isNotEmpty)
                          CustomPaint(
                            painter: DrawingPainter(
                              [],
                              _currentLinePoints,
                              _sprayPoints,
                              _currentSprayPoints,
                              _strokeWidth,
                              _selectedColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(children: [
                    SizedBox(height: screenSize.height * 0.01),
                    // 色選択用のウィジェット
                    Padding(
                      padding: EdgeInsets.all(3.0),
                      child: Text('パレット',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: fontsize)),
                    ),
                    _buildColorPicker(MediaQuery.of(context).size.height / 13),
                    Padding(
                      padding: EdgeInsets.all(3.0),
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
                          iconSize: MediaQuery.of(context).size.height / 17,
                        ),
                        IconButton(
                          icon: Icon(Icons.redo),
                          onPressed: _undoneLines.isNotEmpty ? _redo : null,
                          tooltip: 'Redo',
                          splashColor: Color.fromARGB(255, 255, 67, 195),
                          iconSize: MediaQuery.of(context).size.height / 17,
                        ),
                        IconButton(
                          icon: Icon(_isSprayMode ? Icons.brush : Icons.brush),
                          onPressed: () {
                            setState(() {
                              _isSprayMode = !_isSprayMode;
                            });
                          },
                          tooltip: _isSprayMode ? 'Brush Mode' : 'Spray Mode',
                          splashColor: Color.fromARGB(255, 255, 67, 195),
                          iconSize: MediaQuery.of(context).size.height / 17,
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
                    '閉じる',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontsize,
                        color: Colors.white),
                  ),
                ),

                SizedBox(width: 10), // スペースを追加
                TextButton(
                  onPressed: () async {
                    audioProvider.playSound("tap2.mp3");
                    pickAndProcessImage();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 255, 67, 195),
                  ),
                  child: Text(
                    '写真から選ぶ',
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
            SizedBox(height: 20), // スペースを追加
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

// 画像を処理する関数
  // 画像を処理する関数を改良
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
        await DrawingDatabaseHelper.instance.insertDrawing(pngBytes);
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
// CustomPainterの修正
class DrawingPainter extends CustomPainter {
  final List<Line> lines;
  final List<Offset?> currentLinePoints;
  final List<SprayPoints> sprayPoints;
  final List<Offset> currentSprayPoints;
  final double strokeWidth;
  final Color lineColor;

  DrawingPainter(
    this.lines,
    this.currentLinePoints,
    this.sprayPoints,
    this.currentSprayPoints,
    this.strokeWidth,
    this.lineColor,
  );

  @override
  void paint(Canvas canvas, Size size) {
    // 通常の線を描画
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

    // スプレーポイントを描画
    for (SprayPoints spray in sprayPoints) {
      Paint paint = Paint()
        ..color = spray.color
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 1.0;

      for (Offset point in spray.points) {
        canvas.drawCircle(point, 1.0, paint);
      }
    }

    // 現在のスプレーポイントを描画
    if (currentSprayPoints.isNotEmpty) {
      Paint paint = Paint()
        ..color = lineColor
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 1.0;

      for (Offset point in currentSprayPoints) {
        canvas.drawCircle(point, 1.0, paint);
      }
    }

    // 現在の線を描画
    if (currentLinePoints.isNotEmpty) {
      Paint paint = Paint()
        ..color = lineColor
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
