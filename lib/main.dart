import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Map/map.dart';
import 'Screens/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return ChangeNotifierProvider(
            create: (_) => MapProvider(),
            child: MaterialApp(
              home: SplashScreen(), // Starts with the SplashScreen
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(
              child: Text('Error initializing Firebase: ${snapshot.error}'));
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
