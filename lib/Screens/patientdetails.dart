import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:wellmed/Screens/PaymentMethodScreen.dart';
import 'package:fluttertoast/fluttertoast.dart'; // For showing Toast messages

class PatientDetailsScreen extends StatefulWidget {
  final String DoctorName;
  final String DoctorSpecialist;
  final String AppointmentTime;
  final DateTime AppointmentDate;

  PatientDetailsScreen({
    required this.DoctorName,
    required this.DoctorSpecialist,
    required this.AppointmentTime,
    required this.AppointmentDate,
  });

  @override
  _PatientDetailsScreenState createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  String? _selectedBookingFor = 'Self'; // Dropdown default value
  String? _selectedGender = 'Male'; // Dropdown default value
  int? _selectedAge = 35; // Dropdown default value
  String? _uploadedFileName;
  String _patientName = '';
  String _patientIssue = '';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _issueController = TextEditingController();

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _uploadedFileName = result.files.single.name;
      });
    }
  }

  List<int> _ages =
      List.generate(66, (index) => 15 + index); // Age from 15 to 80

  Future<void> _saveAppointment() async {
    try {
      // Get the current user ID from Firebase Auth
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw 'User not authenticated';
      }
      final userId = user.uid;

      // Create a reference to the appointments node in Firebase Database
      DatabaseReference appointmentRef = FirebaseDatabase.instance
          .reference()
          .child('Patient Appointments')
          .child(userId)
          .push();

      // Prepare data to save
      Map<String, dynamic> appointmentData = {
        'DoctorName': widget.DoctorName,
        'DoctorSpecialist': widget.DoctorSpecialist,
        'AppointmentTime': widget.AppointmentTime,
        'AppointmentDate':
            DateFormat('dd MMM yyyy').format(widget.AppointmentDate),
        'PatientName': _patientName,
        'PatientAge': _selectedAge,
        'BookingFor': _selectedBookingFor,
        'Gender': _selectedGender,
        'Document': _uploadedFileName ?? '',
        'PatientIssue': _patientIssue,
      };

      // Save the data to Firebase
      await appointmentRef.set(appointmentData);

      // Show success message
      Fluttertoast.showToast(
        msg: "Your appointment is booked successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );

      // Navigate to payment screen after successful booking
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PaymentMethodsScreen()),
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to book appointment: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildSection(
            title: 'Doctor Details',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Doctor: ${widget.DoctorName}'),
                Text('Specialist: ${widget.DoctorSpecialist}'),
                Text('Appointment Time: ${widget.AppointmentTime}'),
                Text(
                    'Appointment Date: ${DateFormat('dd MMM yyyy').format(widget.AppointmentDate)}'),
              ],
            ),
          ),
          SizedBox(height: 16),
          _buildSection(
            title: 'Name',
            content: _buildTextField(
              controller: _nameController,
              hint: 'Enter your name',
              onChanged: (value) {
                _patientName = value;
              },
            ),
          ),
          SizedBox(height: 16),
          _buildSection(
            title: 'Booking For',
            content: _buildDropdown<String>(
              value: _selectedBookingFor!,
              items: ['Self', 'Others'],
              onChanged: (String? newValue) {
                setState(() {
                  _selectedBookingFor = newValue;
                });
              },
            ),
          ),
          SizedBox(height: 16),
          _buildSection(
            title: 'Gender',
            content: _buildDropdown<String>(
              value: _selectedGender!,
              items: ['Male', 'Female', 'Others'],
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGender = newValue;
                });
              },
            ),
          ),
          SizedBox(height: 16),
          _buildSection(
            title: 'Your Age',
            content: _buildDropdown<int>(
              value: _selectedAge!,
              items: _ages,
              onChanged: (int? newValue) {
                setState(() {
                  _selectedAge = newValue;
                });
              },
            ),
          ),
          SizedBox(height: 16),
          _buildSection(
            title: 'Upload Document',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: _pickDocument,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _uploadedFileName != null
                                ? _uploadedFileName!
                                : 'Upload Document',
                            style: TextStyle(color: Colors.black),
                          ),
                          Icon(
                            Icons.attachment,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          _buildSection(
            title: 'Write Your Problem',
            content: _buildTextField(
              controller: _issueController,
              hint: 'Describe your problem',
              maxLines: 4,
              onChanged: (value) {
                _patientIssue = value;
              },
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveAppointment,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Color(0xFF0000FF), // Button background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle:
                    TextStyle(color: Colors.white), // Ensure text is white
              ),
              child: Text(
                'Next',
                style: TextStyle(
                  color: Colors.white, // Button text color
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 8),
        content,
      ],
    );
  }

  Widget _buildTextField({
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1.0), // Grey border
          borderRadius: BorderRadius.circular(10.0), // Rounded corners
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: Colors.blue, width: 2.0), // Blue border when focused
          borderRadius: BorderRadius.circular(10.0), // Rounded corners
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items.map<DropdownMenuItem<T>>((T value) {
        return DropdownMenuItem<T>(
          value: value,
          child: Text(value.toString()),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1.0), // Grey border
          borderRadius: BorderRadius.circular(10.0), // Rounded corners
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: Colors.blue, width: 2.0), // Blue border when focused
          borderRadius: BorderRadius.circular(10.0), // Rounded corners
        ),
      ),
    );
  }
}
