import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth import
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wellmed/Screens/HomePage.dart';

import 'onboarding.dart'; // Import for SharedPreferences

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingAndUser();
  }

  // Function to check if onboarding is completed and the user is logged in
  void _checkOnboardingAndUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isOnboardingCompleted = prefs.getBool('onboarding_completed');

    // Simulate a delay for the splash screen
    await Future.delayed(Duration(seconds: 3));

    if (isOnboardingCompleted == true) {
      _checkUser();
    } else {
      // Navigate to OnboardingScreen if onboarding not completed
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    }
  }

  // Function to check if the user is logged in or it's their first time
  void _checkUser() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is already logged in, navigate to HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      // User is not logged in, navigate to OnboardingScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    }
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