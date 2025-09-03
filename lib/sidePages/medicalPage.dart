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
      await Permission.storage.request();

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(24),
          build: (pw.Context context) {
            return [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Row(
                    children: [
                      pw.Icon(pw.IconData(0xe87c), size: 20, color: PdfColors.red),
                      pw.SizedBox(width: 8),
                      pw.Text(
                        "Patient Record – $userName",
                        style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.black,
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Text(
                      "Download PDF",
                      style: pw.TextStyle(color: PdfColors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                "Auto-shared via SOS alert",
                style: pw.TextStyle(color: PdfColors.grey600, fontSize: 10),
              ),
              pw.SizedBox(height: 16),

              // Tabs Row (Blood, Allergies, Meds)
              pw.Container(
                color: PdfColors.blue900,
                padding: pw.EdgeInsets.all(8),
                child: pw.Row(
                  children: [
                    _buildTag("BLOOD", PdfColors.red, PdfColors.white),
                    pw.SizedBox(width: 8),
                    _buildTag("ALLERGIES", PdfColors.grey700, PdfColors.white),
                    pw.SizedBox(width: 8),
                    _buildTag("Penicillin", PdfColors.red, PdfColors.white),
                    pw.SizedBox(width: 8),
                    _buildTag("MEDS 2 current", PdfColors.blue, PdfColors.white),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Patient Info + Address
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: _buildBoxedSection("Patient Info", [
                      _infoRow("Name", userName),
                      _infoRow("Age / Gender", "$userAge - $userGender"),
                      _infoRow("Occupation", "Factory Supervisor"),
                    ]),
                  ),
                  pw.SizedBox(width: 16),
                  pw.Expanded(
                    child: _buildBoxedSection("Location / Address", [
                      _infoRow("Address", "221B Baker Street"),
                      _infoRow("City", "London"),
                      _infoRow("Addictions", "Smoking"),
                    ]),
                  ),
                ],
              ),
              pw.SizedBox(height: 16),

              // Current Medications + Chronic Conditions
              pw.Row(
                children: [
                  pw.Expanded(
                    child: _buildBoxedSection("Current Medications", [
                      pw.Bullet(text: "Insulin"),
                      pw.Bullet(text: "Warfarin"),
                    ]),
                  ),
                  pw.SizedBox(width: 16),
                  pw.Expanded(
                    child: _buildBoxedSection("Chronic Conditions", [
                      pw.Bullet(text: "Diabetes"),
                      pw.Bullet(text: "Asthma"),
                    ]),
                  ),
                ],
              ),
              pw.SizedBox(height: 16),

              // Emergency Contact
              _buildBoxedSection("Emergency Contact", [
                _infoRow("Name", "Jamie Johnson"),
                _infoRow("Relation", "Spouse"),
                _infoRow("Phone", "+1 555-2222"),
              ], color: PdfColors.red50),

              pw.SizedBox(height: 16),

              // Past Diagnoses
              _buildBoxedSection("Past Diagnoses / Major Illnesses", [
                _infoRow("Asthma", "Apr 3, 2018"),
                _infoRow("Hypertension", "Aug 12, 2020"),
                _infoRow("Diabetes Type 2", "Jan 18, 2022"),
              ]),

              pw.SizedBox(height: 16),

              // Immunizations
              _buildBoxedSection("Immunizations & Preventive Care", [
                pw.Text("No immunization data."),
              ]),

              pw.SizedBox(height: 16),

              // Hospitalizations
              _buildBoxedSection("Other (Previous Hospitalizations)", [
                pw.Bullet(
                    text:
                    "St. Mary’s General Hospital, London: admitted for stroke on Jan 12, 2023, discharged Jan 18, 2023."),
                pw.Bullet(
                    text:
                    "City Care Hospital, London: admitted for asthma exacerbation on Jun 1, 2021, discharged Jun 3, 2021."),
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
      print("❌ Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        isGenerating = false;
      });
    }
  }

  pw.Widget _buildTag(String text, PdfColor bg, PdfColor color) {
    return pw.Container(
      padding: pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: pw.BoxDecoration(
        color: bg,
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(color: color, fontSize: 10, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  pw.Widget _buildBoxedSection(String title, List<pw.Widget> children, {PdfColor color = PdfColors.white}) {
    return pw.Container(
      padding: pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: color,
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14, color: PdfColors.blue800),
          ),
          pw.SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  pw.Widget _infoRow(String key, String value) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 2),
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
                      : Icon(Icons.picture_as_pdf, size: 24,color: Colors.white,),
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