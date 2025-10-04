import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_services.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  List<dynamic> patients = [];
  List<dynamic> filteredPatients = [];
  bool isLoading = true;
  String? ambulanceId;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    setState(() => isLoading = true);

    final profile = await AuthService().getAmbulanceProfile();
    if (profile != null && profile["id"] != null) {
      ambulanceId = profile["id"].toString();
    } else {
      ambulanceId = null;
      print("❌ Ambulance ID not found");
    }

    if (ambulanceId != null) {
      await fetchPatients();
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchPatients() async {
    try {
      final result =
      await AuthService().getAssignedPatientsByAmbulance(ambulanceId!);
      setState(() {
        patients = result;
        filteredPatients = patients;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("❌ Error fetching patients: $e");
    }
  }

  void filterPatients(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredPatients = patients.where((patient) {
        final name = (patient["patient_name"] ?? "").toLowerCase();
        return name.contains(searchQuery);
      }).toList();
    });
  }

  Future<void> _launchCall(String phoneNumber) async {
    final Uri url = Uri(scheme: "tel", path: phoneNumber);
    if (!await launchUrl(url)) {
      throw "Could not launch call to $phoneNumber";
    }
  }

  Future<void> _launchMaps(String address) async {
    final Uri url = Uri.parse("https://www.google.com/maps/search/?api=1&query=$address");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw "Could not open maps for $address";
    }
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case "unassigned":
        color = Colors.grey;
        break;
      case "assigned":
        color = Colors.blue;
        break;
      case "ongoing":
        color = Colors.black;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : patients.isEmpty
          ? const Center(child: Text("No patients assigned"))
          : Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: filterPatients,
              decoration: InputDecoration(
                hintText: "Search by patient name...",
                prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Colors.blueAccent, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                ),
              ),
            ),
          ),

          // Patient List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: filteredPatients.length,
              itemBuilder: (context, index) {
                final patient = filteredPatients[index];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name + Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.person_outline, size: 22),
                                const SizedBox(width: 8),
                                Text(
                                  patient["patient_name"] ?? "Unknown",
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            _buildStatusChip(patient["status"] ?? "Unassigned"),
                          ],
                        ),

                        const SizedBox(height: 6),
                        Text(
                          "ID: ${patient["id"] ?? "N/A"}",
                          style: TextStyle(color: Colors.grey[700], fontSize: 13),
                        ),

                        const SizedBox(height: 8),

                        // Address
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on, size: 18, color: Colors.red),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    patient["address"] ?? "Address not available",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  GestureDetector(
                                    onTap: () => _launchMaps(patient["address"] ?? ""),
                                    child: const Text(
                                      "Open in Maps",
                                      style: TextStyle(
                                        color: Colors.blueAccent,
                                        fontSize: 13,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Accept Logic
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text("Accept",style: TextStyle(color: Colors.white),),
                            ),
                            ElevatedButton(
                              onPressed: () => _launchMaps(patient["address"] ?? ""),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text("Navigate",style: TextStyle(color: Colors.white)),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _launchCall(patient["phone"] ?? ""),
                              icon: const Icon(Icons.call, size: 18),
                              label: const Text("Call"),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
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
          ),
        ],
      ),
    );
  }
}
