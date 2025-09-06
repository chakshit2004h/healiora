import 'package:flutter/material.dart';
import 'package:healiora/sidePages/user_card.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_filex/open_filex.dart';

class MedicalDetailsPage extends StatefulWidget {
  final UserProfile user; // pass user data

  const MedicalDetailsPage({super.key, required this.user});

  @override
  _MedicalDetailsPageState createState() => _MedicalDetailsPageState();
}

class _MedicalDetailsPageState extends State<MedicalDetailsPage> {
  late String userName;
  late String userAge;
  late String userGender;

  final TextEditingController dobController = TextEditingController();
  final TextEditingController bloodGroupController = TextEditingController();
  final TextEditingController pastSurgeriesController = TextEditingController();
  final TextEditingController longTermMedsController = TextEditingController();
  final TextEditingController ongoingIllnessesController = TextEditingController();
  final TextEditingController allergiesController = TextEditingController();
  final TextEditingController otherIssuesController = TextEditingController();
  final TextEditingController emergencyContactNameController = TextEditingController();
  final TextEditingController emergencyContactNumberController = TextEditingController();

  bool isGenerating = false;

  @override
  void initState() {
    super.initState();
    userName = widget.user.fullName;
    userAge = widget.user.age;
    userGender = widget.user.gender; // if your UserProfile has DOB
  }

  Future<void> loadUserData() async {
    // load user data here
  }

  Future<void> generateAndDownloadPDF() async {
    setState(() {
      isGenerating = true;
    });

    try {
      await Permission.storage.request();
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(24),
          build: (pw.Context context) {
            return [
              pw.Text("Patient Record – $userName",
                  style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              _buildBoxedSection("Patient Info", [
                _infoRow("Name", userName),
                _infoRow("Age / Gender", "$userAge - $userGender"),
                _infoRow("Date of Birth", dobController.text),
                _infoRow("Blood Group", bloodGroupController.text),
              ]),
              pw.SizedBox(height: 16),
              _buildBoxedSection("Medical Details", [
                _infoRow("Past Surgeries", pastSurgeriesController.text),
                _infoRow("Long-term Medications", longTermMedsController.text),
                _infoRow("Ongoing Illnesses", ongoingIllnessesController.text),
                _infoRow("Allergies", allergiesController.text),
                _infoRow("Other Issues", otherIssuesController.text),
              ]),
              pw.SizedBox(height: 16),
              _buildBoxedSection("Emergency Contact", [
                _infoRow("Name", emergencyContactNameController.text),
                _infoRow("Phone", emergencyContactNumberController.text),
              ]),
            ];
          },
        ),
      );

      final directory = Directory('/storage/emulated/0/Download');
      final file = File('${directory.path}/patient_record_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ PDF saved successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Open',
            textColor: Colors.white,
            onPressed: () async {
              await OpenFilex.open(file.path);
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        isGenerating = false;
      });
    }
  }

  pw.Widget _buildBoxedSection(String title, List<pw.Widget> children) {
    return pw.Container(
      padding: pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16, color: PdfColors.blue800)),
          pw.SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  pw.Widget _infoRow(String key, String value) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(key, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
          pw.Text(value, style: pw.TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back,color: Colors.white,)),
        title: Text('Medical Details',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              _buildCard(
                title: 'Personal Information',
                color: Colors.white,
                children: [
                  _buildInfoRowCard('Name', userName),
                  _buildInfoRowCard('Age', '$userAge'),
                  _buildInfoRowCard('Gender', userGender),
                ],
              ),
              SizedBox(height: 16),
              _buildCard(
                title: 'Medical Details',
                color: Colors.white,
                children: [
                  _buildTextField('Date of Birth', dobController, icon: Icons.calendar_today),
                  _buildTextField('Blood Group', bloodGroupController, icon: Icons.bloodtype),
                  _buildTextField('Past Surgeries', pastSurgeriesController, icon: Icons.local_hospital, maxLines: 3),
                  _buildTextField('Long-term Medications', longTermMedsController, icon: Icons.medication, maxLines: 3),
                  _buildTextField('Ongoing Illnesses', ongoingIllnessesController, icon: Icons.sick, maxLines: 3),
                  _buildTextField('Allergies', allergiesController, icon: Icons.warning, maxLines: 2),
                  _buildTextField('Other Medical Issues', otherIssuesController, icon: Icons.note_alt, maxLines: 3),
                ],
              ),
              SizedBox(height: 16),
              _buildCard(
                title: 'Emergency Contact',
                color: Colors.red.shade50,
                children: [
                  _buildTextField('Emergency Contact Name', emergencyContactNameController, icon: Icons.person),
                  _buildTextField('Emergency Contact Number', emergencyContactNumberController, icon: Icons.phone),
                ],
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: isGenerating ? null : generateAndDownloadPDF,
                icon: isGenerating
                    ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    : Icon(Icons.picture_as_pdf),
                label: Text(isGenerating ? 'Generating PDF...' : 'Download PDF',style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 56),
                  backgroundColor: Colors.blue.shade700,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required Color color, required List<Widget> children}) {
    return Card(
      elevation: 6,
      shadowColor: Colors.grey.shade200,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: color,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
            SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {IconData? icon, int maxLines = 1}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, color: Colors.blue.shade700) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }

  Widget _buildInfoRowCard(String key, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(value, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    dobController.dispose();
    bloodGroupController.dispose();
    pastSurgeriesController.dispose();
    longTermMedsController.dispose();
    ongoingIllnessesController.dispose();
    allergiesController.dispose();
    otherIssuesController.dispose();
    emergencyContactNameController.dispose();
    emergencyContactNumberController.dispose();
    super.dispose();
  }
}
