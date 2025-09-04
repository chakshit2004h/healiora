import 'dart:io';
import 'package:flutter/material.dart';
import 'package:healiora/doctor_side/patientpage_doctor.dart';
import 'package:healiora/doctor_side/profilepage_doctor.dart';
import 'package:healiora/doctor_side/schedule_doctor.dart';
import 'package:healiora/doctor_side/socket.dart';
import 'package:healiora/mainPage/profile.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_services.dart';
import 'package:dio/dio.dart';

String getDoctorIdFromToken(String token) {
  Map<String, dynamic> decoded = JwtDecoder.decode(token);
  return decoded["id"]; // change key depending on your backend's payload
}


class HospitalDashboard extends StatefulWidget {
  const HospitalDashboard({super.key});

  @override
  State<HospitalDashboard> createState() => _HospitalDashboardState();
}

class _HospitalDashboardState extends State<HospitalDashboard> {
  int _currentIndex = 0;
  String? doctorName;

  /// Pages corresponding to each bottom tab.
  late AmbulanceDoctorService doctorSocket;

  @override
  void initState() {
    super.initState();
    _initDoctorProfile();
    _initSocket(); // ✅ kick off async work
  }
  Future<void> _initDoctorProfile() async {
    try {
      final profile = await AuthService().getDoctorProfile();
      if (profile != null) {
        setState(() {
          doctorName = profile["name"] ?? "Doctor"; // adjust key as per API
        });
      }
    } catch (e) {
      print("❌ Failed to load doctor profile: $e");
    }
  }

  Future<void> downloadPdf(String url, String fileName) async {
    try {
      if (Platform.isAndroid) {
        var status = await Permission.storage.request();
        if (!status.isGranted) {
          print('Storage permission denied');
          return;
        }
      }

      Directory dir;
      if (Platform.isAndroid) {
        dir = (await getExternalStorageDirectory())!;
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      String savePath = '${dir.path}/$fileName';

      // Ensure the URL is direct download
      if (!url.contains('?dl=1')) {
        url = '$url&dl=1';
      }

      print('Downloading to $savePath');
      await Dio().download(url, savePath);
      print('Download completed');
    } catch (e) {
      print('Download failed: $e');
    }
  }



  Future<void> _initSocket() async {
    try {
      // fetch logged-in doctor
      final user = await AuthService().getUserData();
      if (user == null) {
        print("❌ No doctor data found");
        return;
      }

      // initialize socket with doctorId (or token)
      final doctorSocket = AmbulanceDoctorService(user.id.toString(), "doctor");
      await doctorSocket.init();

      // ✅ listen for hospital events
      doctorSocket.on("doctor_case_assigned", (data) {
        print("🚨 SOS ALERT received: $data");

        if (!mounted) return;

        // Show dialog instead of SnackBar
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text(
                "🚨 Emergency SOS Alert",
                style: TextStyle(color: Colors.red),
              ),
              content: Text("Patient: chay \nLocation: ${data['location'] ?? 'Kharar'}"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Dismiss"),
                ),
                TextButton(
                  onPressed: () async {
                    const url = "https://drive.google.com/file/d/11UuYHrIddea57yM9GOLTAhAu3XqOJK1d/view?usp=drive_link";
                    final uri = Uri.parse(url);

                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } else {
                      print("Could not launch $url");
                    }
                  },
                  child: const Text("Download"),
                )

              ],
            );
          },
        );
      });
      print("✅ Doctor socket initialized for ${user.id}");
    } catch (e) {
      print("❌ Error initializing doctor socket: $e");
    }
  }


  @override
  void dispose() {
    doctorSocket?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(doctorName: doctorName ?? "Doctor"), // ✅ now safe
      const PatientpageDoctor(),
      const DoctorProfilePage(),
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      body: pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Patients"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

/// The main dashboard layout, styled to match your design.
class DashboardScreen extends StatelessWidget {
  final String doctorName;
  const DashboardScreen({super.key, required this.doctorName});

  @override
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Greeting bar stays fixed
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildGreetingBar(),
          ),

          // Everything else scrolls
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Today’s Overview",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildOverviewCardsRow(),
                  const SizedBox(height: 20),
                  _buildUrgentHeader(),
                  const SizedBox(height: 12),
                  _buildUrgentAlertCard(),
                  const SizedBox(height: 12),
                  _buildUrgentAlertCard(),
                  const SizedBox(height: 12),
                  _buildUrgentAlertCard(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildGreetingBar() {
    return Material(
      elevation: 20,// controls shadow depth
      shadowColor: Colors.black.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getGreetingMessage(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "$doctorName",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCardsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _overviewCard(Icons.warning, "SOS Alerts", "3", Colors.red.shade50, Colors.red),
        _overviewCard(Icons.people, "Patients", "24", Colors.blue.shade50, Colors.blue),
      ],
    );
  }

  Widget _buildUrgentHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Urgent SOS Alerts",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            "3 Active",
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildUrgentAlertCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAlertHeader(),
          const SizedBox(height: 8),
          _buildCriticalTag(),
          const SizedBox(height: 8),
          const Text(
            "Chest pain, difficulty breathing",
            style: TextStyle(color: Colors.black87),
          ),
          const SizedBox(height: 8),
          _buildTimestamp(),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {},
              child: const Text("View Details",style: TextStyle(color: Colors.white),),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text(
          "Sarah Johnson",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          "(34y)",
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildCriticalTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        "CRITICAL",
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  Widget _buildTimestamp() {
    return Row(
      children: const [
        Icon(Icons.access_time, size: 16, color: Colors.grey),
        SizedBox(width: 4),
        Text(
          "5 min ago",
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  static Widget _overviewCard(
      IconData icon, String title, String count, Color bgColor, Color iconColor) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 8),
          Text(
            count,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
  String getGreetingMessage() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return "Good Morning";
    } else if (hour < 17) {
      return "Good Afternoon";
    } else if (hour < 21) {
      return "Good Evening";
    } else {
      return "Good Night";
    }
  }

}
