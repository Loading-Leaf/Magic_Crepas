import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import "package:ai_art/screens/main_page.dart";
import "package:ai_art/screens/generate_page.dart";
import "package:ai_art/screens/drawing_page.dart";
import "package:ai_art/screens/output_page.dart";
import "package:ai_art/screens/tutorial_page.dart";
import 'package:ai_art/artproject/audio_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])
      .then((_) {
    runApp(
      ChangeNotifierProvider(
        create: (context) => AudioProvider(),
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
      title: 'AI X ART',
      initialRoute: '/',
      routes: {
        '/': (context) => const MainPage(),
        '/generate': (context) => const GeneratePage(),
        '/drawing': (context) => const DrawingPage(),
        '/output': (context) => const OutputPage(),
        '/tutorial': (context) => const TutorialPage(),
      },
    );
  }
}
