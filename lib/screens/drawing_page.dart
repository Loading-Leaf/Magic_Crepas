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
import 'package:ai_art/artproject/language_provider.dart';

import 'dart:async';

import 'dart:math' as math;

class DrawingPage extends StatefulWidget {
  const DrawingPage({super.key});

  @override
  _DrawingPageState createState() => _DrawingPageState();
}

// スプレーポイントを表現するクラスを追加

abstract class DrawingItem {
  Color color;
  DrawingItem(this.color);
}

class Line extends DrawingItem {
  List<Offset?> points;
  double strokeWidth;
  int alpha;

  Line(this.points, Color color, this.strokeWidth, {this.alpha = 255})
      : super(color);
}

class SprayPoints extends DrawingItem {
  List<Offset> points;
  double density;

  SprayPoints(this.points, Color color, this.density) : super(color);
}

// 図形の追加
class Circle extends DrawingItem {
  final Offset center;
  final double radius;
  final Color color;

  Circle(this.center, this.radius, this.color) : super(color);
}

class Triangle extends DrawingItem {
  final Offset center;
  final double size;
  final Color color;

  Triangle(this.center, this.size, this.color) : super(color);
}

class Rectangle extends DrawingItem {
  final Offset topLeft;
  final double width;
  final double height;
  final Color color;

  Rectangle(this.topLeft, this.width, this.height, this.color) : super(color);
}

class Heart extends DrawingItem {
  final Offset center;
  final double size;
  final Color color;

  Heart(this.center, this.size, this.color) : super(color);
}

class Star extends DrawingItem {
  final Offset center;
  final double size;
  final Color color;

  Star(this.center, this.size, this.color) : super(color);
}

class Diamond extends DrawingItem {
  final Offset center;
  final double size;
  final Color color;

  Diamond(this.center, this.size, this.color) : super(color);
}

class _DrawingPageState extends State<DrawingPage> {
  List<DrawingItem> _drawItems = []; // DrawingItem型のリスト
  List<DrawingItem> _undoneItems = []; // undoされたアイテムを保持するリスト
  Color _selectedColor = Colors.black; // 選択された色
  Color _selectedpaperColor = Colors.white;
  int edittingmode = 1; // スプレーモードのフラグ
  double _sprayDensity = 100.0; // スプレーの密度
  int isPhoto = 0;
  int selectmode = 1; //1: 色選択, 2: 線の太さおよびペンの選択, 3: スタンプ
  int alpha = 255;

  double _strokeWidth = 5.0; // 線の太さ
  File? image;
  List<Offset?> _currentLinePoints = []; // 現在の線の点
  List<Offset> _currentSprayPoints = []; // 現在のスプレーの点

