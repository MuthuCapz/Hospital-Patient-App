import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
// Import the login screen
import 'package:wellmed/Screens/YourProfile.dart';
import '../Auth/login.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late DocumentReference _profileRef;
  late String userId;
  String? profileImageUrl;
  File? _image;

  @override
  void initState() {
    super.initState();
    userId = _auth.currentUser!.uid;
    _profileRef = FirebaseFirestore.instance.collection('Profile').doc(userId);
    _getProfileData();
  }

  // Retrieve profile image from Firestore
  Future<void> _getProfileData() async {
    final docSnapshot = await _profileRef.get();
    if (docSnapshot.exists) {
      setState(() {
        profileImageUrl = docSnapshot['profile_image'] as String?;
      });
    }
  }

  // Image picker for selecting profile image
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _uploadImage();
    }
  }

  // Upload the selected image to Firebase Storage and update Firestore
  Future<void> _uploadImage() async {
    if (_image == null) return;

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('profile_images')
        .child('$userId.jpg');
    await storageRef.putFile(_image!);

    final imageUrl = await storageRef.getDownloadURL();
    await _profileRef.update({'profile_image': imageUrl});

    setState(() {
      profileImageUrl = imageUrl;
    });
  }

  // Function to log out the user
  Future<void> _logout() async {
    await _auth.signOut(); // Log out from Firebase

    // Navigate to login.dart after logout
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              LoginScreen()), // Assuming the login screen is called LoginScreen
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0000FF),
        elevation: 0,
        title: Padding(
          padding:
              const EdgeInsets.only(left: 40.0), // 40dp padding to the left
          child: Text(
            'My Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: profileImageUrl != null
                      ? NetworkImage(profileImageUrl!)
                      : AssetImage('assets/default_profile.png')
                          as ImageProvider,
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildProfileOption(
                  icon: Icons.person,
                  title: 'Your Profile',
                  onTap: () {
                    // Navigate to profile details
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Profile()),
                    );
                  },
                ),
                _buildProfileOption(
                  icon: Icons.description,
                  title: 'My documents',
                  onTap: () {
                    // Navigate to documents
                  },
                ),
                _buildProfileOption(
                  icon: Icons.settings,
                  title: 'Settings',
                  onTap: () {
                    // Navigate to settings
                  },
                ),
                _buildProfileOption(
                  icon: Icons.help_outline,
                  title: 'Help centre',
                  onTap: () {
                    // Navigate to help center
                  },
                ),
                _buildProfileOption(
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: _logout, // Call the logout function
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(
      {required IconData icon,
      required String title,
      required Function() onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 10),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          leading: Icon(icon, color: Color(0xFF0000FF)),
          title: Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          trailing: Icon(Icons.arrow_forward_ios, color: Colors.black54),
        ),
      ),
    );
  }
}
