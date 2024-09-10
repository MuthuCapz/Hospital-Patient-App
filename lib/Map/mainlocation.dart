import 'package:flutter/material.dart';

import 'manuallocationscreen.dart';
import 'map.dart';
// Import your map.dart file

class MainLocation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFE3E7FD), // Light purple background color
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(30.0),
              child: Icon(
                Icons.location_on,
                size: 60.0,
                color: Color(0xFF0000FF), // Blue color for the icon
              ),
            ),
            SizedBox(height: 30.0),
            Text(
              "What is your location",
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              "To provide you with nearby services,\nwe need access to your location.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 40.0),
            ElevatedButton(
              onPressed: () {
                // Navigate to the MapPage when the button is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          MapScreen()), // Replace with your map page widget
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0000FF), // Blue button color
                padding: EdgeInsets.symmetric(horizontal: 60.0, vertical: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              child: Text(
                "Allow Location Access",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
            ),
            SizedBox(height: 20.0),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ManualLocationScreen()), // Replace with your map page widget
                );
                // Handle Enter Location Manually
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Color(0xFF0000FF), width: 2.0),
                padding: EdgeInsets.symmetric(horizontal: 55.0, vertical: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              child: Text(
                "Enter Location Manually",
                style: TextStyle(
                  color: Color(0xFF0000FF), // Blue text color
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MainLocation(),
  ));
}
