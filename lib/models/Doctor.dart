// lib/models/doctor.dart

import 'package:firebase_database/firebase_database.dart';

class Doctor {
  final String name;
  final String specialist;
  final String profileImage;

  Doctor(
      {required this.name,
      required this.specialist,
      required this.profileImage});

  factory Doctor.fromSnapshot(DataSnapshot snapshot) {
    final value = snapshot.value as Map<dynamic, dynamic>;
    return Doctor(
      name: value['name'] ?? 'Unknown',
      specialist: value['specialist'] ?? 'Unknown',
      profileImage: value['profile_image'] ?? '',
    );
  }
}
