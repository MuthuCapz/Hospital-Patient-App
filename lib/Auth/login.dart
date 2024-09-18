import 'package:google_sign_in/google_sign_in.dart';
import 'package:wellmed/Map/mainlocation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'signup.dart';

import 'package:fluttertoast/fluttertoast.dart'; // Import for toast notifications

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SignInScreen(),
    );
  }
}

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // Initialize GoogleSignIn

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  void _signIn(BuildContext context) async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (!_validateEmail(email) || !_validatePassword(password)) {
      _showToast(context, "Please enter a valid email and password");
      return;
    }

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        _showToast(context, "Login successful!");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainLocation()),
        );
      }
    } on FirebaseAuthException catch (e) {
      _showToast(context, "Error: ${e.message}");
    }
  }

  bool _validateEmail(String email) {
    return email.isNotEmpty && email.contains('@');
  }

  bool _validatePassword(String password) {
    return password.isNotEmpty && password.length >= 3 && password.length <= 15;
  }

  void _showToast(BuildContext context, String message) {
    Fluttertoast.cancel(); // Cancel any existing toast messages
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text;

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your Email')),
      );
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent!')),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred. Please try again later.';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email. Please sign up.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      // Ensure the user is signed out of Google Sign-In
      await _googleSignIn.signOut();

      // Initiate the Google Sign-In process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return; // The user canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      // Navigate to CompleteProfileScreen after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainLocation()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 60),
                      Text(
                        'Sign in',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Hi! Welcome back, you’ve been missed",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 30),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller:
                            _passwordController, // Controller for Password
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            _resetPassword();

                            // Add forgot password functionality
                          },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Color(0xFF0000FF),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0000FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () => _signIn(context),
                          child: Text(
                            'Sign In',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'Or Sign in with',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                          Expanded(
                            child: Divider(),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SignInButton(
                            imagePath: 'assets/images/apple.png',
                            onPressed: () {
                              // Add Apple sign-in functionality
                            },
                          ),
                          SignInButton(
                            imagePath: 'assets/images/google.png',
                            onPressed: () => _signInWithGoogle(context),
                          ),
                          SignInButton(
                            imagePath: 'assets/images/facebook.png',
                            onPressed: () {
                              // Add Facebook sign-in functionality
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      GestureDetector(
                        onTap: () {
                          // Navigate to the SignUpScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpPage()),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            text: "Don’t have an account? ",
                            style: TextStyle(color: Colors.black),
                            children: [
                              TextSpan(
                                text: "Sign Up",
                                style: TextStyle(
                                  color: Color(0xFF0000FF),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SignInButton extends StatelessWidget {
  final String imagePath;
  final VoidCallback onPressed;

  const SignInButton({
    required this.imagePath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: CircleAvatar(
        backgroundColor: Colors.grey[200],
        radius: 25,
        child: Image.asset(
          imagePath,
          height: 25,
        ),
      ),
    );
  }
}
