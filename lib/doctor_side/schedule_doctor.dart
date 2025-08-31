import 'package:flutter/material.dart';
import 'package:healiora/doctor_side/patientpage_doctor.dart';

import 'Patientrecordinfo.dart';

class PatientRecordsPage extends StatefulWidget {
  final String? patientName;

  const PatientRecordsPage({super.key, required this.patientName});

  @override
  State<PatientRecordsPage> createState() => _PatientRecordsPageState();
}

class _PatientRecordsPageState extends State<PatientRecordsPage> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> records = [
      {
        "title": "Blood Test",
        "subtitle": "${widget.patientName} · Normal results",
        "date": "12 Aug 2025",
        "tag": "Reports",
        "tagColor": Colors.blue,
      },
      {
        "title": "SOS Triggered",
        "subtitle": "${widget.patientName} · Arrived via Healiora ambulance",
        "date": "05 Aug 2025",
        "tag": "Emergency",
        "tagColor": Colors.red,
      },
      {
        "title": "Prescription",
        "subtitle": "Aisha Khan · Amoxicillin 500mg, 7 days",
        "date": "10 Aug 2025",
        "tag": "Medications",
        "tagColor": Colors.green,
      },
      {
        "title": "SOS Triggered",
        "subtitle": "Rahul Mehta · ER arrival coordinated",
        "date": "11 Aug 2025",
        "tag": "Emergency",
        "tagColor": Colors.red,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Patient Records",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PatientpageDoctor()));
            },
            child: const Text(
              "Patients",
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Recent records",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text("${records.length} items",
                    style: const TextStyle(color: Colors.black54)),
              ],
            ),
            const SizedBox(height: 16),

            /// Records List
            Expanded(
              child: ListView.builder(
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final r = records[index];
                  return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PatientRecordDetailsPage(
                              patientName: "John Carter",
                              caseId: "p-101",
                            ),
                          ),
                        );
                      },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Title + Date
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(r["title"],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 15)),
                              Text(r["date"],
                                  style: const TextStyle(
                                      color: Colors.black54, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 6),

                          /// Subtitle
                          Text(r["subtitle"],
                              style: const TextStyle(
                                  color: Colors.black87, fontSize: 13)),
                          const SizedBox(height: 10),

                          /// Tag (Reports / Emergency / Medications)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: r["tagColor"],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              r["tag"],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            /// Footer tip
            const Text(
              "Tip: Tap any item to open that patient’s records.",
              style: TextStyle(color: Colors.black54, fontSize: 12),
            )
          ],
        ),
      ),
    );
  }
}
