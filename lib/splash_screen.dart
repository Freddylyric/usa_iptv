import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:usa_tv/channels_list.dart';


class SplashScreen extends StatefulWidget {



  SplashScreen({Key? key, }) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _loadScreen();
  }

  Future<void> _loadScreen() async {
    await Future.delayed(Duration(seconds: 3));

    Navigator.push(context, MaterialPageRoute(builder: (context) => ChannelsList()));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xff6a0e10),
      child: Stack(
        children: [
          CustomPaint(
            painter: ArcPainter(),
            child: Container(),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.45,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/appLogo.png',
                    width: 200,
                    height: 200,
                  ),
                  Text("© Fred Thee Dev 2023", style: GoogleFonts.alegreya(fontSize: 10, color: Colors.black),)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.white;

    Path path = Path();
    path.moveTo(0, size.height * 0.45);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.4, size.width * 0.75, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}