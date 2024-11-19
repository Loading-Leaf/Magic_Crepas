import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    print(screenSize.height);
    print(screenSize.width);
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0), // ここでPaddingを追加
            child: Container(
              alignment: Alignment.centerLeft, // 左寄せ
              child: Container(
                height: screenSize.height * 0.15,
                width: screenSize.width * 0.20,
                child: Image.asset('assets/title_logo_main.png'),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(5.0),
            child: Text('AIが好きな絵と写真で新しいアートを作ってくれるよ'),
          ),
          Padding(
            padding: EdgeInsets.all(5.0),
            child: Container(
              height: screenSize.width * 0.15,
              width: screenSize.width * 0.5,
              child: FittedBox(
                fit: BoxFit.fill,
                child: Image.asset('assets/title_image.png'),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(5.0),
            child: Text('好きなものとアートを組み合わせると？？？'),
          ),
          Container(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/generate');
              },
              style: TextButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 255, 67, 195),
              ),
              child: Text(
                'AIでアートを作る',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
