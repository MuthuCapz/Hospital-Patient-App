import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:wellmed/Screens/Profile.dart';
import 'package:wellmed/Screens/SearchDoctors.dart';
import 'package:wellmed/Screens/SpecialistCategory.dart';

import '../Map/mainlocation.dart';
import '../models/Doctor.dart';
import 'doctorbio.dart';

void main() async {
  runApp(MaterialApp(home: HomeMain())); // Wrap HomeScreen in MaterialApp
}

class HomeMain extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeMain> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Doctor> _doctors = []; // List to hold doctor data
  String _locality = 'Loading...'; // Default value
  String _profileImageUrl = ''; // Field to hold profile image URL

  @override
  void initState() {
    super.initState();
    _fetchLocality();
    _fetchDoctors(); // Fetch doctors data on initialization
    _fetchProfileImageUrl(); // Fetch profile image URL on initialization
  }


  Future<void> _fetchLocality() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        setState(() {
          _locality = 'User not logged in';
        });
        return;
      }

      // Reference to the Firestore document for the user's patient location
      final patientLocationDoc = await FirebaseFirestore.instance
          .collection('Patient Location')
          .doc(userId)
          .get();

      if (patientLocationDoc.exists) {
        setState(() {
          _locality = patientLocationDoc['locality'] ?? 'Not found in Patient Location'; // Get locality or default message
        });
      } else {
        // If "Patient Location" is not found, try retrieving city from "Manual Location"
        final manualLocationDoc = await FirebaseFirestore.instance
            .collection('Manual Location')
            .doc(userId)
            .get();

        if (manualLocationDoc.exists) {
          setState(() {
            _locality = manualLocationDoc['city'] ?? 'Not found in Manual Location'; // Get city or default message
          });
        } else {
          setState(() {
            _locality = 'Not found in both paths';
          });
        }
      }
    } catch (e) {
      setState(() {
        _locality = 'Error: ${e.toString()}';
      });
      print("Error fetching locality: $e");
    }
  }


  Future<void> _fetchDoctors() async {
    try {
      // Create an instance of Firestore
      final CollectionReference doctorsCollection = FirebaseFirestore.instance.collection('DoctorsList');

      // Fetch the documents from the collection
      final QuerySnapshot snapshot = await doctorsCollection.get();

      if (snapshot.docs.isNotEmpty) {
        final List<Doctor> fetchedDoctors = [];

        // Iterate through the documents to create Doctor objects
        for (var doc in snapshot.docs) {
          final doctor = Doctor.fromFirestore(doc); // Use a factory method to create Doctor from Firestore doc
          fetchedDoctors.add(doctor);
        }

        setState(() {
          _doctors = fetchedDoctors;
        });
      } else {
        setState(() {
          _doctors = [];
        });
      }
    } catch (e) {
      print('Error fetching doctors: $e');
      setState(() {
        _doctors = [];
      });
    }
  }


  Future<void> _fetchProfileImageUrl() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        setState(() {
          _profileImageUrl = ''; // Default or placeholder image URL
        });
        return;
      }

      // Reference to the Firestore document for the user's profile
      final userDoc = await FirebaseFirestore.instance.collection('Profile').doc(userId).get();

      if (userDoc.exists) {
        setState(() {
          _profileImageUrl = userDoc['profile_image'] ?? ''; // Get the image URL or default to empty
        });
      } else {
        setState(() {
          _profileImageUrl = ''; // Default or placeholder image URL
        });
      }
    } catch (e) {
      print("Error fetching profile image URL: $e");
      setState(() {
        _profileImageUrl = ''; // Default or placeholder image URL
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Find your doctor',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GestureDetector(
              onTap: () {
                // Navigate to the profile screen when the profile image is clicked
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProfileScreen(), // Replace this with your ProfileScreen widget
                  ),
                );
              },
              child: CircleAvatar(
                backgroundImage: _profileImageUrl.isNotEmpty
                    ? NetworkImage(_profileImageUrl)
                    : const AssetImage('assets/images/default_profile.png')
                as ImageProvider,
              ),
            ),
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Location and Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 10.0, bottom: 10.0),
                  child: Text(
                    'Location',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to MainLocation
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              MainLocation()), // Replace with your MainLocation widget
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_pin,
                              color: Color(0xFF1612F0)),
                          const SizedBox(
                              width: 5), // Spacing between icon and text
                          Text(
                            _locality,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      Transform.translate(
                        offset: const Offset(-15,
                            0), // Moves the dropdown icon 5 pixels to the left
                        child: const Icon(Icons.keyboard_arrow_down,
                            color: Colors.black),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Inside your HomeScreen widget
                Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SearchDoctors(), // Replace with your SearchDoctors page
                        ),
                      );
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.search, color: Colors.black),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Search here',
                            style: TextStyle(
                                color:
                                Colors.black54), // Placeholder text style
                          ),
                        ),
                        Icon(Icons.filter_list, color: Colors.black),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Banner Image
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Image.asset(
                'assets/images/banner.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Horizontal ListView for Categories
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 5.0, bottom: 15.0, top: 10.0),
                  child: Text(
                    'What do you need?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding:
                    const EdgeInsets.only(left: 5.5), // Margin for ListView
                    children: [
                      _buildCategoryItem(
                          'General', 'assets/images/general.png'),
                      _buildCategoryItem(
                          'Cardiology', 'assets/images/cardiology.png'),
                      _buildCategoryItem('Dental', 'assets/images/dental.png'),
                      _buildCategoryItem(
                          'Neurology', 'assets/images/neuro.png'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Vertical ListView for Top Doctors
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Top Doctors',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          _doctors.isEmpty
              ? const Center(child: Text('No doctors found'))
              : ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _doctors.length,
            itemBuilder: (context, index) {
              final doctor = _doctors[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DoctorBioScreen(
                        doctorName: doctor.name,
                        doctorSpecialist: doctor.specialist,
                      ),
                    ),
                  );
                },
                child: _buildDoctorCard(
                  doctor.name,
                  doctor.specialist,
                  doctor.profileImage,
                ),
              );
            },
          ),
        ]),
      ),
    );
  }

// Helper to build a category item
  Widget _buildCategoryItem(String title, String imagePath) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SpecialistCategory(specialistCategory: title),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  height: 30,
                  width: 30,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  // Helper to build a doctor card
  Widget _buildDoctorCard(String name, String specialization, String imageUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white, // Background color of the card
        borderRadius: BorderRadius.circular(12.0), // Rounded corners
        border: Border.all(
          color: Colors.grey[300]!, // Light ash color for the border
          width: 0.5, // Stroke width
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2), // Light shadow color
            spreadRadius: 1, // Amount of shadow spread
            blurRadius: 4, // Blur radius of the shadow
            offset: const Offset(0, 2), // Position of the shadow
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(imageUrl),
        ),
        title: Text(name),
        subtitle: Text(specialization),
      ),
    );
  }
}