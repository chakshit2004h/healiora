import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../services/auth_services.dart';

class PatientpageDoctor extends StatefulWidget {
  const PatientpageDoctor({super.key});

  @override
  State<PatientpageDoctor> createState() => _PatientpageDoctorState();
}

class _PatientpageDoctorState extends State<PatientpageDoctor>
    with SingleTickerProviderStateMixin {
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

      result.sort((a, b) {
        final dateA =
            DateTime.tryParse(a['assignment_date'] ?? '') ?? DateTime(0);
        final dateB =
            DateTime.tryParse(b['assignment_date'] ?? '') ?? DateTime(0);
        return dateB.compareTo(dateA);
      });

      setState(() {
        patients = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("❌ Error fetching patients: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          "Assigned Patients",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.blueAccent.withOpacity(0.2),
        surfaceTintColor: Colors.white,
        foregroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : patients.isEmpty
          ? const Center(
        child: Text(
          "No patients assigned",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: patients.length,
        itemBuilder: (context, index) {
          final patient = patients[index];

          return AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              elevation: 6,
              shadowColor: Colors.blueAccent.withOpacity(0.15),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 👤 Name and avatar
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF2196F3),
                                  Color(0xFF42A5F5),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const CircleAvatar(
                              radius: 26,
                              backgroundColor: Colors.transparent,
                              child: Icon(Icons.person,
                                  color: Colors.white, size: 28),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  patient["patient_name"] ??
                                      "Unknown",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (patient["assigned_at"] != null)
                                  Text(
                                    "Assigned on: ${patient["assigned_at"]}",
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      const Divider(height: 1),

                      const SizedBox(height: 12),

                      // 🎂 Age & Gender row
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.cake,
                                  size: 18, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(
                                "Age: ${patient["patient_age"] ?? "N/A"}",
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.wc,
                                  size: 18, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(
                                "Gender: ${patient["patient_gender"] ?? "N/A"}",
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // 📄 Details Button
                      // Align(
                      //   alignment: Alignment.centerRight,
                      //   child: ElevatedButton.icon(
                      //     onPressed: () async {
                      //       // First try to resolve credential id from patient id via API
                      //       final dynamic rawPatientId = patient["patient_id"] ?? patient["id"];
                      //       String? credentialId;
                      //
                      //       try {
                      //         if (rawPatientId != null) {
                      //           debugPrint('ℹ️ Resolving credential for patientId: ' + rawPatientId.toString());
                      //           credentialId = await AuthService().getPatientCredentialIdById(rawPatientId.toString());
                      //         }
                      //
                      //         // Fallback to fields in the list item if API did not return it
                      //         credentialId ??= patient["credential_id"]?.toString()
                      //             ?? patient["patient_credential_id"]?.toString()
                      //             ?? patient["patient_credential"]?.toString();
                      //
                      //         // Final fallback: SOS cache (useful right after an SOS arrives)
                      //         credentialId ??= AuthService.lastSosCredentialId;
                      //         print("${AuthService.lastSosCredentialId}");
                      //
                      //         if (credentialId == null) {
                      //           debugPrint("❌ No credential_id found for patient ${rawPatientId ?? ''}. Patient item: ${patient.toString()}");
                      //           ScaffoldMessenger.of(context).showSnackBar(
                      //             const SnackBar(content: Text("Credential not found for this patient")),
                      //           );
                      //           return;
                      //         }
                      //         debugPrint('✅ Using credentialId: ' + credentialId);
                      //       } catch (e) {
                      //         debugPrint("❌ Error resolving credential id: $e");
                      //         ScaffoldMessenger.of(context).showSnackBar(
                      //           const SnackBar(content: Text("Failed to resolve credential id")),
                      //         );
                      //         return;
                      //       }
                      //
                      //       final token = await AuthService().getToken();
                      //       final uri = Uri.parse(
                      //         "https://healiorabackend.rawcode.online/api/v1/medical-records/by-credential/${AuthService.lastSosCredentialId}/pdf",
                      //       );
                      //
                      //       try {
                      //         final response = await http.get(
                      //           uri,
                      //           headers: {
                      //             "Authorization": "Bearer $token",
                      //             "Accept": "application/pdf",
                      //           },
                      //         );
                      //
                      //         if (response.statusCode == 200) {
                      //           final tempDir =
                      //           await getTemporaryDirectory();
                      //           final filePath =
                      //               "${tempDir.path}/record_$credentialId.pdf";
                      //           final file = File(filePath);
                      //           await file
                      //               .writeAsBytes(response.bodyBytes);
                      //           await OpenFile.open(filePath);
                      //         } else {
                      //           ScaffoldMessenger.of(context)
                      //               .showSnackBar(
                      //             const SnackBar(
                      //               content: Text(
                      //                   "Failed to download record"),
                      //             ),
                      //           );
                      //         }
                      //       } catch (e) {
                      //         debugPrint(
                      //             "❌ Error downloading PDF: $e");
                      //         ScaffoldMessenger.of(context)
                      //             .showSnackBar(
                      //           const SnackBar(
                      //             content: Text(
                      //                 "Error downloading record"),
                      //           ),
                      //         );
                      //       }
                      //     },
                      //     style: ElevatedButton.styleFrom(
                      //       backgroundColor: Colors.blueAccent,
                      //       elevation: 3,
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(12),
                      //       ),
                      //       padding: const EdgeInsets.symmetric(
                      //           horizontal: 16, vertical: 10),
                      //     ),
                      //     icon: const Icon(Icons.picture_as_pdf,
                      //         size: 18, color: Colors.white),
                      //     label: const Text(
                      //       "Details",
                      //       style: TextStyle(
                      //         color: Colors.white,
                      //         fontWeight: FontWeight.w600,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
