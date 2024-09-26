import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:wellmed/Screens/patientdetails.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doctor Bio Screen',
      theme: ThemeData(
        primaryColor: Color(0xFF0000FF),
      ),
      home: DoctorBioScreen(
        doctorName:
        'Dr. Riman Anira', // Sample name, replace with actual data from navigation
        doctorSpecialist:
        'Cardiologist', // Sample specialist, replace with actual data from navigation
      ),
    );
  }
}

class DoctorBioScreen extends StatefulWidget {
  final String doctorName;
  final String doctorSpecialist;

  DoctorBioScreen({required this.doctorName, required this.doctorSpecialist});

  @override
  _DoctorBioScreenState createState() => _DoctorBioScreenState();
}

class _DoctorBioScreenState extends State<DoctorBioScreen> {
  int selectedMorningTimeIndex = -1; // For morning time selection
  int selectedAfternoonTimeIndex = -1; // For afternoon time selection
  int selectedEveningTimeIndex = -1; // For evening time selection
  DateTime selectedDate = DateTime.now(); // For selected date

  final List<String> morningSlots = [
    '08:00 AM',
    '09:00 AM',
    '10:00 AM',
    '11:00 AM'
  ];
  final List<String> afternoonSlots = [
    '12:30 PM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM'
  ];
  final List<String> eveningSlots = ['04:00 PM', '05:00 PM', '06:00 PM'];

  // Combining all the time slots into one list
  late List<String> timeSlots;
  late String name;
  late String specialist;
  String profileImage = '';
  String aboutMe = '';
  String certifications = '';
  String experience = '';
  String location = ''; // New field for location
  String patients = ''; // For patient count

  @override
  void initState() {
    super.initState();
    name = widget.doctorName;
    specialist = widget.doctorSpecialist;
    timeSlots = [
      ...morningSlots,
      ...afternoonSlots,
      ...eveningSlots
    ]; // Combine slots
    _fetchDoctorDetails();
  }

  Future<void> _fetchDoctorDetails() async {
    try {
      final snapshot = await FirebaseDatabase.instance.ref('DoctorsList').get();

      if (snapshot.exists) {
        final doctorsData = snapshot.value as Map<dynamic, dynamic>;

        for (var doctorData in doctorsData.values) {
          final doctor = doctorData as Map<dynamic, dynamic>;

          if (doctor['name'] == name && doctor['specialist'] == specialist) {
            setState(() {
              profileImage = doctor['profile_image'] ?? '';
              aboutMe = doctor['about_me'] ?? '';
              certifications = doctor['certifications'] ?? '';
              experience = doctor['experience'] ?? '';
              location = doctor['location'] ?? ''; // Fetching location
              patients = doctor['patients'] ?? ''; // Fetching patient count
            });
            break; // Stop iterating once we find the matching doctor
          }
        }
      }
    } catch (e) {
      print('Error fetching doctor details: $e');
    }
  }

