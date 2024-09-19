import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home Page',
      home: MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home Page',
          style: TextStyle(color: Colors.white), // White text color
        ),
        backgroundColor: Color(0xFF0000FF), // Blue color for the AppBar
        iconTheme: IconThemeData(
          color: Colors.white, // White back arrow color
        ),
      ),
      body: Center(
        child: Text(
          'Welcome to the Home Page',
          style: TextStyle(fontSize: 23),
        ),
      ),
    );
  }
}
