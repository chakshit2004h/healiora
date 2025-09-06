import 'package:flutter/material.dart';
import 'package:healiora/mainPage/login.dart';

import '../services/auth_services.dart';

class DoctorProfilePage extends StatefulWidget {
  const DoctorProfilePage({super.key});

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  bool emergencyAlerts = false;
  Map<String, dynamic>? doctorProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await AuthService().getDoctorProfile();
    if (mounted) {
      setState(() {
        doctorProfile = profile;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (doctorProfile == null) {
      return const Scaffold(
        body: Center(child: Text("Failed to load profile")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Profile Card
            Card(
              color: Colors.white,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundImage: AssetImage("assets/doctor.png"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "${doctorProfile!['name'] ?? 'Unknown'}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(width: 6),
                            if (doctorProfile!['verified'] == true)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  "Verified",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(doctorProfile!['specialization'] ?? "Emergency Medicine",
                            style: const TextStyle(
                                color: Colors.black87, fontSize: 13)),
                        Text(
                            "${doctorProfile!['hospital'] ?? 'Fortis Hospital'}, ${doctorProfile!['location'] ?? 'Chandigarh'}",
                            style: const TextStyle(
                                color: Colors.black54, fontSize: 12)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.email_outlined,
                                size: 16, color: Colors.black54),
                            const SizedBox(width: 6),
                            Text(doctorProfile!['email'] ?? "N/A",
                                style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.phone_outlined,
                                size: 16, color: Colors.black54),
                            const SizedBox(width: 6),
                            Text(doctorProfile!['phone_number'] ?? "N/A",
                                style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            _sectionTitle("Professional details"),
            _card(_infoRow(Icons.badge_outlined, "Registration / License No.",
                doctorProfile!['registration_number'] ?? "N/A")),
            _card(_infoRow(Icons.school_outlined, "Qualifications",
                doctorProfile!['education'] ?? "N/A")),
            _card(_infoRow(Icons.local_hospital_outlined,
                "Hospital / Department",
                "${doctorProfile!['hospital'] ?? 'N/A'} / ${doctorProfile!['specialization'] ?? 'N/A'}")),

            const SizedBox(height: 20),

            _sectionTitle("App settings"),
            _card(
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Emergency alerts",
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        Text("Receive urgent SOS notifications",
                            style:
                            TextStyle(color: Colors.black54, fontSize: 12)),
                      ]),
                  Switch(
                    value: emergencyAlerts,
                    onChanged: (val) =>
                        setState(() => emergencyAlerts = val),
                    activeColor: Colors.blue,
                  )
                ],
              ),
            ),
            _card(_buttonRow(Icons.language_outlined, "Language", "English")),
            _card(_buttonRow(
                Icons.lock_outline, "Change password / Security", "Manage")),
            _card(_buttonRow(Icons.devices_other_outlined, "Linked device",
                "Connect",
                subtitle: "No device linked", disabled: true)),

            const SizedBox(height: 20),
            const Divider(thickness: 1),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login()));
                },
                child: const Text("Logout",
                    style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helpers
  Widget _card(Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black12.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.black87)),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.black54),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.black54, fontSize: 12)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500)),
              ]),
        )
      ],
    );
  }

  Widget _buttonRow(IconData icon, String title, String action,
      {String? subtitle, bool disabled = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            if (subtitle != null)
              Text(subtitle,
                  style: const TextStyle(
                      color: Colors.black54, fontSize: 12)),
          ]),
        ]),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(
                color: disabled ? Colors.grey : Colors.blue, width: 1),
            borderRadius: BorderRadius.circular(6),
            color: disabled ? Colors.grey.shade200 : Colors.transparent,
          ),
          child: Text(
            action,
            style: TextStyle(
              fontSize: 13,
              color: disabled ? Colors.grey : Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        )
      ],
    );
  }

  Widget _simpleRow(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.black54),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
