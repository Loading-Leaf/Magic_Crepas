import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_art/artproject/drawing_gallery_database_helper.dart';
import 'package:ai_art/artproject/audio_provider.dart';
import 'dart:io';
import 'package:ai_art/artproject/language_provider.dart';

class DrawingGalleryPage extends StatefulWidget {
  const DrawingGalleryPage({super.key});

  @override
  State<DrawingGalleryPage> createState() => _DrawingGalleryPageState();
}

class _DrawingGalleryPageState extends State<DrawingGalleryPage> {
  late Future<List<Map<String, dynamic>>> _drawingsFuture;

  @override
  void initState() {
    super.initState();
    _drawingsFuture = DrawingGalleryDatabaseHelper.instance.fetchDrawings();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    double fontsizeBig = screenSize.width / 64;
    double fontsize = screenSize.width / 74.6;
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);

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
                  languageProvider.isHiragana
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
                      print(snapshot.data);
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('まだないよ😢');
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
                          itemBuilder: (context, index) {
                            final outputImagePath =
                                drawings[index]['drawingimage'] as String?;
                            if (outputImagePath == null) {
                              return Container(
                                color: Colors.grey,
                                child:
                                    const Center(child: Text("Invalid Image")),
                              );
                            }
                            final outputImageFile = File(outputImagePath);
                            return GestureDetector(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  outputImageFile,
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
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        audioProvider.playSound("tap1.mp3");
                        Navigator.pushNamed(context, '/preparegallery');
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 0, 204, 255),
                      ),
                      child: Text(
                        languageProvider.isHiragana ? 'ホームに戻る' : 'ホームに戻る',
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
