import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:healiora/sidePages/user_card.dart';
import 'package:http/http.dart' as http;

import '../sidePages/medical_record.dart';

class AuthService {
  final _storage = FlutterSecureStorage();
  final String baseUrl = 'https://healiora-backend.onrender.com/api/v1';

  Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/users/credential/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['access_token'];

      if (token != null) {
        await _storage.write(key: 'token', value: token);

        // Fetch user profile and store name
        final profile = await getUserData();
        if (profile != null && profile.fullName.isNotEmpty) {
          await _storage.write(key: 'user_name', value: profile.fullName);
        }

        return true;
      }
    }

    return false;
  }

  Future<String?> signup({
    required String email,
    required String password,
    required String fullName,
    required String age,
    required String phoneNumber,
    required String emergencyContact,
    required String gender,
  }) async {
    final url = Uri.parse('https://healiora-backend.onrender.com/api/v1/patients/register-complete'); // ✅ Correct endpoint
    final headers = {'Content-Type': 'application/json'};

    final body = jsonEncode({
      "email": email,
      "password": password,
      "full_name": fullName,
      "age": int.parse(age),
      "phone_number": phoneNumber,
      "emergency_contact": emergencyContact,
      "gender": gender
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      print('🔁 Signup Response: ${response.statusCode} | ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Store name locally
        await _storage.write(key: 'user_name', value: fullName);
        return fullName;
      } else {
        throw Exception("Signup failed: ${response.body}");
      }
    } catch (e) {
      print('❌ Signup Error: $e');
      return null;
    }
  }
  Future<void> saveName(String name) async {
    await _storage.write(key: 'user_name', value: name);
  }

  Future<String?> getName() async {
    return await _storage.read(key: 'user_name');
  }


  Future<UserProfile?> getUserData() async {
    final token = await _storage.read(key: 'token');
    if (token == null) return null;

    final url = Uri.parse('$baseUrl/users/credential/me');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return UserProfile.fromJson(json);
    }

    return null;
  }
  Future<String?> _getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<MedicalRecord?> getMedicalRecord() async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/medical-records/me');

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      return MedicalRecord.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null; // No data yet
    } else {
      throw Exception('Failed to load medical record: ${response.body}');
    }
  }

  Future<bool> createMedicalRecord(MedicalRecord record) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/medical-records/create');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(record.toJson()),
    );

    return response.statusCode == 201;
  }

  Future<bool> updateMedicalRecord(MedicalRecord record) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/medical-records/update');

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(record.toJson()),
    );

    return response.statusCode == 200;
  }
  Future<List<dynamic>> getNearbyHospitals(double lat, double lng) async {
    final token = await _storage.read(key: 'access_token');
    final url = Uri.parse('$baseUrl/hospitals/nearby/10km?latitude=$lat&longitude=$lng');

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Return only the hospitals list (important!)
      return data['hospitals'] ?? [];
    } else {
      throw Exception('Failed to fetch nearby hospitals');
    }
  }

}
