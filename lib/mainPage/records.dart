// records_page.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:healiora/services/auth_services.dart';
import 'package:pdf/pdf.dart';
import '../sidePages/medical_record.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../sidePages/user_card.dart';

class RecordsPage extends StatefulWidget {
  @override
  _RecordsPageState createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  MedicalRecord? _record;
  UserProfile? _user; // from same API as homepage

  bool _isLoading = true;
  bool _isCreating = false;

  final _controllers = {
    'dob': TextEditingController(),
    'bloodGroup': TextEditingController(),
    'pastSurgeries': TextEditingController(),
    'medications': TextEditingController(),
    'illnesses': TextEditingController(),
    'allergies': TextEditingController(),
    'otherIssues': TextEditingController(),
    'emergencyName': TextEditingController(),
    'emergencyNumber': TextEditingController(),
    'occupation' : TextEditingController(),
    'addiction' : TextEditingController(),
    'smoking' : TextEditingController(),
    'drinking' : TextEditingController(),
    'address' : TextEditingController(),
    'sugar' : TextEditingController(),
  };

  bool _smoking = false;
  bool _drinking = false;
  bool _sugar = false;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _loadMedicalRecord(),
      _loadUser(),   // ✅ both load together
    ]);
    if (!mounted) return;
    setState(() => _isLoading = false);
  }


  Future<void> _loadUser() async {
    try {
      final u = await _authService.getUserData();
      print("✅ User data loaded: $u");
      if (!mounted) return;
      setState(() => _user = u);
    } catch (e) {
      print("❌ Error loading user profile: $e");
    }
  }

  Future<void> _loadMedicalRecord() async {
    try {
      final record = await _authService.getMedicalRecord();
      if (!mounted) return;
      setState(() {
        _record = record;
        if (record != null) {
          // Prefill switches and controllers (keeps form consistent)
          _controllers['dob']!.text = record.dateOfBirth;
          _controllers['bloodGroup']!.text = record.bloodGroup;
          _controllers['pastSurgeries']!.text = record.pastSurgeries;
          _controllers['medications']!.text = record.longTermMedications;
          _controllers['illnesses']!.text = record.ongoingIllnesses;
          _controllers['allergies']!.text = record.allergies;
          _controllers['otherIssues']!.text = record.otherIssues;
          _controllers['emergencyName']!.text = record.emergencyContactName;
          _controllers['emergencyNumber']!.text = record.emergencyContactNumber;
          _controllers['occupation']!.text = record.occupation;
          _controllers['addiction']!.text = record.addiction;
          _controllers['address']!.text = record.address;
          _smoking = record.smoking;
          _drinking = record.drinking;
          _sugar = record.sugar;
        }
      });
    } catch (e) {
      print("❌ Error loading medical record: $e");
    }
  }

  @override
  void dispose() {
    _controllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  Widget _buildSwitch(String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(label, style: TextStyle(fontSize: 14)),
      value: value,
      onChanged: onChanged,
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final newRecord = MedicalRecord(
      dateOfBirth: _controllers['dob']!.text,
      bloodGroup: _controllers['bloodGroup']!.text,
      pastSurgeries: _controllers['pastSurgeries']!.text,
      longTermMedications: _controllers['medications']!.text,
      ongoingIllnesses: _controllers['illnesses']!.text,
      allergies: _controllers['allergies']!.text,
      otherIssues: _controllers['otherIssues']!.text,
      emergencyContactName: _controllers['emergencyName']!.text,
      emergencyContactNumber: _controllers['emergencyNumber']!.text,
      occupation: _controllers['occupation']!.text,
      addiction: _controllers['addiction']!.text,
      address: _controllers['address']!.text,
      smoking: _smoking,
      drinking: _drinking,
      sugar: _sugar,
    );

    bool success;
    if (_record == null) {
      success = await _authService.createMedicalRecord(newRecord);
    } else {
      success = await _authService.updateMedicalRecord(newRecord);
    }

    if (success) {
      setState(() {
        _isCreating = false;
      });
      await _loadMedicalRecord();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Medical record saved successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed to save medical record')),
      );
    }
  }

  // ---------- PDF Generation ----------
  Future<void> _generatePdfAndShare() async {
    final doc = pw.Document();

    // Helper to convert bool to Yes/No
    String yn(bool? v) => (v ?? false) ? "Yes" : "No";

    final fullName = _user?.fullName ?? "Unknown";
    final phone = _user?.phoneNumber ?? "";
    final email = _user?.email ?? "";
    final age = _user?.age.toString() ?? "";
    final gender = _user?.gender ?? "";

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return [
            pw.Container(
              padding: pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey300, width: 1),
                ),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Healiora', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Medical Record', style: pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Date: ${DateTime.now().toLocal().toString().split(' ').first}', style: pw.TextStyle(fontSize: 10)),
                      pw.Text('ID: ${_user?.id ?? ''}', style: pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 12),

            // Personal details section
            pw.Container(
              padding: pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey300, width: 1),
                ),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Personal Details', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    children: [
                      pw.Expanded(child: pw.Text('Name: $fullName')),
                      pw.SizedBox(width: 10),
                      pw.Expanded(child: pw.Text('Phone: $phone')),
                    ],
                  ),
                  pw.SizedBox(height: 6),
                  pw.Row(
                    children: [
                      pw.Expanded(child: pw.Text('Email: $email')),
                      pw.SizedBox(width: 10),
                      pw.Expanded(child: pw.Text('Age: $age  •  Gender: $gender')),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 16),

            // Medical form fields - more 'real life' layout
            pw.Container(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Medical Information', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 8),

                  pw.Row(children: [
                    pw.Expanded(child: pw.Text('Date of Birth: ${_record?.dateOfBirth ?? "Not specified"}')),
                    pw.Expanded(child: pw.Text('Blood Group: ${_record?.bloodGroup ?? "Not specified"}')),
                  ]),
                  pw.SizedBox(height: 6),

                  pw.Text('Allergies: ${_record?.allergies ?? "Not specified"}'),
                  pw.SizedBox(height: 6),

                  pw.Text('Current Medications: ${_record?.longTermMedications ?? "Not specified"}'),
                  pw.SizedBox(height: 6),

                  pw.Text('Major Surgeries / Conditions: ${((_record?.pastSurgeries ?? '') + ((_record?.ongoingIllnesses?.isNotEmpty ?? false) ? ', ' + (_record?.ongoingIllnesses ?? '') : '')).trim()}'),
                  pw.SizedBox(height: 12),

                  // Emergency Contact
                  pw.Text('Emergency Contact', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 6),
                  pw.Row(children: [
                    pw.Expanded(child: pw.Text('Name: ${_record?.emergencyContactName ?? "Not specified"}')),
                    pw.Expanded(child: pw.Text('Phone: ${_record?.emergencyContactNumber ?? "Not specified"}')),
                  ]),

                  pw.SizedBox(height: 12),

                  // Occupation / Addiction / Address
                  pw.Row(children: [
                    pw.Expanded(child: pw.Text('Occupation: ${_record?.occupation ?? "Not specified"}')),
                    pw.Expanded(child: pw.Text('Addiction: ${_record?.addiction?.isNotEmpty == true ? _record!.addiction : "None"}')),
                  ]),
                  pw.SizedBox(height: 6),
                  pw.Text('Address: ${_record?.address ?? "Not specified"}'),

                  pw.SizedBox(height: 12),

                  // Boolean flags
                  pw.Row(children: [
                    pw.Expanded(child: pw.Text('Smoking: ${yn(_record?.smoking)}')),
                    pw.Expanded(child: pw.Text('Drinking: ${yn(_record?.drinking)}')),
                    pw.Expanded(child: pw.Text('Diabetes (Sugar): ${yn(_record?.sugar)}')),
                  ]),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Signature area
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Container(width: 200, child: pw.Column(children: [pw.Text('Patient signature:'), pw.SizedBox(height: 40), pw.Text('(Sign here)')])),
                pw.Container(width: 200, child: pw.Column(children: [pw.Text('Doctor signature:'), pw.SizedBox(height: 40), pw.Text('(Sign here)')])),
              ],
            ),

            pw.SizedBox(height: 12),
            pw.Divider(),
            pw.Text('This is a generated medical record. Please consult your doctor for clinical advice.', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
          ];
        },
      ),
    );

    final Uint8List bytes = await doc.save();
    final filename = '${fullName.replaceAll(' ', '_')}_medical_record.pdf';
    await Printing.sharePdf(bytes: bytes, filename: filename);
  }

  // ---------- UI builders ----------
  Widget _buildSection(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        SizedBox(height: 4),
        Text(value.isNotEmpty ? value : "Not specified", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87)),
      ],
    );
  }

  Widget _buildRecordDisplay() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Header card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.red.shade100,
                            child: Icon(Icons.person, color: Colors.red),
                          ),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Patient Record – ${_user?.fullName ?? "Unknown"}",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Text("Medical Record", style: TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                        ],
                      ),

                      // ✅ Edit button
                      ElevatedButton(
                          onPressed: () => _openEditDialog(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text("Edit",style: TextStyle(color: Colors.white),)
                      )
                    ],
                  ),

                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.cake, size: 18, color: Colors.grey),
                      SizedBox(width: 6),
                      Text("${_record?.dateOfBirth ?? "N/A"}"),
                      SizedBox(width: 16),
                      Icon(Icons.male, size: 18, color: Colors.grey),
                      SizedBox(width: 6),
                      Text("${_user?.gender ?? "N/A"}"),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // 🔹 Current Medications + Chronic Conditions
          Row(
            children: [
              Expanded(
                child: _buildInfoCard("Current Medications", [
                  _record?.longTermMedications.isNotEmpty == true
                      ? Text(_record!.longTermMedications)
                      : Text("None"),
                ]),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard("Chronic Conditions", [
                  Wrap(
                    spacing: 6,
                    children: (_record?.ongoingIllnesses.isNotEmpty == true
                        ? _record!.ongoingIllnesses.split(',')
                        : ["None"]).map((c) {
                      return Chip(
                        label: Text(c.trim()),
                        backgroundColor: Colors.red.shade50,
                        labelStyle: TextStyle(color: Colors.red),
                      );
                    }).toList(),
                  ),
                ]),
              ),
            ],
          ),

          SizedBox(height: 16),
          // Row for Blood Group and Addiction
          Row(
            children: [
              Expanded(
                child: _buildInfoCard("Blood Group", [
                  Text(
                    _record?.bloodGroup.isNotEmpty == true
                        ? _record!.bloodGroup
                        : "Not specified",
                  ),
                ]),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard("Addiction", [
                  Text(
                    _record?.addiction.isNotEmpty == true
                        ? _record!.addiction
                        : "None",
                  ),
                ]),
              ),
            ],
          ),

          SizedBox(height: 12),

