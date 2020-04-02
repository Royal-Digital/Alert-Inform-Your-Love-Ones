import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';

import 'contactsMangement/addContacts.dart';
import 'login.dart';

class AlertSplashScreen extends StatefulWidget {
  @override
  _AlertSplashScreenState createState() => _AlertSplashScreenState();
}

class _AlertSplashScreenState extends State<AlertSplashScreen> {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      gradientBackground: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xff0D2C4F),
            Color(0xff0D2C4F),
            Color(0xff1D2631),
            Color(0xff1D2631),
          ]),
      photoSize: MediaQuery.of(context).size.height * .25,
      seconds: 3,
      image: Image.asset(
        'assets/alertlogo.png',
        fit: BoxFit.contain,
      ),
      loaderColor: Colors.white,
      loadingText: Text(
        "Multi Telesoft Pvt Ltd.",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      ),
      navigateAfterSeconds: AuthCheck(),
    );
  }
}

class AuthCheck extends StatelessWidget {
  Future getCurrentUser(BuildContext context) async {
    FirebaseUser _user = await FirebaseAuth.instance.currentUser();
    FirebaseUser myUser = _user;
    if (myUser != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddContacts(user: myUser),
          ));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
    }
    return _user;
  }

  @override
  Widget build(BuildContext context) {
    getCurrentUser(context);
    return Container();
  }
}
