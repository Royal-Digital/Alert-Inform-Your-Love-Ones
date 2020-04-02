import 'package:com/alertSuccess.dart';
import 'package:com/contactsMangement/addContacts.dart';
import 'package:com/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:splashscreen/splashscreen.dart';
import 'alertSplashScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xff0D2C4F),
        backgroundColor: Color(0xff0D2C4F),
      ),
      home: AlertSplashScreen(),
      routes: {
        '/login': (context) => Login(),
        '/addContacts': (context) => AddContacts(),
        '/alertSuccess': (context) => AlertSuccess()
      },
    );
  }
}

