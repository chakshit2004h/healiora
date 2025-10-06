import 'package:flutter/material.dart';

import '../mainPage/login.dart';
import '../services/auth_services.dart';

class AmbulanceProfilePage extends StatefulWidget {
  const AmbulanceProfilePage({super.key});

  @override
  State<AmbulanceProfilePage> createState() => _AmbulanceProfilePageState();
}

class _AmbulanceProfilePageState extends State<AmbulanceProfilePage> {
  Map<String, dynamic>? profile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await AuthService().getAmbulanceProfile();
    if (mounted) {
      setState(() {
        profile = data;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : profile == null
          ? const Center(child: Text("❌ Failed to load profile"))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...profile!.entries.map((entry) {
            return Card(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: Text(
                  _formatKey(entry.key),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                subtitle: Text(entry.value.toString()),
              ),
            );
          }).toList(),
          const SizedBox(height: 30),
        Center(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Login()),
              );
            },
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text(
              "Logout",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        )
        ]),
      ),
    );
  }

  /// Format snake_case keys into readable labels
  String _formatKey(String key) {
    return key
        .split('_')
        .map((word) =>
    word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : "")
        .join(' ');
  }
}
