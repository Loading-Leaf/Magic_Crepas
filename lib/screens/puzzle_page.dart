import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import "package:ai_art/artproject/terms_of_service.dart";
import 'package:ai_art/artproject/audio_provider.dart';
import 'package:ai_art/artproject/effect_utils.dart';
import 'package:ai_art/artproject/language_provider.dart';
import 'package:ai_art/artproject/gallery_database_helper.dart';
import 'dart:typed_data';
import 'dart:math';
import 'dart:async';
import 'package:image/image.dart' as img;

class PuzzlePage extends StatefulWidget {
  const PuzzlePage({super.key});

  @override
  State<PuzzlePage> createState() => _PuzzlePageState();
}

enum PuzzleState {
  initial,
  loading,
  countdown,
  playing,
}

class _PuzzlePageState extends State<PuzzlePage> {
  Uint8List? puzzleImage;
  List<Uint8List>? puzzlePieces;
  List<int> pieceOrder = List.generate(6, (i) => i); // 0~5
  bool loading = false;
  int secondsLeft = 60;
  Timer? _timer;
  Timer? _countdownTimer;
  int countdown = 3;
  PuzzleState puzzleState = PuzzleState.initial;

  @override
  void dispose() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<List<Uint8List>> splitImage(
      Uint8List imageData, int rows, int cols) async {
    // 軽量化のため isolate等を使う場合は別途実装
    final image = img.decodeImage(imageData)!;
    final pieceWidth = image.width ~/ cols;
    final pieceHeight = image.height ~/ rows;
    List<Uint8List> pieces = [];

    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        final piece = img.copyCrop(
          image,
          x: x * pieceWidth,
          y: y * pieceHeight,
          width: pieceWidth,
          height: pieceHeight,
        );
        pieces.add(Uint8List.fromList(img.encodePng(piece)));
      }
    }
    return pieces;
  }

  Future<void> _preparePuzzle() async {
    setState(() {
      loading = true;
      puzzleState = PuzzleState.loading;
    });
    final images = await GalleryDatabaseHelper.instance.fetchDrawings();
    if (images.isNotEmpty) {
      final rand = Random();
      final idx = rand.nextInt(images.length);
      final Uint8List imageData = images[idx]['outputimage'];
      // 分割処理
      final pieces = await splitImage(imageData, 2, 3);
      setState(() {
        puzzleImage = imageData;
        puzzlePieces = pieces;
        pieceOrder = List.generate(6, (i) => i);
        pieceOrder.shuffle(rand);
        loading = false;
        countdown = 3;
        secondsLeft = 60;
        puzzleState = PuzzleState.countdown;
      });
      _startCountdown();
    } else {
      setState(() {
        puzzleImage = null;
        puzzlePieces = null;
        loading = false;
        puzzleState = PuzzleState.initial;
      });
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      countdown = 3;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown <= 1) {
        timer.cancel();
        setState(() {
          puzzleState = PuzzleState.playing;
        });
        _startTimer();
      } else {
        setState(() {
          countdown--;
        });
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      secondsLeft = 60;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsLeft <= 1) {
        timer.cancel();
        _showTimeoutDialog();
      } else {
        setState(() {
          secondsLeft--;
        });
      }
    });
  }

  void _showTimeoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('時間切れ'),
        content: const Text('もう一度挑戦してね！'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetPuzzle();
            },
            child: const Text('リトライ'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetPuzzle();
              Navigator.pushNamed(context, '/menu');
            },
            child: const Text('メニューへ'),
          ),
        ],
      ),
    );
  }

  void _onPieceDropped(int from, int to) {
    setState(() {
      final tmp = pieceOrder[from];
      pieceOrder[from] = pieceOrder[to];
      pieceOrder[to] = tmp;
    });
    if (_isSolved()) {
      _timer?.cancel();
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('完成！'),
          content: const Text('おめでとう！'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetPuzzle();
              },
              child: const Text('もう一度'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetPuzzle();
                Navigator.pushNamed(context, '/menu');
              },
              child: const Text('メニューへ'),
            ),
          ],
        ),
      );
    }
  }

  bool _isSolved() {
    for (int i = 0; i < pieceOrder.length; i++) {
      if (pieceOrder[i] != i) return false;
    }
    return true;
  }

  void _resetPuzzle() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    setState(() {
      puzzleImage = null;
      puzzlePieces = null;
      pieceOrder = List.generate(6, (i) => i);
      loading = false;
      secondsLeft = 60;
      countdown = 3;
      puzzleState = PuzzleState.initial;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    double fontsize_big = screenSize.width / 64;
    double fontsize = screenSize.width / 74.6;
    final audioProvider = Provider.of<AudioProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    double tile_size = screenSize.height * 0.6;

    Widget content;
    switch (puzzleState) {
      case PuzzleState.initial:
        content = Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                languageProvider.locallanguage == 2
                    ? "Let's Start Puzzle!"
                    : languageProvider.isHiragana
                        ? "パズルをはじめよう！"
                        : "パズルを始めよう！",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: fontsize_big,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  audioProvider.playSound("tap1.mp3");
                  _preparePuzzle();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 67, 195),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                ),
                child: Text(
                  languageProvider.locallanguage == 2
                      ? "Start"
                      : languageProvider.isHiragana
                          ? "スタート"
                          : "スタート",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontsize_big,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
        break;
      case PuzzleState.loading:
        content = const Center(
          child: CircularProgressIndicator(),
        );
        break;
      case PuzzleState.countdown:
        content = Center(
          child: Text(
            countdown > 0 ? countdown.toString() : "",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontsize_big * 2,
              color: Colors.red,
            ),
          ),
        );
        break;
      case PuzzleState.playing:
        content = Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              "残り時間: $secondsLeft 秒",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontsize_big,
                color: Colors.red,
              ),
            ),
            SizedBox(
              width: tile_size,
              height: tile_size,
              child: _PuzzleBoard(
                pieces: puzzlePieces!,
                pieceOrder: pieceOrder,
                onPieceDropped: _onPieceDropped,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 10),
                Container(
                  child: TextButton(
                    onPressed: () {
                      audioProvider.playSound("tap1.mp3");
                      _resetPuzzle();
                      Navigator.pushNamed(context, '/menu');
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 67, 195),
                    ),
                    child: Text(
                      languageProvider.locallanguage == 2
                          ? "Back to Title"
                          : languageProvider.isHiragana
                              ? 'メニューにもどる'
                              : 'メニューに戻る',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontsize,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            )
          ],
        );
        break;
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: GestureDetector(
          onTapUp: (details) {
            Offset tapPosition = details.localPosition;
            showSparkleEffect(context, tapPosition);
          },
          child: SizedBox.expand(child: content),
        ),
      ),
    );
  }
}

