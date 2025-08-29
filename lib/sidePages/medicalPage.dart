import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_filex/open_filex.dart';


class MedicalDetailsPage extends StatefulWidget {
  @override
  _MedicalDetailsPageState createState() => _MedicalDetailsPageState();
}

class _MedicalDetailsPageState extends State<MedicalDetailsPage> {
  // User basic info (you'll get this from your user service)
  String userName = "chay";
  int userAge = 0;
  String userGender = "Male";

  // Medical details form controllers
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
    // Set default date
    dobController.text = "2025-08-20";
    // Load user data here from your AuthService
    loadUserData();
  }

  Future<void> loadUserData() async {
    // Replace this with your actual user service
    // final user = await AuthService().getUserData();
    // if (user != null) {
    //   setState(() {
    //     userName = user.fullName;
    //     userAge = user.age;
    //     userGender = user.gender;
    //   });
    // }
  }

  Future<void> generateAndDownloadPDF() async {
    setState(() {
      isGenerating = true;
    });

    try {
      // Request storage permission
      await Permission.storage.request();

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Header
              pw.Container(
                padding: pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  border: pw.Border.all(color: PdfColors.blue200),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'MEDICAL DETAILS REPORT',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Generated on: ${DateTime.now().toString().split('.')[0]}',
                      style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 30),

              // Personal Information Section
              pw.Container(
                width: double.infinity,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'PERSONAL INFORMATION',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                    pw.SizedBox(height: 15),
                    pw.Container(
                      padding: pw.EdgeInsets.all(15),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: pw.BorderRadius.circular(5),
                      ),
                      child: pw.Column(
                        children: [
                          _buildInfoRow('Full Name:', userName),
                          _buildInfoRow('Age:', '$userAge years'),
                          _buildInfoRow('Gender:', userGender),
                          _buildInfoRow('Date of Birth:', dobController.text),
                          _buildInfoRow('Blood Group:', bloodGroupController.text.isNotEmpty ? bloodGroupController.text : 'Not specified'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 25),

              // Medical History Section
              pw.Container(
                width: double.infinity,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'MEDICAL HISTORY',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                    pw.SizedBox(height: 15),
                    pw.Container(
                      padding: pw.EdgeInsets.all(15),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: pw.BorderRadius.circular(5),
                      ),
                      child: pw.Column(
                        children: [
                          _buildInfoRow('Past Surgeries:', pastSurgeriesController.text.isNotEmpty ? pastSurgeriesController.text : 'None reported'),
                          _buildInfoRow('Long-term Medications:', longTermMedsController.text.isNotEmpty ? longTermMedsController.text : 'None reported'),
                          _buildInfoRow('Ongoing Illnesses:', ongoingIllnessesController.text.isNotEmpty ? ongoingIllnessesController.text : 'None reported'),
                          _buildInfoRow('Allergies:', allergiesController.text.isNotEmpty ? allergiesController.text : 'None reported'),
                          _buildInfoRow('Other Medical Issues:', otherIssuesController.text.isNotEmpty ? otherIssuesController.text : 'None reported'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 25),

              // Emergency Contact Section
              pw.Container(
                width: double.infinity,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'EMERGENCY CONTACT',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.red800,
                      ),
                    ),
                    pw.SizedBox(height: 15),
                    pw.Container(
                      padding: pw.EdgeInsets.all(15),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.red50,
                        border: pw.Border.all(color: PdfColors.red200),
                        borderRadius: pw.BorderRadius.circular(5),
                      ),
                      child: pw.Column(
                        children: [
                          _buildInfoRow('Contact Name:', emergencyContactNameController.text.isNotEmpty ? emergencyContactNameController.text : 'Not provided'),
                          _buildInfoRow('Contact Number:', emergencyContactNumberController.text.isNotEmpty ? emergencyContactNumberController.text : 'Not provided'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 30),

              // Footer
              pw.Container(
                width: double.infinity,
                padding: pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Text(
                  'This document contains confidential medical information. Keep it secure and share only with authorized healthcare providers.',
                  style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ];
          },
        ),
      );

      // Get directory for saving
      final directory = Directory('/storage/emulated/0/Download');
      final file = File('${directory.path}/medical_details_${DateTime.now().millisecondsSinceEpoch}.pdf');


      // Save PDF
      await file.writeAsBytes(await pdf.save());

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ PDF saved successfully!'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Open',
            textColor: Colors.white,
            onPressed: () async {
              await OpenFilex.open(file.path);   // <-- Opens the saved PDF
            },
          ),
        ),
      );
    } catch (e) {
      print('Error generating PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Failed to generate PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isGenerating = false;
      });
    }
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 150,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medical Details'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Personal Info Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personal Information',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: Text('Name: $userName', style: TextStyle(fontSize: 16))),
                          Text('Age: $userAge', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text('Gender: $userGender', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Medical Details Form
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Medical Details',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                      ),
                      SizedBox(height: 16),

                      _buildTextField('Date of Birth', dobController, icon: Icons.calendar_today),
                      _buildTextField('Blood Group', bloodGroupController, icon: Icons.bloodtype),
                      _buildTextField('Past Surgeries', pastSurgeriesController, icon: Icons.local_hospital, maxLines: 3),
                      _buildTextField('Long-term Medications', longTermMedsController, icon: Icons.medication, maxLines: 3),
                      _buildTextField('Ongoing Illnesses', ongoingIllnessesController, icon: Icons.sick, maxLines: 3),
                      _buildTextField('Allergies', allergiesController, icon: Icons.warning, maxLines: 2),
                      _buildTextField('Other Medical Issues', otherIssuesController, icon: Icons.note_alt, maxLines: 3),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Emergency Contact Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: Colors.red.shade50,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.emergency, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Emergency Contact',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red.shade800),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      _buildTextField('Emergency Contact Name', emergencyContactNameController, icon: Icons.person),
                      _buildTextField('Emergency Contact Number', emergencyContactNumberController, icon: Icons.phone),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Download PDF Button
              Container(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: isGenerating ? null : generateAndDownloadPDF,
                  icon: isGenerating
                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Icon(Icons.picture_as_pdf, size: 24),
                  label: Text(
                    isGenerating ? 'Generating PDF...' : 'Download PDF',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                ),
              ),

              SizedBox(height: 16),

              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  border: Border.all(color: Colors.amber.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber.shade800, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Fill in your medical details and tap "Download PDF" to generate a comprehensive medical report.',
                        style: TextStyle(fontSize: 12, color: Colors.amber.shade800),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {IconData? icon, int maxLines = 1}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, color: Colors.blue.shade600) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
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