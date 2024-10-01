import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/Doctor.dart'; // Import the Doctor model

class SearchDoctors extends StatefulWidget {
  @override
  _SearchDoctorsState createState() => _SearchDoctorsState();
}

class _SearchDoctorsState extends State<SearchDoctors> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Doctor> _allDoctors = []; // List to hold all doctors
  List<Doctor> _filteredDoctors = []; // List to hold filtered doctors based on search
  String _searchQuery = ''; // Holds the current search query

  @override
  void initState() {
    super.initState();
    _fetchDoctors(); // Fetch the doctors list when the screen loads
  }

  Future<void> _fetchDoctors() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('DoctorsList').get();

      if (snapshot.docs.isNotEmpty) {
        final List<Doctor> fetchedDoctors = snapshot.docs.map((doc) {
          return Doctor.fromFirestore(doc); // Use fromFirestore method
        }).toList();

        setState(() {
          _allDoctors = fetchedDoctors;
          _filteredDoctors = fetchedDoctors; // Initially, show all doctors
        });
      }
    } catch (e) {
      print('Error fetching doctors: $e');
      setState(() {
        _allDoctors = [];
        _filteredDoctors = [];
      });
    }
  }

  // Function to handle search
  void _filterDoctors(String query) {
    List<Doctor> filteredList = _allDoctors.where((doctor) {
      final nameLower = doctor.name.toLowerCase();
      final specialistLower = doctor.specialist.toLowerCase();
      final queryLower = query.toLowerCase();

      // Return true if the query matches the doctor's name or specialist
      return nameLower.contains(queryLower) || specialistLower.contains(queryLower);
    }).toList();

    setState(() {
      _filteredDoctors = filteredList;
      _searchQuery = query; // Update the search query
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Doctors'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (query) => _filterDoctors(query), // Filter doctors as user types
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search by name or specialist',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ),

          // Doctor List
          Expanded(
            child: _filteredDoctors.isEmpty
                ? const Center(child: Text('No doctors found'))
                : ListView.builder(
              itemCount: _filteredDoctors.length,
              itemBuilder: (context, index) {
                final doctor = _filteredDoctors[index];
                return _buildDoctorCard(doctor);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build a doctor card
  Widget _buildDoctorCard(Doctor doctor) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(doctor.profileImage),
        ),
        title: Text(doctor.name),
        subtitle: Text(doctor.specialist),
        onTap: () {
          // Optionally, navigate to a detailed doctor profile page when tapped
        },
      ),
    );
  }
}
