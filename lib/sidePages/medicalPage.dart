import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class MedicalPage extends StatelessWidget {
  void _openFilePicker(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File Selected: ${result.files.single.name}')),
      );
    } else {
      // User canceled the picker
    }
  }

  Widget _buildEmergencyInfoCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Color(0xFFEFF7FF),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.warning_amber, color: Colors.red),
              SizedBox(width: 8),
              Text("Emergency Info", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ]),
            SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _infoTag("Blood Group", "O+", Icons.bloodtype, Colors.deepOrange),
                _infoTag("Current Meds", "Metformin, Lisinopril", Icons.medication, Colors.blue),
                _infoTag("Allergies", "Penicillin, Shellfish", Icons.warning, Colors.orange),
                _infoTag("Major Surgeries", "Appendectomy, Gallbladder", Icons.healing, Colors.purple),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _infoTag(String title, String value, IconData icon, Color color) {
    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          SizedBox(width: 4),
          Text(value, style: TextStyle(color: Colors.white)),
        ],
      ),
      backgroundColor: color,
    );
  }

  Widget _buildMedicalEntry(String date, String title, String subtitle, String tag, Color tagColor, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: tagColor),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Chip(label: Text(tag), backgroundColor: tagColor.withOpacity(0.1), labelStyle: TextStyle(color: tagColor)),
      ),
    );
  }

  Widget _buildUploadBox(BuildContext context) {
    return GestureDetector(
      onTap: () => _openFilePicker(context),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(Icons.add_circle_outline, size: 40, color: Colors.blue),
            SizedBox(height: 8),
            Text("Add Previous Report", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text("Upload PDF or image files from your device", style: TextStyle(color: Colors.grey)),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _openFilePicker(context),
              child: Text("Choose Files",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Medical History",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
        backgroundColor: Colors.lightBlue,
      ),
      body: ListView(
        children: [
          _buildEmergencyInfoCard(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text("Past Medical Entries", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          _buildMedicalEntry("15 Dec 2024", "Cardiac Checkup", "Routine Heart Examination", "cardiac", Colors.red, Icons.favorite),
          _buildMedicalEntry("28 Nov 2024", "Blood Test Results", "Comprehensive Metabolic Panel", "general", Colors.blue, Icons.science),
          _buildMedicalEntry("10 Oct 2024", "Neurological Consultation", "Migraine Follow-up", "neuro", Colors.purple, Icons.psychology),
          _buildMedicalEntry("22 Sep 2024", "Annual Health Checkup", "Preventive Care Screening", "checkup", Colors.green, Icons.local_hospital),
          _buildUploadBox(context),
        ],
      ),
    );
  }
}
