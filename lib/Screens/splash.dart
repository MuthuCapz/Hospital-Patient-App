
import 'package:flutter/material.dart';
import 'dart:async';

import 'onboarding.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Using a Timer to navigate to the SignUpScreen after 3 seconds
    Timer(Duration(seconds: 3), () {
      // Ensure the context is within the MaterialApp tree
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1612F0),
      body: Center(
        child: Text(
          'WellMed',
          style: TextStyle(
            fontSize: 24,
            fontFamily: 'Nunito', // Set the Nunito font here
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
