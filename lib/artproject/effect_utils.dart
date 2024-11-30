import 'package:flutter/material.dart';
import 'dart:math';

class SparkleEffect extends StatefulWidget {
  final Offset position;

  const SparkleEffect({Key? key, required this.position}) : super(key: key);

  @override
  _SparkleEffectState createState() => _SparkleEffectState();
}

class _SparkleEffectState extends State<SparkleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late List<Offset> _sparklePositions;
  late List<Animation<double>> _sparkleScales;

  @override
  void initState() {
    super.initState();

    // アニメーションコントローラの設定
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    // スケールアニメーション
    _scaleAnimation =
        Tween<double>(begin: 1.0, end: 2.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // エフェクトの点の位置を設定
    _sparklePositions = List.generate(10, (index) {
      double angle = Random().nextDouble() * 2 * pi; // ランダムな角度
      double radius = Random().nextDouble() * 30; // 半径のランダムな値
      return Offset(
        widget.position.dx + radius * cos(angle),
        widget.position.dy + radius * sin(angle),
      );
    });

    // スケールアニメーションのリスト
    _sparkleScales = List.generate(10, (index) {
      return Tween<double>(begin: 1.0, end: 1.5).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(_sparklePositions.length, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Positioned(
              left: _sparklePositions[index].dx - 10,
              top: _sparklePositions[index].dy - 10,
              child: Opacity(
                opacity: 1 - _controller.value, // フェードアウト
                child: Transform.scale(
                  scale: _sparkleScales[index].value,
                  child: Icon(
                    Icons.star,
                    color: Color.fromARGB(255, 255, 184, 246).withOpacity(0.8),
                    size: 20,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

void showSparkleEffect(BuildContext context, Offset position) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => SparkleEffect(position: position),
  );

  overlay.insert(overlayEntry);

  // 1秒後にエフェクトを消す
  Future.delayed(const Duration(seconds: 1), () {
    overlayEntry.remove();
  });
}
