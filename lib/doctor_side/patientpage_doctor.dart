import 'package:flutter/material.dart';
import '../services/auth_services.dart';

class PatientpageDoctor extends StatefulWidget {
  const PatientpageDoctor({super.key});

  @override
  State<PatientpageDoctor> createState() => _PatientpageDoctorState();
}

class _PatientpageDoctorState extends State<PatientpageDoctor> {
  List<dynamic> patients = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPatients();
  }

  Future<void> fetchPatients() async {
    try {
      final result = await AuthService().getAssignedPatients();

      // ✅ Sort patients by assigned date/time (most recent first)
      result.sort((a, b) {
        final dateA = DateTime.tryParse(a['assignment_date'] ?? '') ?? DateTime(0);
        final dateB = DateTime.tryParse(b['assignment_date5'] ?? '') ?? DateTime(0);
        return dateB.compareTo(dateA); // descending order
      });

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
      appBar: AppBar(
        title: const Text("Assigned Patients"),
        elevation: 2,
      ),
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
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Age + Gender row
                  Row(
                    children: [
                      const Icon(Icons.cake,
                          size: 18, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        "Age: ${patient["patient_age"] ?? "N/A"}",
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 20),
                      const Icon(Icons.wc,
                          size: 18, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        "Gender: ${patient["patient_gender"] ?? "N/A"}",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Optional: show assigned date
                  if (patient["assigned_at"] != null)
                    Text(
                      "Assigned on: ${patient["assigned_at"]}",
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey),
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
