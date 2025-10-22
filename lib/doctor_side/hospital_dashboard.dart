import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:audioplayers/audioplayers.dart';
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
  List<Map<String, dynamic>> sosAlerts = [];

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
      // Fetch logged-in doctor
      final user = await AuthService().getUserData();
      final token = await AuthService().getToken(); // ✅ get token

      if (user == null || token == null) {
        print("❌ No doctor data or token found");
        return;
      }

      // Initialize socket with doctorId (or token)
      final doctorSocket = AmbulanceDoctorService(user.id.toString(), "doctor");
      await doctorSocket.init();

      String extractPatientName(String notes) {
        final match = RegExp(r'Patient:\s*([^,]+)').firstMatch(notes);
        return match != null ? match.group(1)!.trim() : "Unknown Patient";
      }

      // ✅ Listen for hospital events
      doctorSocket.on("doctor_case_assigned", (data) async {
        print("🚨 SOS ALERT received: $data");

        if (!mounted) return;
        setState(() {
          sosAlerts.insert(0, {
            "name": data['Patient'] ?? "Unknown Patient",
            "age": data['age'] ?? "N/A",
            "condition": data['condition'] ?? "Emergency case",
            "location": data['location'] ?? "Unknown",
            "credential_id": data['patient_id'], // ✅ store credential_id
            "time": DateTime.now(),
          });
        });

        // Cache latest SOS credential id for other pages to consume as fallback
        try {
          final dynamic cred = data['credential_id'] ?? data['patient_id'] ?? data['patient_credential_id'];
          if (cred != null) {
            AuthService.lastSosCredentialId = cred.toString();
            print('ℹ️ Cached lastSosCredentialId=${AuthService.lastSosCredentialId}');
          }
        } catch (_) {}

        // ✅ Play SOS sound
        final player = AudioPlayer();
        await player.play(AssetSource("sounds/sos_alert.mp3"));

        // Build API endpoint for record download
        String? credentialId = data['patient_id'];
        String pdfUrl =
            "https://healiorabackend.rawcode.online/api/v1/medical-records/by-credential/$credentialId/pdf";

        // Show dialog
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text(
                "🚨 Emergency SOS Alert",
                style: TextStyle(color: Colors.red),
              ),
              content: Text(
                "Patient: ${extractPatientName(data['case_details']?['notes'] ?? '')}\n"
                    "Location: ${data['location'] ?? 'Unknown'}",
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Dismiss"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Diagnosed"),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (credentialId == null) {
                          print("❌ No credential_id found in SOS data");
                          return;
                        }

                        final uri = Uri.parse(
                            "https://healiorabackend.rawcode.online/api/v1/medical-records/by-credential/$credentialId/pdf"
                        );

                        print("📄 Fetching record from: $uri");

                        try {
                          final token = await AuthService().getToken();
                          final response = await http.get(
                            uri,
                            headers: {
                              "Authorization": "Bearer $token",
                              "Accept": "application/pdf",
                            },
                          );

                          if (response.statusCode == 200) {
                            final tempDir = await getTemporaryDirectory();
                            final filePath = "${tempDir.path}/record_$credentialId.pdf";
                            final file = File(filePath);
                            await file.writeAsBytes(response.bodyBytes);

                            print("PDF saved at: $filePath");

                            await OpenFile.open(filePath);
                          } else {
                            print("Failed to fetch PDF: ${response.statusCode}");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Failed to download record (Error ${response.statusCode})")),
                            );
                          }
                        } catch (e) {
                          print("Error downloading PDF: $e");
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error downloading PDF")),
                          );
                        }
                      },
                      child: const Text("Download"),
                    ),

                  ],
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
      DashboardScreen(doctorName: doctorName ?? "Doctor",sosAlerts: sosAlerts,), // ✅ now safe
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
  final List<Map<String, dynamic>> sosAlerts;
  const DashboardScreen({super.key, required this.doctorName, required this.sosAlerts});

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
                  // Full-width overview cards instead of row
                  _overviewCard(
                    title: "Patients Overview",
                    value: "0",
                    subtitle: "Patients",
                    buttonText: "View Patients",
                    icon: Icons.people,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PatientpageDoctor()));
                    },
                  ),
                  const SizedBox(height: 16),

                  _overviewCard(
                    title: "SOS History",
                    value: "0",
                    subtitle: "SOS this month, +2 today",
                    icon: Icons.warning_amber_rounded,
                  ),
                  const SizedBox(height: 20),
                  _buildUrgentHeader(),
                  const SizedBox(height: 12),
                  _buildUrgentAlertsList(),
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
          child: Text(
            "${sosAlerts.length} Active", // ✅ dynamic count
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildUrgentAlertsList() {
    if (sosAlerts.isEmpty) {
      return const Text("✅ No active SOS alerts right now");
    }
    return Column(
      children: sosAlerts.map((alert) {
        return _buildUrgentAlertCard(
          alert["name"],
          alert["age"],
          alert["condition"],
          alert["time"],
        );
      }).toList(),
    );
  }

  Widget _buildUrgentAlertCard(String name, String age, String condition, DateTime time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text("($age y)", style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
            child: const Text("CRITICAL", style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
          const SizedBox(height: 8),
          Text(condition, style: const TextStyle(color: Colors.black87)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text("${DateTime.now().difference(time).inMinutes} min ago",
                  style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {},
              child: const Text("View Details", style: TextStyle(color: Colors.white)),
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

  Widget _overviewCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    String? buttonText,
    VoidCallback? onTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.teal),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.grey)),
          if (buttonText != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: Text(buttonText,style: TextStyle(color: Colors.white),),
              ),
            ),
          ]
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
