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

class _PuzzlePageState extends State<PuzzlePage> {
  Uint8List? puzzleImage;
  List<Uint8List>? puzzlePieces;
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

  Future<List<Uint8List>> splitImage(
      Uint8List imageData, int rows, int cols) async {
    final image = img.decodeImage(imageData)!;
    final pieceWidth = image.width ~/ cols;
    final pieceHeight = image.height ~/ rows;
    List<Uint8List> pieces = [];

    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        // img.copyCropの引数名を明示的に指定
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

  Future<void> _loadRandomImage() async {
    final images = await GalleryDatabaseHelper.instance.fetchDrawings();
    if (images.isNotEmpty) {
      final rand = Random();
      final idx = rand.nextInt(images.length);
      final Uint8List imageData = images[idx]['outputimage'];
      final pieces = await splitImage(imageData, 2, 3);
      setState(() {
        puzzleImage = imageData;
        puzzlePieces = pieces;
        pieceOrder = List.generate(6, (i) => i);
        pieceOrder.shuffle(rand);
        loading = false;
        secondsLeft = 60;
      });
      _startTimer();
    } else {
      setState(() {
        puzzleImage = null;
        puzzlePieces = null;
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
                : puzzleImage == null || puzzlePieces == null
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
                                    Navigator.pushNamed(context, '/menu');
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 255, 67, 195),
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
