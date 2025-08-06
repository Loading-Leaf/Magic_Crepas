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

class PuzzlePage extends StatefulWidget {
  const PuzzlePage({super.key});

  @override
  State<PuzzlePage> createState() => _PuzzlePageState();
}

class _PuzzlePageState extends State<PuzzlePage> {
  Uint8List? puzzleImage;
  List<int> pieceOrder = List.generate(6, (i) => i); // 0~5
  bool loading = true;
  int secondsLeft = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadRandomImage();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadRandomImage() async {
    final images = await GalleryDatabaseHelper.instance.fetchDrawings();
    if (images.isNotEmpty) {
      final rand = Random();
      final idx = rand.nextInt(images.length);
      setState(() {
        puzzleImage = images[idx]['outputimage'];
        pieceOrder.shuffle(rand);
        loading = false;
        secondsLeft = 60;
      });
      _startTimer();
    } else {
      setState(() {
        puzzleImage = null;
        loading = false;
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
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
              _loadRandomImage();
            },
            child: const Text('リトライ'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
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
                _loadRandomImage();
              },
              child: const Text('もう一度'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    double fontsize_big = screenSize.width / 64;
    double fontsize = screenSize.width / 74.6;
    final audioProvider = Provider.of<AudioProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    double tile_size = screenSize.height * 0.6;

    return PopScope(
        canPop: false,
        child: Scaffold(
          body: GestureDetector(
            onTapUp: (details) {
              Offset tapPosition = details.localPosition;
              showSparkleEffect(context, tapPosition);
            },
            child: SizedBox.expand(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : puzzleImage == null
                      ? Center(
                          child: Text(
                            languageProvider.locallanguage == 2
                                ? "No images in gallery"
                                : "ギャラリーに画像がありません",
                            style: TextStyle(fontSize: fontsize_big),
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            // 残り時間表示
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
                              height: tile_size * 2 / 3,
                              child: _PuzzleBoard(
                                image: puzzleImage!,
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
                                      Navigator.pushNamed(context, '/menu');
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                          255, 255, 67, 195),
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
                        ),
            ),
          ),
        ));
  }
}

// 6ピースパズルボード（2行×3列）画像を分割して表示
class _PuzzleBoard extends StatelessWidget {
  final Uint8List image;
  final List<int> pieceOrder;
  final void Function(int from, int to) onPieceDropped;

  const _PuzzleBoard({
    required this.image,
    required this.pieceOrder,
    required this.onPieceDropped,
  });

  @override
  Widget build(BuildContext context) {
    double boardWidth = MediaQuery.sizeOf(context).height * 0.6;
    double boardHeight = boardWidth * 2 / 3;
    double pieceWidth = boardWidth / 3;
    double pieceHeight = boardHeight / 2;

    return SizedBox(
      width: boardWidth,
      height: boardHeight,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemCount: 6,
        itemBuilder: (context, idx) {
          int pieceIdx = pieceOrder[idx];
          return _PuzzlePiece(
            image: image,
            pieceIndex: pieceIdx,
            displayIndex: idx,
            width: pieceWidth,
            height: pieceHeight,
            onAccept: (fromIdx) {
              onPieceDropped(fromIdx, idx);
            },
          );
        },
      ),
    );
  }
}

// 1ピース（画像を分割して表示）
class _PuzzlePiece extends StatelessWidget {
  final Uint8List image;
  final int pieceIndex; // 0~5
  final int displayIndex; // 0~5
  final double width;
  final double height;
  final void Function(int fromIdx) onAccept;

  const _PuzzlePiece({
    required this.image,
    required this.pieceIndex,
    required this.displayIndex,
    required this.width,
    required this.height,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    int row = pieceIndex ~/ 3;
    int col = pieceIndex % 3;
    return DragTarget<int>(
      onWillAccept: (data) => data != displayIndex,
      onAccept: onAccept,
      builder: (context, candidateData, rejectedData) {
        return LongPressDraggable<int>(
          data: displayIndex,
          feedback: _buildPiece(row, col, opacity: 0.7),
          childWhenDragging: Container(
            width: width,
            height: height,
            color: Colors.grey[300],
          ),
          child: _buildPiece(row, col),
        );
      },
    );
  }

  Widget _buildPiece(int row, int col, {double opacity = 1.0}) {
    return Opacity(
      opacity: opacity,
      child: SizedBox(
        width: width,
        height: height,
        child: ClipRect(
          child: Align(
            alignment: Alignment(
              -1.0 + col * 1.0,
              -1.0 + row * 2.0,
            ),
            widthFactor: 1 / 3,
            heightFactor: 1 / 2,
            child: Image.memory(
              image,
              width: width * 3,
              height: height * 2,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
