import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // Import Google Mobile Ads
import 'package:provider/provider.dart';
import "package:ai_art/screens/main_page.dart";
import "package:ai_art/screens/generate_page.dart";
import "package:ai_art/screens/drawing_page.dart";
import "package:ai_art/screens/output_page.dart";
import "package:ai_art/screens/tutorial_page.dart";
import "package:ai_art/screens/image_gallery_page.dart";
import 'package:ai_art/artproject/audio_provider.dart';
import 'package:ai_art/artproject/language_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize(); // Initialize the Google Mobile Ads SDK
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])
      .then((_) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => AudioProvider()),
          ChangeNotifierProvider(create: (context) => LanguageProvider()), // 追加
        ],
        child: MyApp(),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'まじっくくれぱす',
      initialRoute: '/',
      routes: {
        '/': (context) => const MainPage(),
        '/generate': (context) => const GeneratePage(),
        '/drawing': (context) => const DrawingPage(),
        '/output': (context) => const OutputPage(),
        '/tutorial': (context) => const TutorialPage(),
        '/gallery': (context) => const GalleryPage(),
      },
    );
  }
}
