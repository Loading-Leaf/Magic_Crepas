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

//画像シェア用
import 'package:share_plus/share_plus.dart';
import 'package:flutter/scheduler.dart';
import 'dart:io' show Platform;
import 'package:path_provider/path_provider.dart';

class GalleryDetailPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const GalleryDetailPage({super.key, required this.data});

  @override
  _GalleryDetailPageState createState() => _GalleryDetailPageState();
}

class _GalleryDetailPageState extends State<GalleryDetailPage> {
  Uint8List? outputImage = Uint8List(0); //生成した後の画像
  Uint8List? drawingImage = Uint8List(0); //描画した絵
  Uint8List? photoImage = Uint8List(0); //端末の写真アプリで選んだ写真
  String your_detailemotion = ""; //詳しい気持ち
  String your_platform = ""; //使用している端末

  Future<void> checkDevice() async {
    final deviceInfo = DeviceInfoPlugin();
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    //保存時、それぞれの端末ごとに文言を変更
    //例えばiPhoneの場合は「スマホ」,iPadの場合は「アイパッド」と表示
    //使用する場面は「○○に保存」と記載するボタンで使用
    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      setState(() {
        if (iosInfo.model.toLowerCase().contains("ipad")) {
          your_platform =
              languageProvider.locallanguage == 2 ? "Tablet" : "タブレット";
        } else {
          your_platform = languageProvider.locallanguage == 2 ? "Phone" : "スマホ";
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
          your_platform = languageProvider.locallanguage == 2 ? "Other" : "その他";
        } else if (androidInfo.model.toLowerCase().contains("tablet") ||
            androidInfo.product.toLowerCase().contains("tablet")) {
          your_platform =
              languageProvider.locallanguage == 2 ? "Tablet" : "タブレット";
        } else {
          your_platform = languageProvider.locallanguage == 2 ? "Phone" : "スマホ";
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkDevice();
  }

  Future<void> shareImages(
      BuildContext context,
      Uint8List image1, //生成画像
      Uint8List image2, //描画した絵
      String time, //ライブラリに保存した日時
      String title, //作品名
      String your_emotion, //描いた時の気持ち
      String detail_emotion, //描いた時の詳細な気持ち→言葉で表現
      LanguageProvider languageProvider) async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      final outputImagePath =
          '${directory.path}/output_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final drawingImagePath =
          '${directory.path}/drawing_image_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await File(outputImagePath).writeAsBytes(image1);
      await File(drawingImagePath).writeAsBytes(image2);

      final files = <XFile>[XFile(outputImagePath), XFile(drawingImagePath)];

      String content = "";
      //見やすくするために改行を用意
      if (time != "") {
        content += languageProvider.locallanguage == 2
            ? "Date: "
            : "作成日時: " + time + "\n";
      }

      if (title != "") {
        content += languageProvider.locallanguage == 2
            ? "Title: "
            : "タイトル: " + title + "\n";
      }
      if (your_emotion != "") {
        content += languageProvider.locallanguage == 2
            ? "Emotion: "
            : "あなたの気持ち: " + your_emotion + "\n";
      }

      if (detail_emotion != "") {
        content += languageProvider.locallanguage == 2
            ? "Detail:"
            : "詳細な気持ち: " + detail_emotion + "\n";
      }

      // UIフレームの描画後にRenderBoxを取得
      SchedulerBinding.instance.addPostFrameCallback((_) {
        final mediaQuery = MediaQuery.of(context);

        //iPadでシェアする際、場所を設定しないとshare_plusが使えなくなる
        //sharePositionOriginで画面の位置を設定しないと右下に表示されて画面上にシェアするUIが表示されない
        //中央に設置する際、画面の3分の1の座標に設置
        Rect sharePositionOrigin = Rect.fromCenter(
          center: Offset(mediaQuery.size.width / 3, mediaQuery.size.height / 3),
          width: 200,
          height: 200,
        );
        Share.shareXFiles(
          files,
          text: languageProvider.locallanguage == 2
              ? "I created this art from photos and drawings!\n" +
                  content +
                  "\n #MagicCraypas #Memory"
              : '写真とお絵描きからこんなアートができたよ！\n' + content + '\n#まじっくくれぱす #思い出',
          subject: languageProvider.locallanguage == 2
              ? "Generated Art via MagicCraypas\n"
              : 'まじっくくれぱすで作った絵',
          sharePositionOrigin: sharePositionOrigin,
        ).then((_) async {
          // 共有後に一時ファイルを削除
          await File(outputImagePath).delete();
          await File(drawingImagePath).delete();
        });
      });
    } catch (e) {
      final snackBar = SnackBar(
        content: Text(languageProvider.locallanguage == 2
            ? "Sorry! Occured an error during saving: $e"
            : '画像の共有中にエラーが発生しました: $e'),
        duration: Duration(seconds: 3),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> saveImage() async {
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);

    if (outputImage == null) return;

    // 写真ライブラリの権限を確認・リクエスト
    //設定アプリで写真のアクセスを全て許可しなければいけない
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
          message3: result['isSuccess']
              ? 'Success to save😊'
              : 'Failed to save😭\nPlease check settings⚙️',
        ),
      );
      audioProvider.playSound("established.mp3");
    } else {
      // 権限が拒否された場合、警告メッセージを表示
      //保存できない際、保護者に尋ねる文言を追加
      showDialog(
        context: context,
        builder: (context) => const SomethingDisconnectDialog(
          message1:
              'しゃしんライブラリへのアクセスができないよ😢\nおとうさんとおかあさんにはなして、\nいっしょにせっていをかくにんしてね⚙️',
          message2: '写真ライブラリへのアクセスが許可されていません😢\n設定を確認してください⚙️',
          message3: 'Failed to access😢\nPlease check settings⚙️',
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
          message3: result['isSuccess']
              ? 'Success to save😊'
              : 'Failed to save😭\nPlease check settings⚙️',
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
          message3: 'Failed to access😢\nPlease check settings⚙️',
        ),
      );
    }
  }

