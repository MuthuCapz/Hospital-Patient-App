import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';




class CompleteProfileScreen extends StatefulWidget {
  @override
  _CompleteProfileScreenState createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedGender = 'Select';
  final _genders = ['Select', 'Male', 'Female', 'Other'];
  File? _imageFile;

  Color primaryColor = Color(0xFF3366FF);
  Color backgroundColor = Colors.white;
  Color textColor = Colors.black;
  Color subtitleColor = Colors.grey[500]!;
  Color inputFillColor = Colors.white;
  Color inputBorderColor = Colors.grey[700]!;
  Color iconBackgroundColor = Color(0xFF3366FF);

  final ImagePicker _picker = ImagePicker();

  void _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    String name = _nameController.text.trim();
    String phoneNumber = _phoneController.text.trim();

    if (name.isEmpty || name.length > 20) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please enter a valid name (max 20 characters)"),
      ));
      return;
    }

    if (phoneNumber.isEmpty || phoneNumber.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please enter a valid phone number (10 digits)"),
      ));
      return;
    }

    if (_selectedGender == 'Select' || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please complete all fields"),
      ));
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DatabaseReference profileRef =
      FirebaseDatabase.instance.ref().child('Profile').child(user.uid);

      await profileRef.set({
        'name': name,
        'phone': phoneNumber,
        'gender': _selectedGender,
      });

      if (_imageFile != null) {
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child(user.uid);
        await storageRef.putFile(_imageFile!);
        String imageUrl = await storageRef.getDownloadURL();
        await profileRef.update({'profile_image': imageUrl});
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Profile updated successfully!"),
      ));

      // Navigate to ManualProfileScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("User not logged in"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(top: 50.0),
          child: Text(
            'Complete Your Profile',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
        toolbarHeight: 100.0,
      ),
      resizeToAvoidBottomInset: true, // Ensures that the keyboard pushes up the content
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your personal data is fully protected and accessible only by you',
              style: TextStyle(color: subtitleColor),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: inputBorderColor,
                    backgroundImage:
                    _imageFile != null ? FileImage(_imageFile!) : null,
                    child: _imageFile == null
                        ? Icon(Icons.person, size: 60, color: backgroundColor)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        decoration: BoxDecoration(
                          color: iconBackgroundColor,
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child:
                          Icon(Icons.edit, size: 20, color: backgroundColor),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: subtitleColor),
                fillColor: inputFillColor,
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: inputBorderColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _phoneController,
              style: TextStyle(color: textColor),
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                labelStyle: TextStyle(color: subtitleColor),
                fillColor: inputFillColor,
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: inputBorderColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField(
              value: _selectedGender,
              items: _genders
                  .map((gender) => DropdownMenuItem(
                value: gender,
                child: Text(gender, style: TextStyle(color: textColor)),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGender = value!;
                });
              },
              dropdownColor: inputFillColor,
              decoration: InputDecoration(
                labelText: 'Gender',
                labelStyle: TextStyle(color: subtitleColor),
                fillColor: inputFillColor,
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: inputBorderColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Complete Profile',
                  style: TextStyle(color: backgroundColor, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