// Row for Smoking and Drinking
          Row(
            children: [
              Expanded(
                child: _buildInfoCard("Smoking", [
                  Text(_record?.smoking == true ? "Yes" : "No"),
                ]),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard("Drinking", [
                  Text(_record?.drinking == true ? "Yes" : "No"),
                ]),
              ),
            ],
          ),

          SizedBox(height: 12),

// Row for Diabetes and Allergies
          Row(
            children: [
              Expanded(
                child: _buildInfoCard("Diabetes", [
                  Text(_record?.sugar == true ? "Yes" : "No"),
                ]),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard("Allergies", [
                  Wrap(
                    spacing: 6,
                    children: (_record?.allergies.isNotEmpty == true
                        ? _record!.allergies.split(',')
                        : ["None"]).map((a) {
                      return Chip(
                        label: Text(a.trim()),
                        backgroundColor: Colors.orange.shade50,
                        labelStyle: TextStyle(color: Colors.orange),
                      );
                    }).toList(),
                  ),
                ]),
              ),
            ],
          ),

          // 🔹 Emergency Contact
          _buildInfoCard("Emergency Contact", [
            ListTile(
              leading: Icon(Icons.phone, color: Colors.black87),
              title: Text(_record?.emergencyContactName ?? "Unknown"),
              subtitle: Text(_record?.emergencyContactNumber ?? "Not available"),
            )
          ]),

          SizedBox(height: 16),

          // 🔹 Past Diagnoses
          _buildInfoCard("Past Diagnoses / Major Illnesses", [
            _buildTimelineItem("Hypertension", "Aug 12, 2020"),
            _buildTimelineItem("Type 2 Diabetes", "Nov 5, 2019"),
            _buildTimelineItem("Seasonal Allergies", "Apr 8, 2018"),
          ]),

          SizedBox(height: 16),

          // 🔹 Previous Hospitalizations
          _buildInfoCard("Previous Hospitalizations", [
            _buildTimelineItem("San Francisco General Hospital", "Mar 15, 2020",
                desc: "Admitted for: Cardiac monitoring and chest pain evaluation"),
            _buildTimelineItem("UCSF Medical Center", "Mar 4, 2018",
                desc: "Admitted for: Diabetes medication management"),
            _buildTimelineItem("Kaiser Permanente SF", "Aug 12, 2017",
                desc: "Admitted for: Severe asthma exacerbation"),
          ]),

          SizedBox(height: 16),

          // 🔹 Immunizations
          ExpansionTile(
            title: Text("Immunization & Preventive Care",
                style: TextStyle(fontWeight: FontWeight.w600)),
            children: [ListTile(title: Text("Vaccination records not provided"))],
          ),

          SizedBox(height: 16),

          // 🔹 Other
          ExpansionTile(
            title: Text("Other", style: TextStyle(fontWeight: FontWeight.w600)),
            children: [
              ListTile(
                title: Text("Lifestyle: Non-smoker, moderate exercise"),
              ),
              ListTile(
                title: Text("Diet: Balanced, low sodium"),
              ),
            ],
          ),

          SizedBox(height: 24),

          // 🔹 Footer
          Center(
            child: Column(
              children: [
                Text("Healiora",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black54)),
                SizedBox(height: 4),
                Text("Generated on ${DateTime.now().toLocal().toString().split(' ').first}",
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(String title, String date, {String? desc}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: desc != null ? Text(desc, style: TextStyle(color: Colors.grey[700])) : null,
      trailing: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(date, style: TextStyle(color: Colors.white, fontSize: 12)),
      ),
    );
  }



  // An improved, more 'real life' form layout
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: Offset(0,3))]),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(_record == null ? "📝 Create Medical Record" : "✏️ Edit Medical Record", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),

                // Two-column row for DOB & Blood group
                Row(children: [
                  Expanded(child: _buildField("Date of Birth (yyyy-mm-dd)", _controllers['dob']!)),
                  SizedBox(width: 12),
                  Expanded(child: _buildField("Blood Group", _controllers['bloodGroup']!)),
                ]),

                SizedBox(height: 6),

                // Larger text areas for surgeries / meds
                _buildField("Major Surgeries / Past Conditions", _controllers['pastSurgeries']!, maxLines: 3),
                _buildField("Long Term Medications", _controllers['medications']!, maxLines: 3),
                _buildField("Ongoing Illnesses", _controllers['illnesses']!, maxLines: 3),
                _buildField("Allergies", _controllers['allergies']!, maxLines: 3),
                _buildField("Other Issues", _controllers['otherIssues']!, maxLines: 2),

                SizedBox(height: 8),
                Divider(),
                SizedBox(height: 8),

                _buildField("Emergency Contact Name", _controllers['emergencyName']!),
                _buildField("Emergency Contact Number", _controllers['emergencyNumber']!),

                SizedBox(height: 10),
                Row(children: [
                  Expanded(child: _buildField("Occupation", _controllers['occupation']!)),
                  SizedBox(width: 12),
                  Expanded(child: _buildField("Addiction (if any)", _controllers['addiction']!)),
                ]),

                SizedBox(height: 8),
                _buildField("Address", _controllers['address']!, maxLines: 2),

                SizedBox(height: 12),

                // Switches as compact tiles
                _buildSwitch("Do you smoke?", _smoking, (v) => setState(() => _smoking = v)),
                _buildSwitch("Do you drink alcohol?", _drinking, (v) => setState(() => _drinking = v)),
                _buildSwitch("Do you have diabetes (sugar)?", _sugar, (v) => setState(() => _sugar = v)),

                SizedBox(height: 18),
                Row(children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _submit,
                      icon: Icon(Icons.save, color: Colors.white),
                      label: Text(_record == null ? "Submit Record" : "Save Changes", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, padding: EdgeInsets.symmetric(vertical: 14)),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Cancel edit & reload
                        setState(() {
                          _isCreating = false;
                        });
                        _loadMedicalRecord();
                      },
                      icon: Icon(Icons.cancel),
                      label: Text("Cancel"),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.medical_services_outlined, size: 100, color: Colors.grey),
          SizedBox(height: 20),
          Text("No medical record found.", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
          SizedBox(height: 10),
          Text("Tap below to add your medical information.", style: TextStyle(fontSize: 16, color: Colors.grey)),
          SizedBox(height: 30),
          ElevatedButton.icon(
            icon: Icon(Icons.add, color: Colors.white),
            label: Text("Add Medical Record", style: TextStyle(color: Colors.white)),
            onPressed: () => setState(() => _isCreating = true),
            style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14), backgroundColor: Colors.teal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          )
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Medical Records",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.lightBlue,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _isCreating
          ? _buildForm()
          : _record != null
          ? _buildRecordDisplay()
          : _buildEmptyState(),

      // ✅ Proper bottom button
      bottomNavigationBar: (!_isCreating && _record != null)
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: _generatePdfAndShare,
          icon: Icon(Icons.download, size: 20, color: Colors.white),
          label: Text("Download PDF",
              style: TextStyle(color: Colors.white, fontSize: 16)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            padding: EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      )
          : null,
    );
  }
  void _openEditDialog() {
    final tempControllers = {
      'bloodGroup': TextEditingController(text: _record?.bloodGroup ?? ""),
      'medications': TextEditingController(text: _record?.longTermMedications ?? ""),
      'illnesses': TextEditingController(text: _record?.ongoingIllnesses ?? ""),
      'allergies': TextEditingController(text: _record?.allergies ?? ""),
      'emergencyName': TextEditingController(text: _record?.emergencyContactName ?? ""),
      'emergencyNumber': TextEditingController(text: _record?.emergencyContactNumber ?? ""),
      'addiction': TextEditingController(text: _record?.addiction ?? ""),
    };

    bool smoking = _record?.smoking ?? false;
    bool drinking = _record?.drinking ?? false;
    bool sugar = _record?.sugar ?? false;

    showDialog(
      useSafeArea: true,
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            return AlertDialog(
              title: Text("Edit Medical Info"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildDialogField("Blood Group", tempControllers['bloodGroup']!),
                    _buildDialogField("Current Medications", tempControllers['medications']!, maxLines: 2),
                    _buildDialogField("Chronic Conditions", tempControllers['illnesses']!, maxLines: 2),
                    _buildDialogField("Allergies", tempControllers['allergies']!, maxLines: 2),
                    _buildDialogField("Addiction", tempControllers['addiction']!),
                    _buildDialogField("Emergency Contact Name", tempControllers['emergencyName']!),
                    _buildDialogField("Emergency Contact Number", tempControllers['emergencyNumber']!),

                    SwitchListTile(
                      title: Text("Smoking"),
                      value: smoking,
                      onChanged: (v) => setStateDialog(() => smoking = v),
                    ),
                    SwitchListTile(
                      title: Text("Drinking"),
                      value: drinking,
                      onChanged: (v) => setStateDialog(() => drinking = v),
                    ),
                    SwitchListTile(
                      title: Text("Diabetes (Sugar)"),
                      value: sugar,
                      onChanged: (v) => setStateDialog(() => sugar = v),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final updatedRecord = MedicalRecord(
                      dateOfBirth: _record?.dateOfBirth ?? "",
                      bloodGroup: tempControllers['bloodGroup']!.text,
                      pastSurgeries: _record?.pastSurgeries ?? "",
                      longTermMedications: tempControllers['medications']!.text,
                      ongoingIllnesses: tempControllers['illnesses']!.text,
                      allergies: tempControllers['allergies']!.text,
                      otherIssues: _record?.otherIssues ?? "",
                      emergencyContactName: tempControllers['emergencyName']!.text,
                      emergencyContactNumber: tempControllers['emergencyNumber']!.text,
                      occupation: _record?.occupation ?? "",
                      addiction: tempControllers['addiction']!.text,
                      address: _record?.address ?? "",
                      smoking: smoking,
                      drinking: drinking,
                      sugar: sugar,
                    );

                    bool success = await _authService.updateMedicalRecord(updatedRecord);
                    if (success) {
                      setState(() => _record = updatedRecord);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("✅ Record updated")),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("❌ Failed to update record")),
                      );
                    }
                  },
                  child: Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDialogField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }


}
