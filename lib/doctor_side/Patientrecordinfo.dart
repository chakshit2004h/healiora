import 'package:flutter/material.dart';

class PatientRecordDetailsPage extends StatefulWidget {
  final String patientName;
  final String caseId;

  const PatientRecordDetailsPage({
    super.key,
    required this.patientName,
    required this.caseId,
  });

  @override
  State<PatientRecordDetailsPage> createState() => _PatientRecordDetailsPageState();
}

class _PatientRecordDetailsPageState extends State<PatientRecordDetailsPage> {
  int _selectedTabIndex = 0;

  final List<String> _tabs = [
    "Medical History",
    "Medications",
    "Reports & Tests",
    "Emergency"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Records"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text("Patients"),
          )
        ],
      ),
      body: Column(
        children: [
          // ✅ Patient info card
          _buildPatientInfoCard(),

          // ✅ Horizontal tab selector
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _tabs.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedTabIndex == index;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ChoiceChip(
                    label: Text(_tabs[index]),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedTabIndex = index;
                      });
                    },
                    selectedColor: Colors.blue,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                );
              },
            ),
          ),

          // ✅ Tab body
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientInfoCard() {
    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              child: Text(widget.patientName[0]),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.patientName, style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text("42 • Male • O+"),
                Text("Case ID ${widget.caseId}", style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text("Stable", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0: // Medical History
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _recordCard("Allergy", "Peanut allergy noted", "01 Aug 2025", "History", Colors.blue),
          ],
        );
      case 1: // Medications
        return const Center(
          child: Text("No records available yet\nRecords for this patient will appear here."),
        );
      case 2: // Reports
        return const Center(child: Text("Reports & Tests will be shown here"));
      case 3: // Emergency
        return const Center(child: Text("Emergency history will be shown here"));
      default:
        return const SizedBox();
    }
  }

  Widget _recordCard(String title, String subtitle, String date, String tag, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
              child: Text(tag, style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
