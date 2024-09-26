import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Auth/login.dart'; // Import your login screen

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  List<Widget> _buildPageIndicators() {
    return List<Widget>.generate(3, (int index) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        height: 10.0,
        width: index == currentPage ? 20.0 : 10.0,
        decoration: BoxDecoration(
          color: index == currentPage ? const Color(0xFF0000FF) : Colors.grey,
          borderRadius: BorderRadius.circular(5.0),
        ),
      );
    });
  }

  Future<void> _completeOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
        'onboarding_completed', true); // Set onboarding complete flag
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (_) => LoginScreen()), // Navigate to login screen
    );
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
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec vel felis nec magna consequat tincidunt.',
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
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec vel felis nec magna consequat tincidunt.',
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
                    ? const SizedBox.shrink()
                    : Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent, // No fill color
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF0000FF), // Stroke color
                      width: 2.0, // Stroke width
                    ),
                  ),
                  child: IconButton(
                    icon:
                    const Icon(Icons.arrow_back, color: Color(0xFF0000FF)),
                    onPressed: () {
                      _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease);
                    },
                  ),
                ),
                Row(
                  children: _buildPageIndicators(),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF0000FF), // Filled background color
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_forward, color: Colors.white),
                    onPressed: () {
                      if (currentPage < 2) {
                        _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease);
                      } else {
                        // Complete onboarding
                        _completeOnboarding(); // Call the method to complete onboarding
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
                // Skip to the login screen and mark onboarding as complete
                _completeOnboarding();
              },
              child: const Text(
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
          const SizedBox(height: 20.0),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0000FF),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10.0),
          Text(
            description,
            style: const TextStyle(
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