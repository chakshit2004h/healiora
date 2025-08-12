import 'package:flutter/material.dart';

class UserProfile {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String age;
  final String gender;
  final String role;
  final int id;

  UserProfile({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.age,
    required this.gender,
    required this.role,
    required this.id,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      age: json['age']?.toString() ?? '',
      gender: json['gender'] ?? '',
      role: json['role'] ?? '',
      id: json['id'] ?? '',
    );
  }
}

