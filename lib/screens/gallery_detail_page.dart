import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart'; // Provider のインポート
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:ai_art/artproject/audio_provider.dart'; // AudioProvider のインポート
import 'package:photo_manager/photo_manager.dart';
import 'package:ai_art/artproject/gallery_database_helper.dart';

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

      final snackBar = SnackBar(
        content: Text(result['isSuccess'] ? '作った絵を保存しました！' : '作った絵の保存に失敗しました'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      audioProvider.playSound("established.mp3");
    } else {
      // 権限が拒否された場合、警告メッセージを表示
      final snackBar = SnackBar(
        content: Text('写真ライブラリへのアクセスが許可されていません。設定を確認してください。'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
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

      final snackBar = SnackBar(
        content:
            Text(result['isSuccess'] ? 'お絵描きした絵を保存しました！' : 'お絵描きした絵の保存に失敗しました'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      audioProvider.playSound("established.mp3");
    } else {
      // 権限が拒否された場合、警告メッセージを表示
      final snackBar = SnackBar(
        content: Text('写真ライブラリへのアクセスが許可されていません。設定を確認してください。'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
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

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '削除の確認',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontsize,
            ),
          ),
          content: Text(
            'この作品を削除してもよろしいですか？',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontsize,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'キャンセル',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontsize,
                    color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                audioProvider.playSound("tap1.mp3");
              },
            ),
            TextButton(
              child: Text(
                '削除',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontsize,
                    color: Colors.white),
              ),
              onPressed: () async {
                // データベースから削除
                await GalleryDatabaseHelper.instance.delete(widget.data['_id']);
                audioProvider.playSound("tap1.mp3");

                // スナックバーで削除完了を表示
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('作品を削除しました')),
                );

                Navigator.of(context).pop(); // ダイアログを閉じる
                Navigator.pushNamed(context, '/gallery');
              },
            ),
          ],
        );
      },
    );
  }

  void _showPhotoAndEmotionModal() {
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    Size screenSize = MediaQuery.sizeOf(context);
    double fontsize = screenSize.width / 74.6;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "詳細な感情: ${widget.data['detailemotion'] ?? '不明'}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontsize,
                  ),
                ),
                SizedBox(height: 20),
                if (photoImage != null && photoImage!.isNotEmpty) ...[
                  Text(
                    "参考にした写真",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: fontsize,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: (screenSize.width ~/ 6.948).toDouble(),
                    width: (screenSize.width ~/ 5.208).toDouble(),
                    child: Image.memory(
                      photoImage!,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
                SizedBox(height: 20),
                TextButton(
                  onPressed: () async {
                    audioProvider.playSound("tap1.mp3");
                    Navigator.pushNamed(context, '/gallery');
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
    outputImage = widget.data['outputimage'];
    drawingImage = widget.data['drawingimage'];
    photoImage = widget.data['photoimage'];
    String title = widget.data['title'] ?? "無題";
    String emotion = widget.data['emotion'] ?? "無題";
    String detailemotion = widget.data['detailemotion'] ?? "無題";
    String time = widget.data['time'] ?? "不明";
    Size screenSize = MediaQuery.sizeOf(context);
    double fontsize = screenSize.width / 74.6;

    return Scaffold(
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
                "作成日時: $time",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: fontsize,
                ),
              ),
              SizedBox(width: 50),
              Text(
                "感情: $emotion",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: fontsize,
                ),
              ),
            ]),
            /*
            Text(
              "詳細な感情: $detailemotion",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontsize,
              ),
            ),*/

            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("作った絵だよ！",
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
                      '作った絵を保存する',
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
                  Text("お絵描きした絵だよ！",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: fontsize)),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: GestureDetector(
                      onTap: () {
                        if (drawingImage != null) {
                          // 画像が存在する場合、タップしてモーダルを表示
                          _showImageModal(context, MemoryImage(drawingImage!));
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
                      'お絵描きした絵を保存する',
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
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 255, 67, 195),
                  ),
                  child: Text(
                    "戻る",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontsize,
                        color: Colors.white),
                  ),
                ),
                SizedBox(width: 20),
                TextButton(
                  onPressed: _showPhotoAndEmotionModal,
                  style: TextButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 255, 67, 195),
                  ),
                  child: Text(
                    "詳細を見る",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontsize,
                        color: Colors.white),
                  ),
                ),
                SizedBox(width: 20),
                TextButton(
                  onPressed: _showDeleteConfirmDialog,
                  style: TextButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 255, 67, 195),
                  ),
                  child: Text(
                    "削除する",
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
}
