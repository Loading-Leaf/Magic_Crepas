import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_art/artproject/audio_provider.dart';
import 'package:ai_art/artproject/language_provider.dart';

class WifiDisconnectDialog extends StatelessWidget {
  const WifiDisconnectDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // 利用規約の内容（例）
    final audioProvider = Provider.of<AudioProvider>(context);

    Size screenSize = MediaQuery.sizeOf(context);
    double fontsize_big = screenSize.width / 64;
    double fontsize = screenSize.width / 74.6;
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    return AlertDialog(
      title: Text(
        languageProvider.isHiragana
            ? 'wifiがきれてえのさくせいしっぱいしたよ'
            : 'wifiがきれて絵の作成失敗したよ',
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: fontsize,
            color: Colors.white),
      ),
      content: Text(""),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            audioProvider.playSound("tap1.mp3");
            Navigator.pushNamed(context, '/');
          },
          style: TextButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 255, 67, 195),
          ),
          child: Text(languageProvider.isHiragana ? 'ホームにもどる' : 'ホームに戻る',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: fontsize,
                  color: Colors.white)),
        ),
      ],
    );
  }
}

class SomethingDisconnectDialog extends StatefulWidget {
  final String message1;
  final String message2;

  const SomethingDisconnectDialog({
    super.key,
    required this.message1,
    required this.message2,
  });

  @override
  _SomethingDisconnectDialogState createState() =>
      _SomethingDisconnectDialogState();
}

class _SomethingDisconnectDialogState extends State<SomethingDisconnectDialog> {
  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    Size screenSize = MediaQuery.sizeOf(context);
    double fontsize = screenSize.width / 74.6;

    return AlertDialog(
      title: Text(
        languageProvider.isHiragana ? widget.message1 : widget.message2,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: fontsize,
            color: Colors.white),
      ),
      content: const SizedBox.shrink(),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            audioProvider.playSound("tap1.mp3");
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 255, 67, 195),
          ),
          child: Text(languageProvider.isHiragana ? 'とじる' : '閉じる',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: fontsize,
                  color: Colors.white)),
        ),
      ],
    );
  }
}
