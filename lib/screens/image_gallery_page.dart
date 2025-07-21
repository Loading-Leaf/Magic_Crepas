import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_art/artproject/gallery_database_helper.dart';
import 'package:ai_art/artproject/audio_provider.dart';
import 'dart:typed_data';
import 'gallery_detail_page.dart'; // ← 追加
import 'package:ai_art/artproject/language_provider.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  late Future<List<Map<String, dynamic>>> _drawingsFuture;

  @override
  void initState() {
    super.initState();
    _drawingsFuture = GalleryDatabaseHelper.instance.fetchDrawings();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context); //画面の情報を習得: MediaQuery.sizeOf
    double fontsizeBig = screenSize.width / 64;
    double fontsize = screenSize.width / 74.6;
    final audioProvider = Provider.of<AudioProvider>(context);

    double imageWidth = screenSize.width / 6 - 10;
    double imageHeight = imageWidth;
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    return PopScope(
      // ここを追加
      canPop: false, // false で無効化
      child: Scaffold(
        body: GestureDetector(
          child: SizedBox.expand(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 20),
                Text(
                  languageProvider.locallanguage == 2 ? "Gallery" : 'ギャラリー',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontsizeBig,
                  ),
                ),
                Text(
                  languageProvider.locallanguage == 2
                      ? "You can see arts😊"
                      : languageProvider.isHiragana
                          ? 'いままでつくったえをみれるよ😊'
                          : '今まで作った絵を見れるよ😊',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontsizeBig,
                  ),
                ),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _drawingsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text(languageProvider.locallanguage == 2
                          ? "There are no pictures yet😢"
                          : 'まだないよ😢');
                    } else {
                      List<Map<String, dynamic>> drawings = snapshot.data!;
                      return Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: drawings.length,
                          //indexは作品を削除する際に使用
                          itemBuilder: (context, index) {
                            Uint8List? outputImage = drawings[index]
                                ['outputimage']; //ここでは生成画像のみをディスプレイに表示
                            if (outputImage == null || outputImage.isEmpty) {
                              //もしなかったらgreyのみの画像を表示
                              return Container(
                                color: Colors.grey,
                                child:
                                    const Center(child: Text("Invalid Image")),
                              );
                            }
                            return GestureDetector(
                              onTap: () {
                                audioProvider.playSound("tap1.mp3");
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GalleryDetailPage(
                                        data: drawings[index]),
                                  ), //GalleryDetailPageという個別化したページに遷移する→その際、取得したindexを指定してページ遷移
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  outputImage,
                                  width: imageWidth,
                                  height: imageHeight,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        audioProvider.playSound("tap1.mp3");
                        Navigator.pushNamed(context, '/menu');
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 0, 204, 255),
                      ),
                      child: Text(
                        languageProvider.locallanguage == 2
                            ? "Back"
                            : languageProvider.isHiragana
                                ? 'ホームにもどる'
                                : 'ホームに戻る',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontsize,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
