import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Column(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text('AIが好きな絵と写真を組み合わせて自動描画してくれます'),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
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
            padding: EdgeInsets.all(10.0),
            child: Text('好きなドリンクとアートを組み合わせると？？？'),
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