  Color SelectedColor1 = Colors.black;
  Color SelectedColor2 = Colors.black;
  Color? MixedColor;
  bool select1 = true;
  bool select2 = false;
  List<Color?> _allmixedColor = [];

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
      if (_drawItems.isNotEmpty) {
        _undoneItems.add(_drawItems.removeLast());
      }
    });
  }

  void _redo() {
    setState(() {
      if (_undoneItems.isNotEmpty) {
        _drawItems.add(_undoneItems.removeLast());
      }
    });
  }

  void _addSprayPoints(Offset center, BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.1;
    double height = MediaQuery.of(context).size.height * 0.1;
    final random = math.Random();
    final points = <Offset>[];

    for (int i = 0; i < _sprayDensity; i++) {
      final radius = _strokeWidth * 2 * random.nextDouble();
      final angle = 2 * math.pi * random.nextDouble();
      final dx = radius * math.cos(angle);
      final dy = radius * math.sin(angle);
      points.add(Offset(center.dx + dx - width, center.dy + dy - height));
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

  void _MixColorDialog(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    double fontsize = screenSize.width / 74.6;
    final audioProvider = Provider.of<AudioProvider>(context);
    bool ismixed = false;
    final languageProvider = Provider.of<LanguageProvider>(context);

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return Dialog(
                child: Container(
                    width: screenSize.width * 0.8,
                    height: screenSize.height * 0.9,
                    padding: const EdgeInsets.all(10.0),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(
                        'カラーブレンド🎨',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontsize,
                        ),
                      ),
                      Text(
                        languageProvider.isHiragana
                            ? 'パレットのよこにある2つのいろをせっていしてね🎨'
                            : 'パレットの横にある2つの色を選んでね🎨',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontsize,
                        ),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(mainAxisSize: MainAxisSize.min, children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            languageProvider.isHiragana
                                                ? 'いろ1🖌️'
                                                : '色1🖌️',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: fontsize,
                                            ),
                                          ),
                                          _MixedSelectedColorCircle(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  28,
                                              1,
                                              setState),
                                        ]),
                                    Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            languageProvider.isHiragana
                                                ? 'いろ2🖌️'
                                                : '色2🖌️',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: fontsize,
                                            ),
                                          ),
                                          _MixedSelectedColorCircle(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  28,
                                              2,
                                              setState),
                                        ]),
                                  ]),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          audioProvider.playSound("tap1.mp3");
                                          _mixColors();
                                        });

                                        ismixed = true;
                                      },
                                      style: TextButton.styleFrom(
                                        backgroundColor:
                                            Color.fromARGB(255, 255, 67, 195),
                                      ),
                                      child: Text(
                                        languageProvider.isHiragana
                                            ? 'いろをまぜる🪄'
                                            : '色を混ぜる🪄',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: fontsize,
                                            color: Colors.white),
                                      ),
                                    ),
                                    if (ismixed == true) ...[
                                      SizedBox(width: 10),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            audioProvider.playSound("tap1.mp3");

                                            ismixed = false;
                                          });
                                        },
                                        style: TextButton.styleFrom(
                                          backgroundColor:
                                              Color.fromARGB(255, 0, 204, 255),
                                        ),
                                        child: Text(
                                          languageProvider.isHiragana
                                              ? 'やりなおす🔙'
                                              : 'やり直す🔙',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: fontsize,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ]
                                  ]),
                              if (ismixed == true &&
                                  _allmixedColor.length <= 6) ...[
                                Text(
                                  languageProvider.isHiragana
                                      ? 'まぜたいろ🖌️'
                                      : '混ぜた色🖌️',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: fontsize,
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width / 28,
                                  height:
                                      MediaQuery.of(context).size.width / 28,
                                  decoration: BoxDecoration(
                                    color: MixedColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: 1,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ]),
                            Column(mainAxisSize: MainAxisSize.min, children: [
                              Text(
                                'パレット🎨',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: fontsize,
                                    color: Colors.black),
                              ),
                              _buildMixedColorPicker(
                                  MediaQuery.of(context).size.width / 28,
                                  select1,
                                  select2,
                                  setState),
                            ]),
                            Text(
                              languageProvider.isHiragana
                                  ? 'いろをまぜたら\n「これでOK」をおして、\nパレットのいろをえらんだら\nまぜたいろがでてくるよ🎨\n6しょくつくれるよ😊'
                                  : '色を混ぜたら\n「これでOK」を押して、\nパレットの色を選んだら\n混ぜた色が出てくるよ🎨\n6色作れるよ😊',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: fontsize,
                              ),
                            ),
                          ]),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                audioProvider.playSound("tap1.mp3");
                              },
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(255, 0, 204, 255),
                              ),
                              child: Text(
                                languageProvider.isHiragana ? 'とじる🔙' : '閉じる🔙',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: fontsize,
                                    color: Colors.white),
                              ),
                            ),
                            SizedBox(width: 20),
                            TextButton(
                              onPressed: () {
                                if (ismixed == true) {
                                  MixedColor = MixedColor; // 確認のため同じ値を代入

                                  setState(() {
                                    _allmixedColor.add(MixedColor);
                                  });
                                  Navigator.of(context).pop(); // ダイアログを閉じる
                                  Future.microtask(() {
                                    if (mounted) {
                                      setState(() {});
                                    }
                                  });
                                }
                                audioProvider.playSound("tap1.mp3");
                              },
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(255, 255, 67, 195),
                              ),
                              child: Text(
                                'これでOK🪄',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: fontsize,
                                    color: Colors.white),
                              ),
                            ),
                          ]),
                    ])));
          },
        );
      },
    );
  }

  void _mixColors() {
    // RGB の値を取得
    int r1 = SelectedColor1.red;
    int g1 = SelectedColor1.green;
    int b1 = SelectedColor1.blue;

    int r2 = SelectedColor2.red;
    int g2 = SelectedColor2.green;
    int b2 = SelectedColor2.blue;

    // RGB の加重平均
    int mixedR = ((r1 + r2) / 2).round();
    int mixedG = ((g1 + g2) / 2).round();
    int mixedB = ((b1 + b2) / 2).round();

    // 新しい色を作成
    MixedColor = Color.fromARGB(alpha, mixedR, mixedG, mixedB);
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
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left:
                        MediaQuery.of(context).size.height * 0.1), // 左辺だけに余白を追加
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
                              color: _selectedpaperColor,
                              child: GestureDetector(
                                onTapUp: (details) {
                                  setState(() {
                                    Offset tapPosition = details.localPosition;

                                    if (edittingmode == 3) {
                                      audioProvider.playSound("stamp.mp3");
                                      _drawItems.add(Circle(
                                          tapPosition,
                                          20 * (_strokeWidth / 10),
                                          _selectedColor));
                                    } else if (edittingmode == 4) {
                                      audioProvider.playSound("stamp.mp3");
                                      _drawItems.add(Triangle(
                                          tapPosition,
                                          30 * (_strokeWidth / 10),
                                          _selectedColor));
                                    } else if (edittingmode == 5) {
                                      audioProvider.playSound("stamp.mp3");
                                      _drawItems.add(Rectangle(
                                          tapPosition,
                                          40 * (_strokeWidth / 10),
                                          40 * (_strokeWidth / 10),
                                          _selectedColor));
                                    } else if (edittingmode == 6) {
                                      audioProvider.playSound("stamp.mp3");
                                      _drawItems.add(Heart(
                                          tapPosition,
                                          30 * (_strokeWidth / 10),
                                          _selectedColor));
                                    } else if (edittingmode == 7) {
                                      audioProvider.playSound("stamp.mp3");
                                      _drawItems.add(Star(
                                          tapPosition,
                                          30 * (_strokeWidth / 10),
                                          _selectedColor));
                                    } else if (edittingmode == 8) {
                                      audioProvider.playSound("stamp.mp3");
                                      _drawItems.add(Diamond(
                                          tapPosition,
                                          30 * (_strokeWidth / 10),
                                          _selectedColor));
                                    }
                                  });
                                },
                                onPanUpdate: (details) {
                                  setState(() {
                                    if (!isDrawing) {
                                      //audioProvider.playSound("drawing.mp3");
                                      isDrawing = true;
                                      if (edittingmode == 1) {
                                        audioProvider.playSound("drawing.mp3");
                                      } else if (edittingmode == 2) {
                                        audioProvider.playSound("drawing2.mp3");
                                      }
                                    }

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
                                    if (edittingmode == 2 &&
                                        correctedPosition.dx >= -20 &&
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
                                      final RenderBox renderBox = context
                                          .findRenderObject() as RenderBox;
                                      final localPosition =
                                          renderBox.globalToLocal(
                                              details.globalPosition);
                                      _addSprayPoints(localPosition, context);
                                    } else if (edittingmode == 1) {
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
                                        _currentLinePoints
                                            .add(correctedPosition);
                                      }
                                    }
                                  });
                                },
                                onPanEnd: (details) {
                                  setState(() {
                                    if (edittingmode == 2 &&
                                        _currentSprayPoints.isNotEmpty) {
                                      audioProvider.pauseAudio();
                                      isDrawing = false;
                                      _drawItems.add(SprayPoints(
                                          List.from(_currentSprayPoints),
                                          _selectedColor,
                                          _sprayDensity));
                                      _currentSprayPoints.clear();
                                    } else if (edittingmode == 1 &&
                                        _currentLinePoints.isNotEmpty) {
                                      audioProvider.pauseAudio();
                                      isDrawing = false;
                                      _drawItems.add(Line(_currentLinePoints,
                                          _selectedColor, _strokeWidth));
                                      _currentLinePoints = [];
                                    }
                                    _undoneItems.clear();
                                  });
                                },
                                child: CustomPaint(
                                  size: Size(
                                      MediaQuery.of(context).size.width * 0.6,
                                      MediaQuery.of(context).size.height * 0.6),
                                  painter: DrawingPainter(
                                    _drawItems,
                                    _currentLinePoints,
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
                      if (selectmode == 1) ...[
                        // 色選択用のウィジェット
                        Padding(
                          padding: EdgeInsets.all(3.0),
                          child: Text('パレット🎨',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontsize)),
                        ),
                        _buildColorPicker(
                            MediaQuery.of(context).size.width / 42),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                audioProvider.playSound("tap1.mp3");
                                _MixColorDialog(context);
                              },
                              tooltip: 'mix color',
                              splashColor: Color.fromARGB(255, 255, 67, 195),
                              iconSize: MediaQuery.of(context).size.width / 42,
                            ),
                          ],
                        ),
                      ] else if (selectmode == 2) ...[
                        Padding(
                          padding: EdgeInsets.all(3.0),
                          child: Text(
                              languageProvider.isHiragana
                                  ? 'ふでのおおきさ🖌️'
                                  : '筆の大きさ🖌️',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontsize)),
                        ),
                        _buildStrokePicker(
                            MediaQuery.of(context).size.width / 28),
                        Padding(
                          padding: EdgeInsets.all(3.0),
                          child: Text(
                              languageProvider.isHiragana
                                  ? 'ふでのしゅるい✏️'
                                  : '筆の種類✏️',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontsize)),
                        ),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: edittingmode == 1
                                      ? Colors.black
                                      : Color.fromARGB(
                                          255, 199, 198, 198), //枠線の色
                                  width: edittingmode == 1 ? 1 : 0, //枠線の太さ
                                ),
                              ),
                              child: IconButton(
                                icon: Icon(
                                    edittingmode == 1
                                        ? Icons.create
                                        : Icons.create,
                                    color: edittingmode == 1
                                        ? _selectedColor // 選択されたらピンク
                                        : const Color.fromARGB(
                                            255, 199, 198, 198)),
                                onPressed: () {
                                  setState(() {
                                    edittingmode = 1;
                                  });
                                },
                                tooltip:
                                    edittingmode == 1 ? 'Pen Mode' : 'Pen Mode',
                                splashColor: _selectedColor,
                                iconSize:
                                    MediaQuery.of(context).size.width / 42,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: edittingmode == 2
                                      ? Colors.black
                                      : Color.fromARGB(
                                          255, 199, 198, 198), //枠線の色
                                  width: edittingmode == 2 ? 1 : 0, //枠線の太さ
                                ),
                              ),
                              child: IconButton(
                                icon: Icon(
                                    edittingmode == 2
                                        ? Icons.brush
                                        : Icons.brush,
                                    color: edittingmode == 2
                                        ? _selectedColor // 選択されたらピンク
                                        : const Color.fromARGB(
                                            255, 199, 198, 198)),
                                onPressed: () {
                                  setState(() {
                                    edittingmode = 2;
                                  });
                                },
                                tooltip: edittingmode == 2
                                    ? 'Brush Mode'
                                    : 'Spray Mode',
                                splashColor: _selectedColor,
                                iconSize:
                                    MediaQuery.of(context).size.width / 42,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.all(3.0),
                          child: Text('スタンプ🔴',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontsize)),
                        ),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: edittingmode == 3
                                      ? Colors.black
                                      : Color.fromARGB(
                                          255, 199, 198, 198), //枠線の色
                                  width: edittingmode == 3 ? 1 : 0, //枠線の太さ
                                ),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  edittingmode == 3
                                      ? Icons.circle
                                      : Icons.circle,
                                  color: edittingmode == 3
                                      ? _selectedColor // 選択されたらピンク
                                      : const Color.fromARGB(
                                          255, 199, 198, 198),
                                ),
                                onPressed: () {
                                  setState(() {
                                    edittingmode = 3;
                                  });
                                },
                                tooltip: edittingmode == 3
                                    ? 'circle Mode'
                                    : 'circle Mode',
                                splashColor: _selectedColor,
                                iconSize:
                                    MediaQuery.of(context).size.width / 42,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: edittingmode == 4
                                      ? Colors.black
                                      : Color.fromARGB(
                                          255, 199, 198, 198), //枠線の色
                                  width: edittingmode == 4 ? 1 : 0, //枠線の太さ
                                ),
                              ),
                              child: IconButton(
                                icon: Icon(
                                    edittingmode == 4
                                        ? Icons.change_history
                                        : Icons.change_history,
                                    color: edittingmode == 4
                                        ? _selectedColor // 選択されたらピンク
                                        : const Color.fromARGB(
                                            255, 199, 198, 198)),
                                onPressed: () {
                                  setState(() {
                                    edittingmode = 4;
                                  });
                                },
                                tooltip: edittingmode == 4
                                    ? 'triangle Mode'
                                    : 'triangle Mode',
                                splashColor: _selectedColor,
                                iconSize:
                                    MediaQuery.of(context).size.width / 42,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: edittingmode == 5
                                      ? Colors.black
                                      : Color.fromARGB(
                                          255, 199, 198, 198), //枠線の色
                                  width: edittingmode == 5 ? 1 : 0, //枠線の太さ
                                ),
                              ),
                              child: IconButton(
                                icon: Icon(
                                    edittingmode == 5
                                        ? Icons.rectangle
                                        : Icons.rectangle,
                                    color: edittingmode == 5
                                        ? _selectedColor // 選択されたらピンク
                                        : const Color.fromARGB(
                                            255, 199, 198, 198)),
                                onPressed: () {
                                  setState(() {
                                    edittingmode = 5;
                                  });
                                },
                                tooltip: edittingmode == 5
                                    ? 'Rect Mode'
                                    : 'Rect Mode',
                                splashColor: _selectedColor,
                                iconSize:
                                    MediaQuery.of(context).size.width / 42,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: edittingmode == 6
                                      ? Colors.black
                                      : Color.fromARGB(
                                          255, 199, 198, 198), //枠線の色
                                  width: edittingmode == 6 ? 1 : 0, //枠線の太さ
                                ),
                              ),
                              child: IconButton(
                                icon: Icon(
                                    edittingmode == 6
                                        ? Icons.favorite
                                        : Icons.favorite,
                                    color: edittingmode == 6
                                        ? _selectedColor // 選択されたらピンク
                                        : const Color.fromARGB(
                                            255, 199, 198, 198)),
                                onPressed: () {
                                  setState(() {
                                    edittingmode = 6;
                                  });
                                },
                                tooltip: edittingmode == 6
                                    ? 'Heart Mode'
                                    : 'Heart Mode',
                                splashColor: _selectedColor,
                                iconSize:
                                    MediaQuery.of(context).size.width / 42,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: edittingmode == 7
                                      ? Colors.black
                                      : Color.fromARGB(
                                          255, 199, 198, 198), //枠線の色
                                  width: edittingmode == 7 ? 1 : 0, //枠線の太さ
                                ),
                              ),
                              child: IconButton(
                                icon: Icon(
                                    edittingmode == 7 ? Icons.star : Icons.star,
                                    color: edittingmode == 7
                                        ? _selectedColor // 選択されたらピンク
                                        : const Color.fromARGB(
                                            255, 199, 198, 198)),
                                onPressed: () {
                                  setState(() {
                                    edittingmode = 7;
                                  });
                                },
                                tooltip: edittingmode == 7
                                    ? 'Star Mode'
                                    : 'Star Mode',
                                splashColor: _selectedColor,
                                iconSize:
                                    MediaQuery.of(context).size.width / 42,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: edittingmode == 8
                                      ? Colors.black
                                      : Color.fromARGB(
                                          255, 199, 198, 198), //枠線の色
                                  width: edittingmode == 8 ? 1 : 0, //枠線の太さ
                                ),
                              ),
                              child: IconButton(
                                icon: Icon(
                                    edittingmode == 8
                                        ? Icons.diamond
                                        : Icons.diamond,
                                    color: edittingmode == 8
                                        ? _selectedColor // 選択されたらピンク
                                        : const Color.fromARGB(
                                            255, 199, 198, 198)),
                                onPressed: () {
                                  setState(() {
                                    edittingmode = 8;
                                  });
                                },
                                tooltip:
                                    edittingmode == 8 ? 'Dia Mode' : 'Dia Mode',
                                splashColor: _selectedColor,
                                iconSize:
                                    MediaQuery.of(context).size.width / 42,
                              ),
                            ),
                          ],
                        ),
                      ] else if (selectmode == 3) ...[
                        Padding(
                          padding: EdgeInsets.all(3.0),
                          child: Text(
                              languageProvider.isHiragana ? 'かみのいろ📃' : '紙の色📃',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontsize)),
                        ),
                        _buildPaperColorPicker(
                            MediaQuery.of(context).size.width / 28)
                      ],
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.undo),
                            onPressed: _drawItems.isNotEmpty ? _undo : null,
                            tooltip: 'Undo',
                            splashColor: Color.fromARGB(255, 255, 67, 195),
                            iconSize: MediaQuery.of(context).size.width / 42,
                          ),
                          IconButton(
                            icon: Icon(Icons.redo),
                            onPressed: _undoneItems.isNotEmpty ? _redo : null,
                            tooltip: 'Redo',
                            splashColor: Color.fromARGB(255, 255, 67, 195),
                            iconSize: MediaQuery.of(context).size.width / 42,
                          ),
                        ],
                      ),
                    ]),
                    Column(children: [
                      SizedBox(height: screenSize.height * 0.01),
                      IconButton(
                        icon: Icon(Icons.palette),
                        onPressed: () {
                          setState(() {
                            selectmode = 1;
                            audioProvider.playSound("tap1.mp3");
                          });
                        },
                        tooltip: 'palette',
                        splashColor: Color.fromARGB(255, 255, 67, 195),
                        color: selectmode == 1
                            ? Color.fromARGB(255, 255, 67, 195) // 選択されたらピンク
                            : const Color.fromARGB(255, 199, 198, 198),
                      ),
                      SizedBox(height: screenSize.height * 0.01),
                      IconButton(
                        icon: Icon(Icons.brush),
                        onPressed: () {
                          setState(() {
                            selectmode = 2;
                            audioProvider.playSound("tap1.mp3");
                          });
                        },
                        tooltip: 'pen',
                        splashColor: Color.fromARGB(255, 255, 67, 195),
                        color: selectmode == 2
                            ? Color.fromARGB(255, 255, 67, 195) // 選択されたらピンク
                            : const Color.fromARGB(255, 199, 198, 198),
                      ),
                      SizedBox(height: screenSize.height * 0.01),
                      IconButton(
                        icon: Icon(Icons.crop_portrait),
                        onPressed: () {
                          setState(() {
                            selectmode = 3;
                            audioProvider.playSound("tap1.mp3");
                          });
                        },
                        tooltip: 'paper',
                        splashColor: Color.fromARGB(255, 255, 67, 195),
                        color: selectmode == 3
                            ? Color.fromARGB(255, 255, 67, 195) // 選択されたらピンク
                            : const Color.fromARGB(255, 199, 198, 198),
                      ),
                    ]),
                    SizedBox(width: screenSize.width * 0.05),
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
                      backgroundColor: Color.fromARGB(255, 0, 204, 255),
                    ),
                    child: Text(
                      languageProvider.isHiragana ? 'とじる🔙' : '閉じる🔙',
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
                      languageProvider.isHiragana ? 'しゃしんからえらぶ🖼' : '写真から選ぶ🖼',
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
                      'できたよ🪄',
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
        await DrawingDatabaseHelper.instance.insertDrawing(pngBytes, isPhoto);
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
      isPhoto = 1;

      // データベースの初期化と保存
      await _initializeDatabase();
      try {
        await DrawingDatabaseHelper.instance.insertDrawing(pngBytes, isPhoto);
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
              _colorCircle(Color.fromARGB(255, 244, 67, 54), size),
              _colorCircle(Color.fromARGB(255, 255, 152, 0), size),
              _colorCircle(Color.fromARGB(255, 248, 181, 0), size),
            ],
          ),
          SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _colorCircle(Color.fromARGB(255, 255, 235, 59), size),
              _colorCircle(Color.fromARGB(255, 139, 195, 74), size),
              _colorCircle(Color.fromARGB(255, 76, 175, 80), size),
            ],
          ),
          SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _colorCircle(Color.fromARGB(255, 3, 169, 244), size),
              _colorCircle(Color.fromARGB(255, 0, 30, 255), size),
              _colorCircle(Color.fromARGB(255, 156, 39, 176), size),
            ],
          ),
          SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _colorCircle(Color.fromARGB(255, 255, 130, 171), size),
              _colorCircle(Color.fromARGB(255, 254, 220, 189), size),
              _colorCircle(Color.fromARGB(255, 255, 255, 255), size),
            ],
          ),
          SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _colorCircle(Color.fromARGB(255, 125, 125, 125), size),
              _colorCircle(Color.fromARGB(255, 0, 0, 0), size),
              _colorCircle(Color.fromARGB(255, 121, 85, 72), size),
            ],
          ),
          SizedBox(height: 3),
          _buildAllMixedColors(size),
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
            width: _selectedColor == color ? 1 : 1,
            color: _selectedColor == color ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }

  // 色を選択するためのウィジェット
  Widget _buildPaperColorPicker(double size) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _papercolorCircle(Color.fromARGB(255, 244, 67, 54), size),
              _papercolorCircle(Color.fromARGB(255, 255, 152, 0), size),
              _papercolorCircle(Color.fromARGB(255, 248, 181, 0), size),
            ],
          ),
          SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _papercolorCircle(Color.fromARGB(255, 255, 235, 59), size),
              _papercolorCircle(Color.fromARGB(255, 139, 195, 74), size),
              _papercolorCircle(Color.fromARGB(255, 76, 175, 80), size),
            ],
          ),
          SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _papercolorCircle(Color.fromARGB(255, 3, 169, 244), size),
              _papercolorCircle(Color.fromARGB(255, 0, 30, 255), size),
              _papercolorCircle(Color.fromARGB(255, 156, 39, 176), size),
            ],
          ),
          SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _papercolorCircle(Color.fromARGB(255, 255, 130, 171), size),
              _papercolorCircle(Color.fromARGB(255, 254, 220, 189), size),
              _papercolorCircle(Color.fromARGB(255, 255, 255, 255), size),
            ],
          ),
          SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _papercolorCircle(Color.fromARGB(255, 125, 125, 125), size),
              _papercolorCircle(Color.fromARGB(255, 0, 0, 0), size),
              _papercolorCircle(Color.fromARGB(255, 121, 85, 72), size),
            ],
          ),
          SizedBox(height: 3),
        ],
      ),
    );
  }

  Widget _buildMixedColorPicker(
      double size, bool select1, bool select2, Function setState) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MixedColorCircle(Color.fromARGB(255, 244, 67, 54), size, select1,
                  select2, setState),
              _MixedColorCircle(Color.fromARGB(255, 255, 152, 0), size, select1,
                  select2, setState),
              _MixedColorCircle(Color.fromARGB(255, 248, 181, 0), size, select1,
                  select2, setState),
            ],
          ),
          SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MixedColorCircle(Color.fromARGB(255, 255, 235, 59), size,
                  select1, select2, setState),
              _MixedColorCircle(Color.fromARGB(255, 139, 195, 74), size,
                  select1, select2, setState),
              _MixedColorCircle(Color.fromARGB(255, 76, 175, 80), size, select1,
                  select2, setState),
            ],
          ),
          SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MixedColorCircle(Color.fromARGB(255, 3, 169, 244), size, select1,
                  select2, setState),
              _MixedColorCircle(Color.fromARGB(255, 0, 30, 255), size, select1,
                  select2, setState),
              _MixedColorCircle(Color.fromARGB(255, 156, 39, 176), size,
                  select1, select2, setState),
            ],
          ),
          SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MixedColorCircle(Color.fromARGB(255, 255, 130, 171), size,
                  select1, select2, setState),
              _MixedColorCircle(Color.fromARGB(255, 254, 220, 189), size,
                  select1, select2, setState),
              _MixedColorCircle(Color.fromARGB(255, 255, 255, 255), size,
                  select1, select2, setState),
            ],
          ),
          SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MixedColorCircle(Color.fromARGB(255, 125, 125, 125), size,
                  select1, select2, setState),
              _MixedColorCircle(Color.fromARGB(255, 0, 0, 0), size, select1,
                  select2, setState),
              _MixedColorCircle(Color.fromARGB(255, 121, 85, 72), size, select1,
                  select2, setState),
            ],
          ),
          SizedBox(height: 3),
        ],
      ),
    );
  }

  Widget _MixedColorCircle(
      Color color, double size, bool select1, bool select2, Function setState) {
    final audioProvider = Provider.of<AudioProvider>(context);
    return GestureDetector(
      onTap: () {
        setState(() {
          audioProvider.playSound("tap1.mp3");
          if (select1 == true) {
            SelectedColor1 = color; // 色を更新
          } else if (select2 == true) {
            SelectedColor2 = color; // 色を更新
          }
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
              width: (select1 && SelectedColor1 == color) ||
                      (select2 && SelectedColor2 == color)
                  ? 3
                  : 1,
              color: (select1 && SelectedColor1 == color) ||
                      (select2 && SelectedColor2 == color)
                  ? Colors.black
                  : Colors.grey,
            )),
      ),
    );
  }

  Widget _MixedSelectedColorCircle(double size, int selectnum, setState) {
    final audioProvider = Provider.of<AudioProvider>(context);
    Color? selectedColor = (selectnum == 1) ? SelectedColor1 : SelectedColor2;

    return GestureDetector(
      onTap: () {
        setState(() {
          audioProvider.playSound("tap1.mp3");
          if (selectnum == 1) {
            select1 = true;
            select2 = false;
          } else if (selectnum == 2) {
            select1 = false;
            select2 = true;
          }
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.0),
        color: selectedColor,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: selectedColor,
          shape: BoxShape.circle,
          border: Border.all(
            width: (selectnum == 1 && select1) || (selectnum == 2 && select2)
                ? 3
                : 1,
            color: (selectnum == 1 && select1) || (selectnum == 2 && select2)
                ? Colors.black
                : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildAllMixedColors(double size) {
    if (_allmixedColor.isEmpty) return SizedBox(); // 空なら何も表示しない

    final List<Color> filteredColors = _allmixedColor
        .where((color) => color != null)
        .map((color) => color!)
        .toSet()
        .toList();

    int maxColors = 6; // 最大6色表示
    int colorCount = filteredColors.length.clamp(0, maxColors); // 実際に表示する色数を決定

    return Column(
      children: List.generate((colorCount / 3).ceil(), (rowIndex) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (colIndex) {
              final index = rowIndex * 3 + colIndex;
              if (index < colorCount) {
                return _colorCircle(filteredColors[index], size);
              }
              return const SizedBox(width: 0);
            }),
          ),
        );
      }),
    );
  }

  // 色選択用のボタン
  Widget _papercolorCircle(Color color, double size) {
    final audioProvider = Provider.of<AudioProvider>(context);
    return GestureDetector(
      onTap: () {
        setState(() {
          audioProvider.playSound("tap1.mp3");
          _selectedpaperColor = color; // 色を更新
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.0),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            width: _selectedpaperColor == color ? 3 : 1,
            color: _selectedpaperColor == color ? Colors.black : Colors.grey,
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
              color: _selectedColor,
              shape: BoxShape.circle,
              border: Border.all(
                width: _strokeWidth == strokesize ? 1.5 : 1,
                color: _strokeWidth == strokesize ? Colors.black : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// カスタムペインタークラス
// CustomPainterの修正
class DrawingPainter extends CustomPainter {
  final List<DrawingItem> items;
  final List<Offset?> currentLinePoints;
  final List<Offset> currentSprayPoints;
  final double strokeWidth;
  final Color color;

  DrawingPainter(
    this.items,
    this.currentLinePoints,
    this.currentSprayPoints,
    this.strokeWidth,
    this.color,
  );

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..style = PaintingStyle.fill;

    for (var item in items) {
      if (item is Line) {
        paint
          ..color = item.color.withAlpha(item.alpha)
          ..strokeWidth = item.strokeWidth
          ..strokeCap = StrokeCap.round;

        for (int i = 0; i < item.points.length - 1; i++) {
          if (item.points[i] != null && item.points[i + 1] != null) {
            canvas.drawLine(item.points[i]!, item.points[i + 1]!, paint);
          }
        }
      } else if (item is SprayPoints) {
        paint.color = item.color;
        for (var point in item.points) {
          canvas.drawCircle(point, 1.0, paint);
        }
      } else if (item is Circle) {
        paint.color = item.color;
        canvas.drawCircle(item.center, item.radius, paint);
      } else if (item is Triangle) {
        paint.color = item.color;
        Path path = Path();
        path.moveTo(item.center.dx, item.center.dy - item.size);
        path.lineTo(item.center.dx - item.size, item.center.dy + item.size);
        path.lineTo(item.center.dx + item.size, item.center.dy + item.size);
        path.close();
        canvas.drawPath(path, paint);
      } else if (item is Rectangle) {
        paint.color = item.color;
        canvas.drawRect(
          Rect.fromLTWH(item.topLeft.dx - item.width / 2,
              item.topLeft.dy - item.height / 2, item.width, item.height),
          paint,
        );
      } else if (item is Heart) {
        paint.color = item.color;
        Path path = Path();
        double x = item.center.dx;
        double y = item.center.dy;
        double s = item.size;
        // Move to the starting point
        path.moveTo(x, y + s / 4);
        // Left side curve
        path.cubicTo(x - s * 0.5, y - s * 0.5, x - s, y + s * 0.2, x, y + s);
        // Right side curve
        path.cubicTo(
            x + s, y + s * 0.2, x + s * 0.5, y - s * 0.5, x, y + s / 4);
        // Draw the path
        canvas.drawPath(path, paint);
      } else if (item is Star) {
        paint.color = item.color;
        Path path = Path();
        double x = item.center.dx;
        double y = item.center.dy;
        double s = item.size;

        for (int i = 0; i < 5; i++) {
          double angle = (i * 144) * (3.1415926535 / 180);
          double dx = x + s * math.cos(angle);
          double dy = y + s * math.sin(angle);
          if (i == 0) {
            path.moveTo(dx, dy);
          } else {
            path.lineTo(dx, dy);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
      } else if (item is Diamond) {
        paint.color = item.color;
        Path path = Path();
        path.moveTo(item.center.dx, item.center.dy - item.size);
        path.lineTo(item.center.dx - item.size, item.center.dy);
        path.lineTo(item.center.dx, item.center.dy + item.size);
        path.lineTo(item.center.dx + item.size, item.center.dy);
        path.close();
        canvas.drawPath(path, paint);
      }
    }
    // 現在の線の描画
    if (currentLinePoints.isNotEmpty) {
      paint
        ..color = color
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i < currentLinePoints.length - 1; i++) {
        if (currentLinePoints[i] != null && currentLinePoints[i + 1] != null) {
          canvas.drawLine(
              currentLinePoints[i]!, currentLinePoints[i + 1]!, paint);
        }
      }
    }

    // 現在のスプレーの描画
    if (currentSprayPoints.isNotEmpty) {
      paint.color = color;
      for (var point in currentSprayPoints) {
        canvas.drawCircle(point, 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
