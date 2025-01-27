import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_art/artproject/gallery_database_helper.dart';
import 'package:ai_art/artproject/audio_provider.dart';
import 'dart:typed_data';

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
    // Fetch the list of drawings when the page is initialized
    _drawingsFuture = GalleryDatabaseHelper.instance.fetchDrawings();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    double fontsizeBig = screenSize.width / 64;
    double fontsize = screenSize.width / 74.6;
    final audioProvider = Provider.of<AudioProvider>(context);
    Uint8List? outputImagecheck;
    String? Lengthdb;

    double imageWidth = screenSize.width / 6 - 10; // Adjusted for spacing
    double imageHeight = imageWidth;

    return Scaffold(
      body: GestureDetector(
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 20),
              Text(
                '今まで作った絵を見れるよ～',
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
                    return const Text('No images available.');
                  } else {
                    List<Map<String, dynamic>> drawings = snapshot.data!;
                    outputImagecheck = drawings[0]['drawingimage'];
                    return Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              6, // You can change the number of columns
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: drawings.length,
                        itemBuilder: (context, index) {
                          Uint8List? outputImage = drawings[index]['photo'];
                          Lengthdb = drawings.length.toString();
                          if (outputImage == null || outputImage.isEmpty) {
                            // Fallback to indicate invalid image data
                            return Container(
                              color: Colors.grey,
                              child: const Center(
                                child: Text("Invalid Image"),
                              ),
                            );
                          }
                          return Container(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                outputImage,
                                width: imageWidth,
                                height: imageHeight,
                                fit: BoxFit
                                    .contain, // Changed from cover to prevent cropping
                              ),
                            ),
                          );
                          
                        },
                      ),
                    );
                  }
                },
              ),
              Text(Lengthdb);
              Text(outputImagecheck.toString()),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      audioProvider.playSound("tap1.mp3");
                      Navigator.pushNamed(context, '/');
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 67, 195),
                    ),
                    child: Text(
                      '閉じる',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontsize,
                        color: Colors.white,
                      ),
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
