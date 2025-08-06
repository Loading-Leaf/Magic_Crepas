import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import "package:ai_art/artproject/terms_of_service.dart";
import 'package:ai_art/artproject/audio_provider.dart';
import 'package:ai_art/artproject/effect_utils.dart';
import 'package:ai_art/artproject/language_provider.dart';

class LessonPage extends StatefulWidget {
  const LessonPage({super.key});

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    double fontsize_big = screenSize.width / 64;
    double fontsize = screenSize.width / 74.6;
    final audioProvider = Provider.of<AudioProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Lesson モード', style: TextStyle(fontSize: fontsize_big)),
          centerTitle: true,
          bottom: TabBar(
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            tabs: const [
              Tab(text: '色を混ぜる'),
              Tab(text: '色のクイズ'),
            ],
            controller: TabController(length: 2, vsync: ScaffoldState()),
            // ダミー: 実際は下で切り替え
          ),
          toolbarHeight: 60,
        ),
        body: _selectedIndex == 0
            ? _buildMixColorsPage(context, fontsize)
            : _buildColorQuizPage(context, fontsize),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.color_lens), label: '色を混ぜる'),
            BottomNavigationBarItem(icon: Icon(Icons.quiz), label: '色のクイズ'),
          ],
        ),
      ),
    );
  }

  Widget _buildMixColorsPage(BuildContext context, double fontsize) {
    // 色を混ぜるページの簡易UI
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('2色を選んで混ぜてみよう', style: TextStyle(fontSize: fontsize)),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _colorCircle(Colors.red),
              SizedBox(width: 20),
              _colorCircle(Colors.blue),
            ],
          ),
          SizedBox(height: 20),
          Text('混ぜた色：', style: TextStyle(fontSize: fontsize)),
          SizedBox(height: 10),
          _colorCircle(Colors.purple), // 仮: 赤+青=紫
        ],
      ),
    );
  }

  Widget _buildColorQuizPage(BuildContext context, double fontsize) {
    // 色のクイズページの簡易UI
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('この色は何色？', style: TextStyle(fontSize: fontsize)),
          SizedBox(height: 20),
          _colorCircle(Colors.orange),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            child: Text('こたえを見る', style: TextStyle(fontSize: fontsize)),
          ),
        ],
      ),
    );
  }

  Widget _colorCircle(Color color) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black26, width: 2),
      ),
    );
  }
}
