import 'package:flutter/material.dart';
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

  // Initialize ambulance ID and fetch patients
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
        filteredPatients = patients; // Initially show all
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("❌ Error fetching patients: $e");
    }
  }

  // 🔎 Filter patients based on search query
  void filterPatients(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredPatients = patients.where((patient) {
        final name = (patient["patient_name"] ?? "").toLowerCase();
        return name.contains(searchQuery);
      }).toList();
    });
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
          // 🔎 Search Bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: filterPatients,
              decoration: InputDecoration(
                hintText: "Search by patient name...",
                prefixIcon:
                const Icon(Icons.search, color: Colors.blueAccent),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 12, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(
                      color: Colors.blueAccent, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(
                      color: Colors.blueAccent, width: 2),
                ),
              ),
            ),
          ),

          // Patient List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              itemCount: filteredPatients.length,
              itemBuilder: (context, index) {
                final patient = filteredPatients[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header with gradient + avatar
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blueAccent.withOpacity(0.9),
                              Colors.lightBlueAccent.withOpacity(0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20)),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.white,
                              child: Text(
                                (patient["patient_name"] != null &&
                                    patient["patient_name"]
                                        .isNotEmpty)
                                    ? patient["patient_name"][0]
                                    .toUpperCase()
                                    : "?",
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                patient["patient_name"] ?? "Unknown",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Info Section
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Chip(
                                  avatar: const Icon(Icons.cake,
                                      size: 18, color: Colors.white),
                                  label: Text(
                                    "Age: ${patient["patient_age"] ?? "N/A"}",
                                    style: const TextStyle(
                                        color: Colors.white),
                                  ),
                                  backgroundColor: Colors
                                      .blueAccent
                                      .withOpacity(0.8),
                                ),
                                const SizedBox(width: 10),
                                Chip(
                                  avatar: const Icon(Icons.wc,
                                      size: 18, color: Colors.white),
                                  label: Text(
                                    "Gender: ${patient["patient_gender"] ?? "N/A"}",
                                    style: const TextStyle(
                                        color: Colors.white),
                                  ),
                                  backgroundColor: Colors
                                      .green
                                      .withOpacity(0.7),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            const Divider(),

                            // Action Buttons
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () {
                                    // 👉 Navigate to details page
                                  },
                                  icon: const Icon(Icons.info_outline,
                                      size: 18,
                                      color: Colors.blueAccent),
                                  label: const Text(
                                    "Details",
                                    style: TextStyle(
                                        color: Colors.blueAccent),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
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