  //アプリのUIの都合上、写真を大きくすることは困難
  //そこで写真をタップしたら大きく見れるかつ拡大縮小できるInteractiveViewerを実装
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

  //削除確認のためのモーダル
  Future<void> _showDeleteConfirmDialog() async {
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    Size screenSize = MediaQuery.sizeOf(context);
    double fontsize = screenSize.width / 74.6;
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            languageProvider.locallanguage == 2
                ? "Delete"
                : languageProvider.isHiragana
                    ? 'さくじょする'
                    : '削除する',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontsize,
            ),
          ),
          content: Text(
            languageProvider.locallanguage == 2
                ? "Is it okay to delete this work?"
                : languageProvider.isHiragana
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
                languageProvider.locallanguage == 2
                    ? "Back"
                    : languageProvider.isHiragana
                        ? 'もどる'
                        : '戻る',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontsize,
                    color: Colors.white),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 0, 204, 255),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                audioProvider.playSound("tap1.mp3");
              },
            ),
            TextButton(
              child: Text(
                languageProvider.locallanguage == 2
                    ? "Delete"
                    : languageProvider.isHiragana
                        ? 'さくじょする'
                        : '削除する',
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
                //削除する際は、保存したアートに該当する配列番号ごと削除
                await GalleryDatabaseHelper.instance.delete(widget.data['_id']);
                audioProvider.playSound("tap1.mp3");

                Navigator.pushNamed(context, '/gallery');

                showDialog(
                  context: context,
                  builder: (context) => const SomethingDisconnectDialog(
                    message1: 'さくじょしたよ',
                    message2: '削除したよ',
                    message3: "Success to deleted",
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  //UIによる漏れを防ぐため、詳細な気持ちを改行して表示
  String _getFormattedText(String input, int maxLength) {
    List<String> lines = [];
    for (int i = 0; i < input.length; i += maxLength) {
      lines.add(input.substring(
          i, i + maxLength > input.length ? input.length : i + maxLength));
    }
    return lines.join('\n'); // Join lines with a newline
  }

  //詳細な気持ちと元写真を使用すると画面に収まりきらないので、別途モーダルを用意
  void _showPhotoAndEmotionModal() {
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    Size screenSize = MediaQuery.sizeOf(context);
    double fontsize = screenSize.width / 74.6;
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: screenSize.width * 0.8,
            height: screenSize.height * 0.95,
            padding: EdgeInsets.all(20),
            //Columnにすると見れなくなるエラーが発生する。
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      languageProvider.locallanguage == 2
                          ? "Detail"
                          : languageProvider.isHiragana
                              ? 'しょうさいなきもち'
                              : "詳細な気持ち",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontsize,
                      ),
                    ),
                    SizedBox(height: 10),
                    //詳細な気持ちを表示
                    Text(
                      _getFormattedText(your_detailemotion, 15), //１行ごと15文字まで表示
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontsize,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 20),
                if (photoImage != null && photoImage!.isNotEmpty) ...[
                  Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(
                      languageProvider.locallanguage == 2
                          ? "Used photo"
                          : languageProvider.isHiragana
                              ? "つかったしゃしん"
                              : "使った写真",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontsize,
                      ),
                    ),
                    SizedBox(width: 5),
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
                  ]),
                ],
                SizedBox(width: 20),
                TextButton(
                  onPressed: () async {
                    audioProvider.playSound("tap1.mp3");
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 0, 204, 255),
                  ),
                  child: Text(
                    languageProvider.locallanguage == 2
                        ? "Close"
                        : languageProvider.isHiragana
                            ? 'とじる'
                            : '閉じる',
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
    outputImage = widget.data['outputimage']; //生成した絵
    drawingImage = widget.data['drawingimage']; //描画した絵
    photoImage = widget.data['photoimage']; //選んだ写真
    String title = widget.data['title'] ?? "無題"; //タイトル
    String emotion = widget.data['emotion'] ?? "無題"; //感情
    String detailemotion = widget.data['detailemotion'] ?? "無題"; //詳細な気持ち
    your_detailemotion = detailemotion; //現時点ではグローバル変数として使用しているが、後に修正予定
    String time = widget.data['time'] ?? "不明"; //保存した時間帯
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
                languageProvider.locallanguage == 2 ? "Title" : "タイトル: $title",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: fontsize,
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  languageProvider.locallanguage == 2
                      ? "Date: $time"
                      : languageProvider.isHiragana
                          ? "さくせいにちじ: $time"
                          : "作成日時: $time",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontsize,
                  ),
                ),
                SizedBox(width: 50),
                Text(
                  languageProvider.locallanguage == 2
                      ? "Emotion: $emotion"
                      : languageProvider.isHiragana
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
                    Text(
                        languageProvider.locallanguage == 2
                            ? "Generated art"
                            : languageProvider.isHiragana
                                ? "つくったえ"
                                : "作った絵",
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
                        languageProvider.locallanguage == 2
                            ? "Save to $your_platform"
                            : languageProvider.isHiragana
                                ? '$your_platformにほぞんする'
                                : '$your_platformに保存する',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: fontsize,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                        languageProvider.locallanguage == 2
                            ? "Drawing"
                            : languageProvider.isHiragana
                                ? 'おえかきしたえ'
                                : "お絵描きした絵",
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
                        languageProvider.locallanguage == 2
                            ? "Save to $your_platform"
                            : languageProvider.isHiragana
                                ? '$your_platformにほぞんする'
                                : '$your_platformに保存する',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: fontsize,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 20),
                Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () => {
                          audioProvider.playSound("tap1.mp3"),
                          _showPhotoAndEmotionModal(),
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 255, 67, 195),
                        ),
                        child: Text(
                          languageProvider.locallanguage == 2
                              ? "Detail"
                              : languageProvider.isHiragana
                                  ? "くわしくみる"
                                  : "詳しく見る",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: fontsize,
                              color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextButton(
                        onPressed: () => {
                          audioProvider.playSound("tap1.mp3"),
                          _showDeleteConfirmDialog(),
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 255, 67, 195),
                        ),
                        child: Text(
                          languageProvider.locallanguage == 2
                              ? "Delete"
                              : languageProvider.isHiragana
                                  ? "さくじょする"
                                  : "削除する",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: fontsize,
                              color: Colors.white),
                        ),
                      ),
                    ]),
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
                      backgroundColor: Color.fromARGB(255, 0, 204, 255),
                    ),
                    child: Text(
                      languageProvider.locallanguage == 2
                          ? "Back"
                          : languageProvider.isHiragana
                              ? "もどる"
                              : "戻る",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontsize,
                          color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 20),
                  TextButton(
                    onPressed: () {
                      audioProvider.playSound("tap1.mp3");
                      if (outputImage != null && drawingImage != null) {
                        shareImages(
                            context,
                            outputImage!,
                            drawingImage!,
                            time,
                            title,
                            emotion,
                            detailemotion,
                            languageProvider); // 両方の画像をシェアする
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 255, 67, 195),
                    ),
                    child: Text(
                      languageProvider.locallanguage == 2 ? "Share" : 'シェアする',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontsize,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
