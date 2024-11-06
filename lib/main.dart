import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:ai_art/screens/main_page.dart";
import "package:ai_art/screens/generate_page.dart";
import "package:ai_art/screens/drawing_page.dart";
import "package:ai_art/screens/output_page.dart";

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])
      .then((_) {
    runApp(const MyApp());
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
      },
    );
  }
}
