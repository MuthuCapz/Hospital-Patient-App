import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/Doctor.dart'; // Import your Doctor model

class SpecialistCategory extends StatefulWidget {
  final String specialistCategory;

  const SpecialistCategory({Key? key, required this.specialistCategory}) : super(key: key);

  @override
  _SpecialistCategoryState createState() => _SpecialistCategoryState();
}

class _SpecialistCategoryState extends State<SpecialistCategory> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<Doctor> _specialists = [];

  @override
  void initState() {
    super.initState();
    _fetchSpecialists(); // Fetch the specialists based on the category
  }

  Future<void> _fetchSpecialists() async {
    try {
      final snapshot = await _database.child('DoctorsList').get();

      if (snapshot.exists) {
        final Map<dynamic, dynamic> doctorsMap = snapshot.value as Map<dynamic, dynamic>;
        final List<Doctor> fetchedSpecialists = [];

        doctorsMap.forEach((key, value) {
          final data = value as Map<dynamic, dynamic>;
          final doctor = Doctor(
            name: data['name'] ?? '',
            specialist: data['specialist'] ?? '',
            profileImage: data['profile_image'] ?? '',
            // Fetch the location
          );

          // Check if the doctor's specialist matches the selected category
          if (doctor.specialist == widget.specialistCategory) {
            fetchedSpecialists.add(doctor);
          }
        });

        setState(() {
          _specialists = fetchedSpecialists;
        });
      } else {
        print('No specialists found for category: ${widget.specialistCategory}');
        setState(() {
          _specialists = [];
        });
      }
    } catch (e) {
      print('Error fetching specialists: $e');
      setState(() {
        _specialists = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.specialistCategory),
        backgroundColor: Colors.white,
      ),
      body: _specialists.isEmpty
          ? const Center(child: Text('No specialists found'))
          : ListView.builder(
        itemCount: _specialists.length,
        itemBuilder: (context, index) {
          final specialist = _specialists[index];
          return _buildSpecialistCard(specialist);
        },
      ),
    );
  }

  Widget _buildSpecialistCard(Doctor specialist) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Color(0xFFF7F8FA), // Light background color like in your design
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(specialist.profileImage),
              ),
              const SizedBox(width: 16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    specialist.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    specialist.specialist,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey[600],
                    ),
                  ),

                ],
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0000FF), // Custom button color
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                _makeAppointment(specialist);
              },
              child: Text(
                'Make Appointment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Text color is white
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _makeAppointment(Doctor specialist) {
    // Implement your appointment logic here
    print('Making appointment with ${specialist.name}');
  }
}
