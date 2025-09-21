import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // State values
  bool sosAlerts = false;
  bool medicalUpdates = false;
  String selectedLanguage = "English";
  bool biometricLogin = false;

  final List<String> languages = ["English", "Hindi", "Spanish", "French"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // 🔔 Notification Preferences
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Notification Preferences",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    value: medicalUpdates,
                    onChanged: (val) => setState(() => medicalUpdates = val),
                    title: const Text("Medical Record Updates"),
                    subtitle: const Text("Get notified about record changes"),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 🔐 Account & Security
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Account & Security",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    value: biometricLogin,
                    onChanged: (val) => setState(() => biometricLogin = val),
                    title: const Text("Biometric Login"),
                    subtitle: const Text("Use fingerprint or face ID to login"),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 🔗 Connected Devices
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Connected Devices",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Text("Coming in Phase 1"),
                  Text("Manage your connected health devices",
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
