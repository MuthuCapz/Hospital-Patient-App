import 'package:flutter/material.dart';

import '../Auth/login.dart';
// Import your login screen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: OnboardingScreen(),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController _pageController = PageController();
  int currentPage = 0;

  List<Widget> _buildPageIndicators() {
    return List<Widget>.generate(3, (int index) {
      return AnimatedContainer(
        duration: Duration(milliseconds: 150),
        margin: EdgeInsets.symmetric(horizontal: 5.0),
        height: 10.0,
        width: index == currentPage ? 20.0 : 10.0,
        decoration: BoxDecoration(
          color: index == currentPage ? Color(0xFF0000FF) : Colors.grey,
          borderRadius: BorderRadius.circular(5.0),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                currentPage = page;
              });
            },
            children: [
              OnboardingPage(
                imagePath: 'assets/images/onboarding1.png',
                title: 'Learn About Your Doctors',
                description:
                    'Lorem ipsum dolor, consectetur adipiscing elit. Donec felis nec magna consequat tincidunt.',
              ),
              OnboardingPage(
                imagePath: 'assets/images/onboarding2.png',
                title: 'Effortless Appointment Booking',
                description:
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec vel felis nec magna consequat tincidunt.',
              ),
              OnboardingPage(
                imagePath: 'assets/images/onboarding3.png',
                title: 'Discover Experienced Doctors',
                description:
                    'Lorem ipsum dolor sit , consectetur adipiscing elit. Donec vel felis nec magna consequat tincidunt.',
              ),
            ],
          ),
          Positioned(
            bottom: 20.0,
            left: 20.0,
            right: 20.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                currentPage == 0
                    ? SizedBox.shrink()
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent, // No fill color
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Color(0xFF0000FF), // Stroke color
                            width: 2.0, // Stroke width
                          ),
                        ),
                        child: IconButton(
                          icon:
                              Icon(Icons.arrow_back, color: Color(0xFF0000FF)),
                          onPressed: () {
                            _pageController.previousPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.ease);
                          },
                        ),
                      ),
                Row(
                  children: _buildPageIndicators(),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF0000FF), // Filled background color
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_forward, color: Colors.white),
                    onPressed: () {
                      if (currentPage < 2) {
                        _pageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.ease);
                      } else {
                        // Navigate to the login screen
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => LoginScreen()),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 50.0,
            right: 20.0,
            child: GestureDetector(
              onTap: () {
                // Skip to the login screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              },
              child: Text(
                'Skip',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0000FF),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  OnboardingPage({
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, height: 300.0),
          SizedBox(height: 20.0),
          Text(
            title,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0000FF),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10.0),
          Text(
            description,
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
