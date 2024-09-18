import 'package:google_sign_in/google_sign_in.dart';
import 'package:wellmed/Map//mainlocation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Import for toast messages
import 'login.dart'; // Import login.dart
// Import the HomePage widget

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance; // FirebaseAuth instance
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isChecked = false;

  void _signUp() async {
    if (!_isChecked) {
      // Show a message to agree with terms and conditions
      Fluttertoast.showToast(
        msg: "Please agree with the terms and conditions.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (!_validateEmail(email)) {
      Fluttertoast.showToast(
        msg: "Please enter a valid email address.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    if (!_validatePassword(password)) {
      Fluttertoast.showToast(
        msg: "Password must be between 3 and 15 characters.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Add additional user information to Firebase (e.g., display name)
      if (userCredential.user != null) {
        await userCredential.user!
            .updateDisplayName(_nameController.text.trim());
        await userCredential.user!.reload();
      }

      // Show success toast message
      Fluttertoast.showToast(
        msg: "User signed up successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      // Navigate to HomePage after a short delay
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainLocation()),
        );
      });
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(
        msg: "Error: ${e.message}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  bool _validateEmail(String email) {
    // Simple email validation
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(email);
  }

  bool _validatePassword(String password) {
    // Password must be between 3 and 15 characters
    return password.length >= 3 && password.length <= 15;
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
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 50.0, left: 24.0, right: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Create Account',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Fill your information below or register with your social account.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 32),
              TextField(
                controller: _nameController, // Controller for Name
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _emailController, // Controller for Email
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController, // Controller for Password
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
              SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _isChecked,
                    checkColor: Colors.white,
                    activeColor: Color(0xFF0000FF),
                    onChanged: (value) {
                      setState(() {
                        _isChecked = value!;
                      });
                    },
                  ),
                  Text('Agree with '),
                  GestureDetector(
                    onTap: () {
                      // Navigate to Terms & Conditions
                    },
                    child: Text(
                      'Terms & Condition',
                      style: TextStyle(
                        color: Color(0xFF0000FF),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Color(0xFF0000FF), // background
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _signUp, // Call _signUp method
                child: Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: Divider(thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('Or Sign up with'),
                  ),
                  Expanded(child: Divider(thickness: 1)),
                ],
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SignInButton(
                    imagePath: 'assets/images/apple.png',
                    onPressed: () {
                      // Apple sign-up logic
                    },
                  ),
                  SizedBox(width: 24),
                  SignInButton(
                    imagePath: 'assets/images/google.png',
                    onPressed: () =>
                        _signInWithGoogle(context), // Google sign-in logic
                  ),
                  SizedBox(width: 24),
                  SignInButton(
                    imagePath: 'assets/images/facebook.png',
                    onPressed: () {
                      // Facebook sign-up logic
                    },
                  ),
                ],
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  // Navigate to Sign In page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignInScreen()),
                  );
                },
                child: RichText(
                  text: TextSpan(
                    text: 'Already have an account? ',
                    style: TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: 'Sign In',
                        style: TextStyle(
                          color: Color(0xFF0000FF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
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