  List<DateTime> getDatesForMonth(DateTime currentMonth) {
    List<DateTime> days = [];
    int daysInMonth =
        DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(currentMonth.year, currentMonth.month, i));
    }
    return days;
  }

  void _showOverdueToast() {
    Fluttertoast.showToast(
      msg: "Sorry, this date is overdue.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black, // Red background
      textColor: Colors.red,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> days = getDatesForMonth(selectedDate);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              // Menu action
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor Info
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: profileImage.isNotEmpty
                        ? NetworkImage(profileImage)
                        : AssetImage('assets/doctor_image.jpg')
                    as ImageProvider,
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text(specialist, style: TextStyle(fontSize: 16)),
                      SizedBox(height: 4),
                      Text(location, style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Experience, Certifications, and Patients Stats
              Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Color(0xFFE6E6FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    StatWidget(label: 'Patients', value: patients),
                    StatWidget(label: 'Experience', value: '$experience Years'),
                    StatWidget(label: 'Certifications', value: certifications),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Biography Section
              Text('Biography',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text(
                aboutMe,
                style: TextStyle(color: Colors.grey, height: 1.5),
              ),
              SizedBox(height: 20),
              // Working Hours
              Text('Working Hours',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),

              // Morning Slots
              Text('Morning',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  mainAxisExtent: 40,
                ),
                itemCount: morningSlots.length,
                itemBuilder: (context, index) {
                  return TimeSlotWidget(
                    time: morningSlots[index],
                    isSelected: selectedMorningTimeIndex == index,
                    onTap: () {
                      setState(() {
                        selectedMorningTimeIndex = index;
                        selectedAfternoonTimeIndex =
                        -1; // Deselect afternoon slot
                        selectedEveningTimeIndex = -1; // Deselect evening slot
                      });
                    },
                  );
                },
              ),

              SizedBox(height: 20),

              // Afternoon Slots
              Text('Afternoon',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  mainAxisExtent: 40,
                ),
                itemCount: afternoonSlots.length,
                itemBuilder: (context, index) {
                  return TimeSlotWidget(
                    time: afternoonSlots[index],
                    isSelected: selectedAfternoonTimeIndex == index,
                    onTap: () {
                      setState(() {
                        selectedAfternoonTimeIndex = index;
                        selectedMorningTimeIndex = -1; // Deselect morning slot
                        selectedEveningTimeIndex = -1; // Deselect evening slot
                      });
                    },
                  );
                },
              ),
              SizedBox(height: 20),

              // Evening Slots
              Text('Evening',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  mainAxisExtent: 40,
                ),
                itemCount: eveningSlots.length,
                itemBuilder: (context, index) {
                  return TimeSlotWidget(
                    time: eveningSlots[index],
                    isSelected: selectedEveningTimeIndex == index,
                    onTap: () {
                      setState(() {
                        selectedEveningTimeIndex = index;
                        selectedMorningTimeIndex = -1; // Deselect morning slot
                        selectedAfternoonTimeIndex =
                        -1; // Deselect afternoon slot
                      });
                    },
                  );
                },
              ),

              SizedBox(height: 20),

              // Schedule Section (Calendar)
              Text('Schedules',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),

              // Month and Year Navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_left),
                    onPressed: () {
                      setState(() {
                        selectedDate = DateTime(
                            selectedDate.year, selectedDate.month - 1, 1);
                      });
                    },
                  ),
                  Text(
                    DateFormat('MMMM yyyy').format(selectedDate),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_right),
                    onPressed: () {
                      setState(() {
                        selectedDate = DateTime(
                            selectedDate.year, selectedDate.month + 1, 1);
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),

              // Calendar
              SizedBox(
                height: 70,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: days.length,
                  itemBuilder: (context, index) {
                    bool isSelected = selectedDate.day == days[index].day &&
                        selectedDate.month == days[index].month &&
                        selectedDate.year == days[index].year;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          DateTime today = DateTime.now();
                          // Check if the selected date is before today
                          if (days[index].isBefore(
                              DateTime(today.year, today.month, today.day))) {
                            _showOverdueToast(); // Show toast for past dates only
                          } else {
                            selectedDate = days[
                            index]; // Select the date if not in the past
                          }
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        padding:
                        EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? Color(0xFF0000FF) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: isSelected
                                  ? Color(0xFF0000FF)
                                  : Colors.grey.shade300),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              DateFormat('EEE').format(days[index]), // Day Name
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              DateFormat('dd')
                                  .format(days[index]), // Day Number
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 20),

              // Make Appointment Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Ensure a time slot is selected from any of the morning, afternoon, or evening slots
                    if (selectedMorningTimeIndex != -1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PatientDetailsScreen(
                            DoctorName: name,
                            DoctorSpecialist: specialist,
                            AppointmentTime:
                            morningSlots[selectedMorningTimeIndex],
                            AppointmentDate: selectedDate,
                            DoctorProfileImage:
                            profileImage, // Pass the profile image here
                          ),
                        ),
                      );
                    } else if (selectedAfternoonTimeIndex != -1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PatientDetailsScreen(
                            DoctorName: name,
                            DoctorSpecialist: specialist,
                            AppointmentTime:
                            afternoonSlots[selectedAfternoonTimeIndex],
                            AppointmentDate: selectedDate,
                            DoctorProfileImage:
                            profileImage, // Pass the profile image here
                          ),
                        ),
                      );
                    } else if (selectedEveningTimeIndex != -1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PatientDetailsScreen(
                            DoctorName: name,
                            DoctorSpecialist: specialist,
                            AppointmentTime:
                            eveningSlots[selectedEveningTimeIndex],
                            AppointmentDate: selectedDate,
                            DoctorProfileImage:
                            profileImage, // Pass the profile image here
                          ),
                        ),
                      );
                    } else {
                      // Show a message if no time slot is selected
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select a time slot.')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 80, vertical: 16),
                    backgroundColor: Color(0xFF0000FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Make an Appointment',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
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

class StatWidget extends StatelessWidget {
  final String label;
  final String value;

  StatWidget({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}

class TimeSlotWidget extends StatelessWidget {
  final String time;
  final bool isSelected;
  final VoidCallback onTap;

  TimeSlotWidget({
    required this.time,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40, // Reduced height to 40
        width: 100, // Adjusted width to 100
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF0000FF) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Color(0xFF0000FF) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          time,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}