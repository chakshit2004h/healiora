import 'package:flutter/material.dart';
import '../services/auth_services.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  List<dynamic> patients = [];
  bool isLoading = true;
  String? ambulanceId;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  // Initialize ambulance ID and fetch patients
  Future<void> _initData() async {
    setState(() => isLoading = true);

    // 1️⃣ Get ambulance profile
    final profile = await AuthService().getAmbulanceProfile();
    if (profile != null && profile["id"] != null) {
      ambulanceId = profile["id"].toString();
    } else {
      ambulanceId = null;
      print("❌ Ambulance ID not found");
    }

    // 2️⃣ Fetch patients if ambulanceId exists
    if (ambulanceId != null) {
      await fetchPatients();
    } else {
      setState(() => isLoading = false);
    }
  }
  // Fetch patients assigned to this ambulance
  Future<void> fetchPatients() async {
    try {
      final result = await AuthService().getAssignedPatientsByAmbulance(ambulanceId!);
      setState(() {
        patients = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("❌ Error fetching patients: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : patients.isEmpty
          ? const Center(child: Text("No patients assigned"))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: patients.length,
        itemBuilder: (context, index) {
          final patient = patients[index];
          return Card(
            elevation: 4,
            shadowColor: Colors.blueAccent.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + Priority
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.blueAccent,
                            child: Icon(Icons.person,
                                color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            patient["patient_name"] ?? "Unknown",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      // Chip(
                      //   label: Text(
                      //     patient["priority_level"] ?? "Normal",
                      //     style: const TextStyle(color: Colors.white),
                      //   ),
                      //   backgroundColor: (patient["priority_level"] == "High")
                      //       ? Colors.red
                      //       : Colors.green,
                      // ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Age + Gender row
                  Row(
                    children: [
                      const Icon(Icons.cake, size: 18, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        "Age: ${patient["patient_age"] ?? "N/A"}",
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 20),
                      const Icon(Icons.wc, size: 18, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        "Gender: ${patient["patient_gender"] ?? "N/A"}",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          // 👉 Navigate to details page
                        },
                        icon: const Icon(Icons.info_outline,
                            size: 18, color: Colors.blueAccent),
                        label: const Text(
                          "Details",
                          style: TextStyle(color: Colors.blueAccent),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
