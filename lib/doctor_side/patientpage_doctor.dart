import 'package:flutter/material.dart';
import 'package:healiora/doctor_side/hospital_dashboard.dart';
import 'package:healiora/doctor_side/schedule_doctor.dart';

class PatientpageDoctor extends StatefulWidget {
  const PatientpageDoctor({super.key});

  @override
  State<PatientpageDoctor> createState() => _PatientpageDoctorState();
}

class _PatientpageDoctorState extends State<PatientpageDoctor> {
  String selectedFilter = "All";
  String searchQuery = "";

  final List<Map<String, dynamic>> patients = [
    {
      "initials": "AJ",
      "name": "Alex Johnson",
      "hospitalId": "SHG-842",
      "caseCode": "HST-AXJ-01",
      "status": "Stable",
      "statusColor": Colors.green,
    },
    {
      "initials": "MS",
      "name": "Maria Santos",
      "hospitalId": "SHG-913",
      "caseCode": "HST-MRS-11",
      "status": "Emergency",
      "statusColor": Colors.red,
    },
    {
      "initials": "IK",
      "name": "Ibrahim Khan",
      "hospitalId": "SHG-221",
      "caseCode": "HST-IBK-07",
      "status": "Under Observation",
      "statusColor": Colors.orange,
    },
    {
      "initials": "PP",
      "name": "Priya Patel",
      "hospitalId": "SHG-377",
      "caseCode": "HST-PPT-02",
      "status": "Stable",
      "statusColor": Colors.green,
    },
  ];

  @override
  Widget build(BuildContext context) {
    /// Apply filtering
    final filteredPatients = patients.where((p) {
      final matchesFilter = selectedFilter == "All" ||
          p["status"].toString().toLowerCase() ==
              selectedFilter.toLowerCase() ||
          (selectedFilter == "Observation" &&
              p["status"] == "Under Observation");

      final matchesSearch = searchQuery.isEmpty ||
          p["name"].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
          p["hospitalId"].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
          p["caseCode"].toString().toLowerCase().contains(searchQuery.toLowerCase());

      return matchesFilter && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            "My Patients",
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => HospitalDashboard()));
              },
              child: const Text(
                "Dashboard",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Patients assigned by St. Helena General",
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 16),

            /// Search Bar + Filter Dropdown
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) {
                      setState(() => searchQuery = val);
                    },
                    decoration: InputDecoration(
                      hintText: "Search by name, ID, or hospital code",
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedFilter,
                      items: const [
                        DropdownMenuItem(value: "All", child: Text("All")),
                        DropdownMenuItem(value: "Stable", child: Text("Stable")),
                        DropdownMenuItem(value: "Emergency", child: Text("Emergency")),
                        DropdownMenuItem(
                            value: "Observation", child: Text("Observation")),
                      ],
                      onChanged: (value) {
                        setState(() => selectedFilter = value!);
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            /// Patients List
            Expanded(
              child: filteredPatients.isEmpty
                  ? const Center(
                child: Text("No patients found"),
              )
                  : ListView.builder(
                itemCount: filteredPatients.length,
                itemBuilder: (context, index) {
                  final p = filteredPatients[index];
                  return PatientCard(
                    initials: p["initials"],
                    name: p["name"],
                    hospitalId: p["hospitalId"],
                    caseCode: p["caseCode"],
                    status: p["status"],
                    statusColor: p["statusColor"],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Patient card widget
class PatientCard extends StatelessWidget {
  final String initials;
  final String name;
  final String hospitalId;
  final String caseCode;
  final String status;
  final Color statusColor;

  const PatientCard({
    super.key,
    required this.initials,
    required this.name,
    required this.hospitalId,
    required this.caseCode,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.blue.shade100,
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text("Hospital ID: $hospitalId",
                    style: const TextStyle(color: Colors.black54, fontSize: 13)),
                Text("Case Code: $caseCode",
                    style: const TextStyle(color: Colors.black54, fontSize: 13)),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PatientRecordsPage(patientName: name),
                    ),
                  );
                },
                child: const Text("View Records", style: TextStyle(color: Colors.white)),
              ),

            ],
          ),
        ],
      ),
    );
  }
}