// 6ピースパズルボード（2行×3列）画像を分割して表示
class _PuzzleBoard extends StatelessWidget {
  final List<Uint8List> pieces;
  final List<int> pieceOrder;
  final void Function(int from, int to) onPieceDropped;

  const _PuzzleBoard({
    required this.pieces,
    required this.pieceOrder,
    required this.onPieceDropped,
  });

  @override
  Widget build(BuildContext context) {
    double boardWidth = MediaQuery.sizeOf(context).height * 0.6;
    double pieceWidth = boardWidth / 3;
    double pieceHeight = boardWidth / 3; // 正方形ピース

    return SizedBox(
      width: boardWidth,
      height: boardWidth * 2 / 3,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemCount: 6,
        itemBuilder: (context, idx) {
          int pieceIdx = pieceOrder[idx];
          return _ImagePuzzlePiece(
            imageData: pieces[pieceIdx],
            displayIndex: idx,
            onAccept: (fromIdx) {
              onPieceDropped(fromIdx, idx);
            },
            width: pieceWidth,
            height: pieceHeight,
          );
        },
      ),
    );
  }
}

// 分割画像ピースWidget
class _ImagePuzzlePiece extends StatelessWidget {
  final Uint8List imageData;
  final int displayIndex;
  final void Function(int fromIdx) onAccept;
  final double width;
  final double height;

  const _ImagePuzzlePiece({
    required this.imageData,
    required this.displayIndex,
    required this.onAccept,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<int>(
      onWillAccept: (data) => data != displayIndex,
      onAccept: onAccept,
      builder: (context, candidateData, rejectedData) {
        return LongPressDraggable<int>(
          data: displayIndex,
          feedback: SizedBox(
            width: width,
            height: height,
            child: Opacity(
                opacity: 0.7,
                child: Image.memory(imageData, fit: BoxFit.cover)),
          ),
          childWhenDragging: Container(
            width: width,
            height: height,
            color: Colors.grey[300],
          ),
          child: SizedBox(
            width: width,
            height: height,
            child: Image.memory(imageData, fit: BoxFit.cover),
          ),
        );
      },
    );
  }
}
