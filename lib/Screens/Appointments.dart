import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Appointments extends StatefulWidget {
  @override
  _AppointmentsPageState createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<Appointments>
    with SingleTickerProviderStateMixin {
  List<Map<dynamic, dynamic>> upcomingAppointments = [];
  List<Map<dynamic, dynamic>> completedAppointments = [];
  List<Map<dynamic, dynamic>> canceledAppointments = [];
  String? currentUserID;

  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _tabController = TabController(length: 3, vsync: this);
  }

  // Function to get current user's ID
  void _getCurrentUser() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserID = user.uid;
      });
      _fetchAppointments();
    }
  }

  // Function to fetch appointments of the current user from Firebase
  void _fetchAppointments() {
    if (currentUserID == null) return;

    DatabaseReference appointmentsRef = FirebaseDatabase.instance
        .ref()
        .child("Patient Appointments")
        .child(currentUserID!);

    appointmentsRef.once().then((DatabaseEvent event) {
      Map<dynamic, dynamic>? values =
      event.snapshot.value as Map<dynamic, dynamic>?;

      if (values != null) {
        values.forEach((bookingId, appointmentData) {
          String status = appointmentData['status'] ?? 'upcoming';
          appointmentData['BookingID'] = bookingId;

          // Check if the appointment has expired
          bool isExpired = _checkIfAppointmentExpired(
              appointmentData['AppointmentDate'], appointmentData['AppointmentTime']);

          // Update status to 'canceled' if the appointment has expired
          if (isExpired && status != 'canceled') {
            status = 'canceled';
            appointmentData['status'] = 'canceled';  // Update local status

            // Update Firebase to mark appointment as canceled
            appointmentsRef.child(bookingId).update({'status': 'canceled'});
          }

          // Categorize appointments based on their status
          if (status == 'upcoming') {
            setState(() {
              upcomingAppointments.add(appointmentData);
            });
          } else if (status == 'completed') {
            setState(() {
              completedAppointments.add(appointmentData);
            });
          } else if (status == 'canceled') {
            setState(() {
              canceledAppointments.add(appointmentData);
            });
          }
        });
      }
    });
  }

  // Function to check if the appointment date and time are expired
  bool _checkIfAppointmentExpired(String appointmentDate, String appointmentTime) {
    try {
      // Combine appointment date and time into a single DateTime object
      String dateTimeString = '$appointmentDate $appointmentTime';

      // Ensure the format string matches the exact format of your date and time inputs
      DateFormat format = DateFormat('dd MMM yyyy hh:mm a'); // Adjusted format

      // Parse the appointment date and time into a DateTime object
      DateTime appointmentDateTime = format.parse(dateTimeString);

      // Get the current date and time for comparison
      DateTime now = DateTime.now();

      // Return true if the appointment has passed (i.e., is before the current time)
      return appointmentDateTime.isBefore(now);
    } catch (e) {
      print('Error parsing date/time: $e');
      return false;  // If there's an error, assume the appointment is not expired
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Bookings',
          style: TextStyle(
            fontSize: 20,         // Set the font size to 20
            fontWeight: FontWeight.bold,  // Optional: make the text bold
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Color(0xFF0000FF),         // Set selected tab text color to blue
          unselectedLabelColor: Colors.black,  // Unselected tab text color
          indicatorColor: Color(0xFF0000FF),     // Set indicator color to blue
          tabs: [
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
            Tab(text: 'Canceled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAppointmentList(upcomingAppointments, true),  // Show cancel and reschedule buttons for upcoming
          _buildAppointmentList(completedAppointments, false), // No buttons for completed
          _buildAppointmentList(canceledAppointments, false),  // No buttons for canceled
        ],
      ),
    );
  }

  // Function to build appointment list based on data
  Widget _buildAppointmentList(List<Map<dynamic, dynamic>> appointments, bool showButtons) {
    if (appointments.isEmpty) {
      return Center(child: Text('No Appointments'));
    }

    return ListView.builder(
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return AppointmentCard(appointment: appointment, showButtons: showButtons);
      },
    );
  }
}

// Widget for displaying appointment card
class AppointmentCard extends StatelessWidget {
  final Map<dynamic, dynamic> appointment;
  final bool showButtons;

  const AppointmentCard({Key? key, required this.appointment, required this.showButtons}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${appointment['AppointmentDate']} | ${appointment['AppointmentTime']}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: appointment['DoctorProfileImage'] != null && appointment['DoctorProfileImage'].isNotEmpty
                      ? NetworkImage(appointment['DoctorProfileImage'])
                      : AssetImage('assets/placeholder_image.png'), // Provide a default placeholder image
                ),
                SizedBox(width: 30),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment['DoctorName'],
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(appointment['DoctorSpecialist']),
                      Text(
                        '${appointment['PatientName']}, ${appointment['Gender']}, Age ${appointment['PatientAge']}',
                      ),
                      Text(
                        'Book ID: ${appointment['BookingID']}',
                        style: TextStyle(color: Color(0xFF0000FF)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            if (showButtons)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade100,
                    ),
                    onPressed: () {
                      _cancelAppointment(appointment['BookingID']);
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Color(0xFF0000FF)),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0000FF),
                    ),
                    onPressed: () {
                      _rescheduleAppointment(appointment['BookingID']);
                    },
                    child: Text(
                      'Reschedule',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // Dummy function to cancel an appointment (implement your logic here)
  void _cancelAppointment(String bookingID) {
    // Implement cancellation logic (e.g., show confirmation dialog)
    print('Canceling appointment with Booking ID: $bookingID');
  }

  // Dummy function to reschedule an appointment (implement your logic here)
  void _rescheduleAppointment(String bookingID) {
    // Implement rescheduling logic (e.g., show rescheduling dialog)
    print('Rescheduling appointment with Booking ID: $bookingID');
  }
}
