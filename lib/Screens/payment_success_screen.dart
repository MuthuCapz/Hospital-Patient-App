import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({super.key});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  String doctorName = 'Loading...';
  String patientName = 'Loading...';
  String appointmentDate = 'Loading...';
  String appointmentTime = 'Loading...';
  String userId = '';

  @override
  void initState() {
    super.initState();
    _getRecentAppointmentDetails();
  }

  Future<void> _getRecentAppointmentDetails() async {
    try {
      // Get the current user ID
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        userId = user.uid;

        // Reference to the user's appointments in Firebase Realtime Database
        DatabaseReference ref = FirebaseDatabase.instance
            .ref()
            .child('Patient Appointments')
            .child(userId);

        // Query to get the last added key under the user's appointments
        Query lastAppointmentQuery = ref.limitToLast(1);

        // Fetch the last appointment data
        lastAppointmentQuery.once().then((DatabaseEvent event) {
          if (event.snapshot.value != null) {
            // Since we limited the query to 1, it should return only one key-value pair
            Map<String, dynamic> appointmentData = Map<String, dynamic>.from(
              event.snapshot.value as Map<dynamic, dynamic>,
            );

            // Get the first (and only) key-value pair from the map
            appointmentData.forEach((key, value) {
              setState(() {
                doctorName = value['DoctorName'] ?? 'Doctor Not Found';
                patientName = value['PatientName'] ?? 'Patient Not Found';
                appointmentDate = value['AppointmentDate'] ?? 'Date Not Found';
                appointmentTime = value['AppointmentTime'] ?? 'Time Not Found';
              });
            });
          } else {
            setState(() {
              doctorName = 'No Appointments Found';
              patientName = 'No Patient Found';
              appointmentDate = 'No Date Found';
              appointmentTime = 'No Time Found';
            });
          }
        });
      }
    } catch (e) {
      print("Error fetching appointment details: $e");
      setState(() {
        doctorName = 'Error fetching data';
        patientName = 'Error fetching data';
        appointmentDate = 'Error fetching data';
        appointmentTime = 'Error fetching data';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Handle back button functionality
            },
          ),
          title: const Text("Payment"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 70.0),
          child: Column(
            children: [
              // Success Icon
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF0000FF), // Updated color
                ),
                padding: const EdgeInsets.all(20),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 80,
                ),
              ),
              const SizedBox(height: 24),

              // Payment Successful Text
              const Text(
                "Payment Successful!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Subheading Text
              const Text(
                "You have successfully booked an appointment with",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),

              // Display Doctor Name retrieved from Firebase
              Text(
                doctorName, // Doctor's name from Firebase
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              // Row for Patient Name and Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, color: Color(0xFF0000FF)),
                      const SizedBox(width: 8),
                      Text(
                        patientName, // Patient's name from Firebase
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const Row(
                    children: [
                      Icon(Icons.attach_money, color: Color(0xFF0000FF)),
                      SizedBox(width: 8),
                      Text(
                        "\$20", // This is still hardcoded. Update if needed.
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(width: 35),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Row for Date and Time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: Color(0xFF0000FF)),
                      const SizedBox(width: 8),
                      Text(
                        appointmentDate, // Appointment date from Firebase
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Color(0xFF0000FF)),
                      const SizedBox(width: 8),
                      Text(
                        appointmentTime, // Appointment time from Firebase
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 50),

              // Buttons
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0000FF), // Updated color
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  // Handle View Appointment
                },
                child: const Text(
                  "View Appointment",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // Handle Go to Home
                },
                child: const Text(
                  "Go to Home",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF0000FF), // Updated color
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
