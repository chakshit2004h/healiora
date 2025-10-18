import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:healiora/ambulance_side/active_trip.dart';
import 'package:healiora/ambulance_side/history.dart';
import 'package:healiora/ambulance_side/profile_ambulance.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import '../services/auth_services.dart';
import 'ambulance_socket.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> activeTrips = [];
  List<Map<String, dynamic>> historyTrips = [];

  late final List<Widget> _pages;
  AmbulanceSocketService? ambulanceService;

  bool isLoading = true;
  String? ambulanceId; // store fetched id

  @override
  void initState() {
    super.initState();
    _pages = [
      dashboard(),
      History(),
      AmbulanceProfilePage()
    ];
    _loadAndInitSocket();
  }
  String? credentialId;
  Future<void> _loadAndInitSocket() async {
    try {
      final profile = await AuthService().getAmbulanceProfile();
      if (profile != null && profile["id"] != null) {
        ambulanceId = profile["id"].toString();
      } else {
        ambulanceId = "UNKNOWN";
      }

      ambulanceService = AmbulanceSocketService(ambulanceId!, "ambulance");
      await ambulanceService!.init();

      ambulanceService!.on("ambulance_case_assigned", (data) {
        print("🚨 SOS Request received: $data");

        // Add to active trips list
        setState(() {
          activeTrips.add({
            "tripId": data["tripId"] ?? "TR-${DateTime.now().millisecondsSinceEpoch}",
            "patientId": data["patientId"] ?? "Unknown",
            "name": data["name"] ?? "Unknown",
            "address": data["address"] ?? "Unknown",
            "urgency": data["urgency"] ?? "NORMAL",
            "time": DateTime.now(),
            "caseDetails": data["case_details"] ?? {},
          });
        });

        // Show dialog with patient info
        if (mounted) {
          _showSOSDialog(data);
        }
      });

      ambulanceService!.on("trip_update", (data) {
        print("📦 Trip Update: $data");
        credentialId = data['patient_id'];
        if (data["status"] == "completed") {
          setState(() {
            activeTrips.removeWhere((t) => t["tripId"] == data["tripId"]);
            historyTrips.add(data);
          });
        }
      });
    } catch (e) {
      print("❌ Failed to init socket: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

// Show SOS dialog
  void _showSOSDialog(dynamic data) {
    final caseDetails = data["case_details"] ?? {};
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Patient ID: ${data["patientId"]}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hospital ID: ${data["hospital_id"] ?? 'N/A'}"),
              const SizedBox(height: 8),
              Text("Symptoms: ${caseDetails["symptoms"] ?? 'N/A'}"),
              Text("Severity: ${caseDetails["severity"] ?? 'N/A'}"),
              Text("Estimated Arrival: ${caseDetails["estimated_arrival"] ?? 'N/A'}"),
              Text("Patient: ${caseDetails["patient"] ?? 'N/A'}"),
              Text("Age: ${caseDetails["age"] ?? 'N/A'}"),
              Text("Notes: ${caseDetails["notes"] ?? 'N/A'}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Implement View on Map
                print("View on Map clicked for patient ${data["patientId"]}");
              },
              child: const Text("View on Map"),
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
        );
      },
    );
  }


  @override
  void dispose() {
    ambulanceService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(Icons.health_and_safety, size: 30, color: Colors.teal),
            Text(
              "Healiora Ambulance",
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 18),
            ),
          ],
        ),
      ),

      body: _pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        elevation: 8,
        selectedFontSize: 10,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "History",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget dashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 👇 Overview cards here
          _overviewCard(
            title: "SOS Alerts",
            value: "${activeTrips.length}",   // ✅ dynamic count
            subtitle: "Active SOS requests",
            icon: Icons.warning_amber_rounded,
            buttonText: "View Alerts",
            onTap: () {
              setState(() => _selectedIndex = 1); // Go to History tab
            },
          ),
          const SizedBox(height: 16),

          _overviewCard(
            title: "Patients Overview",
            value: "0",  // Replace with real value later
            subtitle: "Registered patients",
            icon: Icons.people,
            buttonText: "View Patients",
            onTap: () {
              print("View Patients tapped");
            },
          ),

          const SizedBox(height: 20),

          const Text(
            "SOS Requests",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          if (activeTrips.isEmpty)
            const Center(
              child: Text("No SOS requests yet", style: TextStyle(color: Colors.grey)),
            )
          else
            ...activeTrips.map((trip) {
              return _buildSosCard(trip);
            }).toList(),
        ],
      ),
    );
  }


  Widget _buildSosCard(Map<String, dynamic> trip) {
    final caseDetails = trip["caseDetails"] ?? {};
    Color urgencyColor;
    switch (trip["urgency"]) {
      case "CRITICAL":
        urgencyColor = Colors.red;
        break;
      case "HIGH":
        urgencyColor = Colors.orange;
        break;
      default:
        urgencyColor = Colors.green;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: urgency + time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: urgencyColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    trip["urgency"] ?? "NORMAL",
                    style: TextStyle(
                      color: urgencyColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  "${trip["time"]}".split('.')[0], // formatted
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Patient Name
            Text(
              trip["name"] ?? "Unknown",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "Patient ID: ${trip["patientId"] ?? 'N/A'} | Hospital ID: ${trip["hospital_id"] ?? 'N/A'}",
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 8),

            // Case Details
            Text("Symptoms: ${caseDetails["symptoms"] ?? 'N/A'}"),
            Text("Severity: ${caseDetails["severity"] ?? 'N/A'}"),
            Text("Estimated Arrival: ${caseDetails["estimated_arrival"] ?? 'N/A'}"),
            Text("Age: ${caseDetails["age"] ?? 'N/A'} | Patient: ${caseDetails["patient"] ?? 'N/A'}"),
            Text("Notes: ${caseDetails["notes"] ?? 'N/A'}"),
            const SizedBox(height: 12),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Open detailed view / map
                    _showSOSDialog(trip);
                  },
                  icon: const Icon(Icons.map, size: 18),
                  label: const Text("View on Map"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Download patient info
                    print("Download clicked for patient ${trip["patientId"]}");
                  },
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text("Download"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _sosCard({
    required String urgency,
    required Color urgencyColor,
    required String time,
    required String name,
    required String id,
    required String address,
    required String distance,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // urgency + time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: urgencyColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  urgency,
                  style: TextStyle(
                    color: urgencyColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                time,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(name,
              style:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text("ID: $id", style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(address),
            ],
          ),
          const SizedBox(height: 4),
          Text(distance,
              style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 10),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text("Map Preview",
                style: TextStyle(color: Colors.black54)),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              setState(() {
                activeTrips.add({
                  "tripId": "TR-${DateTime.now().millisecondsSinceEpoch}",
                  "patientId": id,
                  "name": name,
                  "address": address,
                  "urgency": urgency,
                  "time": DateTime.now(),
                });
              });
            },
            child: const Text("Accept",
                style: TextStyle(color: Colors.white)),
          )
        ],
      ),
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
          Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.grey)),
          if (buttonText != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: onTap,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.teal.shade700),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(buttonText),
              ),
            ),
          ]
        ],
      ),
    );
  }


}
