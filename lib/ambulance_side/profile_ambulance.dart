import 'package:flutter/material.dart';

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
      appBar: AppBar(
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back,color: Colors.white,)),
        title: const Text("Ambulance Profile",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500),),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : profile == null
          ? const Center(child: Text("❌ Failed to load profile"))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: profile!.entries.map((entry) {
            return Card(
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
        ),
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
