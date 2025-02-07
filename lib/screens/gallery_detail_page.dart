import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart'; // Provider のインポート
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:ai_art/artproject/audio_provider.dart'; // AudioProvider のインポート
import 'package:photo_manager/photo_manager.dart';
import 'package:ai_art/artproject/gallery_database_helper.dart';
import 'package:ai_art/artproject/language_provider.dart';
import 'package:ai_art/artproject/modal_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';

class GalleryDetailPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const GalleryDetailPage({super.key, required this.data});

  @override
  _GalleryDetailPageState createState() => _GalleryDetailPageState();
}

class _GalleryDetailPageState extends State<GalleryDetailPage> {
  Uint8List? outputImage = Uint8List(0);
  Uint8List? drawingImage = Uint8List(0);
  Uint8List? photoImage = Uint8List(0);
  String your_detailemotion = "";
  String your_platform = "";

  Future<void> checkDevice() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      setState(() {
        if (iosInfo.model.toLowerCase().contains("ipad")) {
          your_platform = "タブレット";
        } else {
          your_platform = "スマホ";
        }
      });
    } else if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      setState(() {
        if (androidInfo.systemFeatures
                .contains("android.hardware.type.television") ||
            androidInfo.systemFeatures
                .contains("android.hardware.type.watch") ||
            androidInfo.systemFeatures
                .contains("android.hardware.type.automotive")) {
          your_platform = "その他";
        } else if (androidInfo.model.toLowerCase().contains("tablet") ||
            androidInfo.product.toLowerCase().contains("tablet")) {
          your_platform = "タブレット";
        } else {
          your_platform = "スマホ";
        }
      });
    }
  }

  Future<void> saveImage() async {
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);

    if (outputImage == null) return;

    // 写真ライブラリの権限を確認・リクエスト
    final PermissionState permission =
        await PhotoManager.requestPermissionExtend();
    if (permission.isAuth) {
      // 権限が許可されている場合、画像を保存
      final result = await ImageGallerySaverPlus.saveImage(
        outputImage!,
        quality: 100,
        name: 'output_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      showDialog(
        context: context,
        builder: (context) => SomethingDisconnectDialog(
          message1: result['isSuccess']
              ? 'つくったえをほぞんしたよ😊'
              : 'つくったえのほぞんにしっぱいしたよ😭\nおとうさんとおかあさんにはなして、\nいっしょにせっていをかくにんしてね⚙️',
          message2: result['isSuccess']
              ? '作った絵を保存したよ😊'
              : '作った絵の保存に失敗しました😭\n設定を確認してください⚙️',
        ),
      );
      audioProvider.playSound("established.mp3");
    } else {
      // 権限が拒否された場合、警告メッセージを表示
      showDialog(
        context: context,
        builder: (context) => const SomethingDisconnectDialog(
          message1:
              'しゃしんライブラリへのアクセスができないよ😢\nおとうさんとおかあさんにはなして、\nいっしょにせっていをかくにんしてね⚙️',
          message2: '写真ライブラリへのアクセスが許可されていません😢\n設定を確認してください⚙️',
        ),
      );
    }
  }

  Future<void> saveDrawing() async {
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);

    if (drawingImage == null) return;

    // 写真ライブラリの権限を確認・リクエスト
    final PermissionState permission =
        await PhotoManager.requestPermissionExtend();
    if (permission.isAuth) {
      // 権限が許可されている場合、画像を保存
      final result = await ImageGallerySaverPlus.saveImage(
        drawingImage!,
        quality: 100,
        name: 'drawing_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      showDialog(
        context: context,
        builder: (context) => SomethingDisconnectDialog(
          message1: result['isSuccess']
              ? 'おえかきしたえをほぞんしたよ😊'
              : 'おえかきしたえのほぞんにしっぱいしたよ😭\nおとうさんとおかあさんにはなして、\nいっしょにせっていをかくにんしてね⚙️',
          message2: result['isSuccess']
              ? 'お絵描きした絵を保存したよ😊'
              : 'お絵描きした絵の保存に失敗しました😭\n設定を確認してください⚙️',
        ),
      );
      audioProvider.playSound("established.mp3");
    } else {
      // 権限が拒否された場合、警告メッセージを表示
      showDialog(
        context: context,
        builder: (context) => const SomethingDisconnectDialog(
          message1:
              'しゃしんライブラリへのアクセスができないよ。😢\nおとうさんとおかあさんにはなして、\nいっしょにせっていをかくにんしてね⚙️',
          message2: '写真ライブラリへのアクセスが許可されていません。😢\n設定を確認してください⚙️',
        ),
      );
    }
  }

  void _showImageModal(BuildContext context, ImageProvider image) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent, // 背景を透明に
          child: InteractiveViewer(
            child: Image(image: image), // ここでタップした画像を表示
          ),
        );
      },
    );
  }

  Future<void> _showDeleteConfirmDialog() async {
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    Size screenSize = MediaQuery.sizeOf(context);
    double fontsize = screenSize.width / 74.6;
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            languageProvider.isHiragana ? 'さくじょする🗑️' : '削除する🗑️',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontsize,
            ),
          ),
          content: Text(
            languageProvider.isHiragana
                ? 'このさくひんをさくじょしてもだいじょうぶ？'
                : 'この作品を削除しても大丈夫？',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontsize,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                languageProvider.isHiragana ? 'もどる🔙' : '戻る🔙',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontsize,
                    color: Colors.white),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 0, 81, 255),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                audioProvider.playSound("tap1.mp3");
              },
            ),
            TextButton(
              child: Text(
                languageProvider.isHiragana ? 'さくじょする🗑️' : '削除する🗑️',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontsize,
                    color: Colors.white),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 255, 67, 195),
              ),
              onPressed: () async {
                // データベースから削除
                await GalleryDatabaseHelper.instance.delete(widget.data['_id']);
                audioProvider.playSound("tap1.mp3");

                Navigator.pushNamed(context, '/gallery');

                showDialog(
                  context: context,
                  builder: (context) => const SomethingDisconnectDialog(
                    message1: 'さくじょしたよ🗑️',
                    message2: '削除したよ🗑️',
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  String _getFormattedText(String input, int maxLength) {
    List<String> lines = [];
    for (int i = 0; i < input.length; i += maxLength) {
      lines.add(input.substring(
          i, i + maxLength > input.length ? input.length : i + maxLength));
    }
    return lines.join('\n'); // Join lines with a newline
  }

  void _showPhotoAndEmotionModal() {
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    Size screenSize = MediaQuery.sizeOf(context);
    double fontsize = screenSize.width / 74.6;
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: screenSize.width * 0.6,
            height: screenSize.height * 0.9,
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  languageProvider.isHiragana ? 'しょうさいなきもち😊' : "詳細な気持ち😊",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontsize,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  _getFormattedText(your_detailemotion, 20),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontsize,
                  ),
                ),
                SizedBox(height: 20),
                if (photoImage != null && photoImage!.isNotEmpty) ...[
                  Text(
                    languageProvider.isHiragana ? "つかったしゃしん🖼" : "使った写真🖼",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: fontsize,
                    ),
                  ),
                  SizedBox(height: 5),
                  Padding(
                    padding: EdgeInsets.all(5.0),
                    child: GestureDetector(
                      onTap: () {
                        if (photoImage != null) {
                          // 画像が存在する場合、タップしてモーダルを表示
                          _showImageModal(context, MemoryImage(photoImage!));
                        } else {
                          // デフォルト画像の場合
                          _showImageModal(
                              context, AssetImage('assets/content.png'));
                        }
                      },
                      child: Container(
                        height: (screenSize.width ~/ 6.948).toDouble(),
                        width: (screenSize.width ~/ 5.208).toDouble(),
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: photoImage != null
                              ? Image.memory(photoImage!) // 画像を表示
                              : Image.asset('assets/content.png'), // デフォルト画像
                        ),
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 20),
                TextButton(
                  onPressed: () async {
                    audioProvider.playSound("tap1.mp3");
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 0, 81, 255),
                  ),
                  child: Text(
                    languageProvider.isHiragana ? 'とじる🔙' : '閉じる🔙',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontsize,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    outputImage = widget.data['outputimage'];
    drawingImage = widget.data['drawingimage'];
    photoImage = widget.data['photoimage'];
    String title = widget.data['title'] ?? "無題";
    String emotion = widget.data['emotion'] ?? "無題";
    String detailemotion = widget.data['detailemotion'] ?? "無題";
    your_detailemotion = detailemotion;
    String time = widget.data['time'] ?? "不明";
    Size screenSize = MediaQuery.sizeOf(context);
    double fontsize = screenSize.width / 74.6;

    return PopScope(
      // ここを追加
      canPop: false, // false で無効化
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "タイトル: $title",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: fontsize,
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  languageProvider.isHiragana ? "さくせいにちじ" : "作成日時: $time",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontsize,
                  ),
                ),
                SizedBox(width: 50),
                Text(
                  languageProvider.isHiragana
                      ? "かんじょう: $emotion"
                      : "感情: $emotion",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontsize,
                  ),
                ),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(languageProvider.isHiragana ? "つくったえ" : "作った絵",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: fontsize)),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: GestureDetector(
                        onTap: () {
                          if (outputImage != null) {
                            // 画像が存在する場合、タップしてモーダルを表示
                            _showImageModal(context, MemoryImage(outputImage!));
                          } else {
                            // デフォルト画像の場合
                            _showImageModal(
                                context, AssetImage('assets/output_style.png'));
                          }
                        },
                        child: Container(
                          height: (screenSize.width ~/ 6.948).toDouble(),
                          width: (screenSize.width ~/ 5.208).toDouble(),
                          child: FittedBox(
                            fit: BoxFit.fill,
                            child: outputImage != null
                                ? Image.memory(outputImage!) // 画像を表示
                                : Image.asset(
                                    'assets/output_style.png'), // デフォルト画像
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        audioProvider.playSound("established.mp3");
                        saveImage();
                      }, // 画像を保存するボタン
                      style: TextButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 255, 67, 195),
                      ),
                      child: Text(
                        languageProvider.isHiragana
                            ? your_platform + 'にほぞんする📱'
                            : your_platform + 'に保存する📱',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: fontsize,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(languageProvider.isHiragana ? 'おえかきしたえ' : "お絵描きした絵",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: fontsize)),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: GestureDetector(
                        onTap: () {
                          if (drawingImage != null) {
                            // 画像が存在する場合、タップしてモーダルを表示
                            _showImageModal(
                                context, MemoryImage(drawingImage!));
                          } else {
                            // デフォルト画像の場合
                            _showImageModal(
                                context, AssetImage('assets/content.png'));
                          }
                        },
                        child: Container(
                          height: (screenSize.width ~/ 6.948).toDouble(),
                          width: (screenSize.width ~/ 5.208).toDouble(),
                          child: FittedBox(
                            fit: BoxFit.fill,
                            child: drawingImage != null
                                ? Image.memory(drawingImage!) // 画像を表示
                                : Image.asset('assets/content.png'), // デフォルト画像
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        audioProvider.playSound("established.mp3");
                        saveDrawing();
                      }, // 画像を保存するボタン
                      style: TextButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 255, 67, 195),
                      ),
                      child: Text(
                        languageProvider.isHiragana
                            ? your_platform + 'にほぞんする📱'
                            : your_platform + 'に保存する📱',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: fontsize,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ]),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => {
                      Navigator.pop(context),
                      audioProvider.playSound("tap1.mp3"),
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 0, 81, 255),
                    ),
                    child: Text(
                      languageProvider.isHiragana ? "もどる🔙" : "戻る🔙",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontsize,
                          color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 20),
                  TextButton(
                    onPressed: () => {
                      audioProvider.playSound("tap1.mp3"),
                      _showPhotoAndEmotionModal(),
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 255, 67, 195),
                    ),
                    child: Text(
                      languageProvider.isHiragana ? "くわしくみる👀" : "詳しく見る👀",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontsize,
                          color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 20),
                  TextButton(
                    onPressed: () => {
                      audioProvider.playSound("tap1.mp3"),
                      _showDeleteConfirmDialog(),
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 255, 67, 195),
                    ),
                    child: Text(
                      languageProvider.isHiragana ? "さくじょする🗑️" : "削除する🗑️",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontsize,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
