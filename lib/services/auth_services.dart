import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:healiora/sidePages/user_card.dart';
import 'package:http/http.dart' as http;

import '../sidePages/medical_record.dart';

class AuthService {
  final _storage = FlutterSecureStorage();
  final String baseUrl = 'https://healiorabackend.rawcode.online/api/v1';

  // Simple cache to bridge IDs coming from SOS socket
  static String? lastSosCredentialId;

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
    final url = Uri.parse('https://healiorabackend.rawcode.online/api/v1/patients/register-complete'); // ✅ Correct endpoint
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
  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<MedicalRecord?> getMedicalRecord() async {
    final token = await getToken();
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
    final token = await getToken();
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
    final token = await getToken();
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
  Future<List<dynamic>> getNearbyHospitals20(double lat, double lng) async {
    final token = await _storage.read(key: 'token');  // use your stored token key
    final url = Uri.parse('$baseUrl/hospitals/nearby/20km?latitude=$lat&longitude=$lng');  // match API param names

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Return the list of hospitals directly (adjust if your API wraps it differently)
      return data;
    } else {
      throw Exception('Failed to fetch nearby hospitals: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>?> getDoctorProfile() async {
    final token = await _storage.read(key: 'token');
    if (token == null) return null;

    final url = Uri.parse('$baseUrl/doctors/doctors/me'); // ✅ Doctor profile API
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print("❌ Failed to fetch doctor profile: ${response.statusCode} | ${response.body}");
      return null;
    }
  }
  Future<Map<String, dynamic>?> getAmbulanceProfile() async {
    final token = await _storage.read(key: 'token');
    if (token == null) return null;

    final url = Uri.parse('$baseUrl/ambulances/ambulances/me');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print("❌ Failed to fetch ambulance profile: ${response.statusCode} | ${response.body}");
      return null;
    }
  }
  Future<List<dynamic>> getAssignedPatients() async {
    final token = await getToken();
    if (token == null) throw Exception("No token found");

    final url = Uri.parse("$baseUrl/patient-assignments/me/assigned-patients");

    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      // ✅ API already returns a list, so just return it
      return data;
    } else {
      throw Exception("Failed to fetch patients: ${response.statusCode}");
    }
  }
  Future<List<dynamic>> getAssignedPatientsByAmbulance(String ambulanceId) async {
    final token = await getToken();
    if (token == null) throw Exception("No token found");

    final response = await http.get(
      Uri.parse("$baseUrl/patient-assignments/me/assigned-patients"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token", // 🔑 keep token
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic>data = json.decode(response.body);
      // Optionally, filter by ambulanceId if backend returns ambulance info
      // For now, just return the same list
      return data;
    } else {
      throw Exception("Failed to fetch patients for ambulance");
    }
  }

  // Update patient profile using the API endpoint
  Future<bool> updateProfile({
    required String fullName,
    required String phoneNumber,
    required String email,
    required int age,
    required String gender,
  }) async {
    final token = await getToken();
    if (token == null) throw Exception("No token found");

    final url = Uri.parse('$baseUrl/patients/patients/update-profile');
    
    final body = jsonEncode({
      'full_name': fullName,
      'phone_number': phoneNumber,
      'email': email,
      'age': age,
      'gender': gender,
    });

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      print('🔁 Update Profile Response: ${response.statusCode} | ${response.body}');

      if (response.statusCode == 200) {
        // Update local storage with new name
        await _storage.write(key: 'user_name', value: fullName);
        return true;
      } else {
        print('❌ Update Profile Error: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Update Profile Exception: $e');
      return false;
    }
  }

  // Fetch patient's credential id by patient id
  Future<String?> getPatientCredentialIdById(String patientId) async {
    final token = await getToken();
    if (token == null) throw Exception("No token found");

    final url = Uri.parse('$baseUrl/patients/patients/me/$patientId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        // Debug: print response to help identify correct field
        // ignore: avoid_print
        print('ℹ️ getPatientCredentialIdById($patientId) payload: ' + response.body.toString());

        dynamic cred;
        // Try direct keys
        cred = data['credential_id'] ?? data['patient_credential_id'] ?? data['patient_credential'] ?? data['credentialId'];
        // Try nested structures
        cred ??= (data['credential'] is Map) ? (data['credential']['id'] ?? data['credential']['credential_id']) : null;
        cred ??= (data['patient'] is Map)
            ? (data['patient']['credential_id'] ??
                data['patient']['credentialId'] ??
                (data['patient']['credential'] is Map
                    ? (data['patient']['credential']['id'] ?? data['patient']['credential']['credential_id'])
                    : null))
            : null;
        // Sometimes APIs wrap the patient under 'data'
        if (cred == null && data['data'] is Map) {
          final Map<String, dynamic> d = data['data'];
          cred = d['credential_id'] ?? d['patient_credential_id'] ?? d['credentialId'] ??
              (d['credential'] is Map ? (d['credential']['id'] ?? d['credential']['credential_id']) : null);
        }

        if (cred == null) return null;
        return cred.toString();
      } else {
        print('❌ getPatientCredentialIdById error: ${response.statusCode} | ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ getPatientCredentialIdById exception: $e');
      return null;
    }
  }

  // Request password change for doctor (sends email code)
  Future<bool> requestPasswordChange({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final token = await getToken();
    if (token == null) throw Exception("No token found");

    final url = Uri.parse('$baseUrl/doctors/doctors/request-password-change');
    
    final body = jsonEncode({
      'current_password': currentPassword,
      'new_password': newPassword,
      'confirm_password': confirmPassword,
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      print('🔁 Request Password Change Response: ${response.statusCode} | ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        print('❌ Request Password Change Error: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Request Password Change Exception: $e');
      return false;
    }
  }

  // Verify email code and complete password change
  Future<bool> verifyPasswordChangeCode({
    required String code,
  }) async {
    final token = await getToken();
    if (token == null) throw Exception("No token found");

    final url = Uri.parse('$baseUrl/doctors/doctors/change-password');
    
    final body = jsonEncode({
      'verification_code': code,
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      print('🔁 Verify Password Change Code Response: ${response.statusCode} | ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        print('❌ Verify Password Change Code Error: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Verify Password Change Code Exception: $e');
      return false;
    }
  }

}
