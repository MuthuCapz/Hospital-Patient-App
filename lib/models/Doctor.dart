// lib/models/doctor.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class Doctor {
  final String name;
  final String specialist;
  final String profileImage;

  Doctor({
    required this.name,
    required this.specialist,
    required this.profileImage,
  });

  // Factory constructor to create a Doctor instance from a Firestore document
  factory Doctor.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Doctor(
      name: data['name'] ?? 'Unknown',
      specialist: data['specialist'] ?? 'Unknown',
      profileImage: data['profile_image'] ?? '',
    );
  }

  // Optional: Keep the existing method for Realtime Database if still needed
  factory Doctor.fromSnapshot(DataSnapshot snapshot) {
    final value = snapshot.value as Map<dynamic, dynamic>;
    return Doctor(
      name: value['name'] ?? 'Unknown',
      specialist: value['specialist'] ?? 'Unknown',
      profileImage: value['profile_image'] ?? '',
    );
  }
}
