import 'package:flutter/material.dart';
import 'package:healiora/services/auth_services.dart';
import '../sidePages/medical_record.dart';

class RecordsPage extends StatefulWidget {
  @override
  _RecordsPageState createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  MedicalRecord? _record;

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

  Widget _buildSwitch(String label, String field) {
    return SwitchListTile(
      title: Text(label),
      value: field == "smoking"
          ? _smoking
          : field == "drinking"
          ? _drinking
          : _sugar,
      onChanged: (val) {
        setState(() {
          if (field == "smoking") _smoking = val;
          if (field == "drinking") _drinking = val;
          if (field == "sugar") _sugar = val;
        });
      },
    );
  }


  @override
  void initState() {
    super.initState();
    _loadMedicalRecord();
  }

  void _loadMedicalRecord() async {
    try {
      final record = await _authService.getMedicalRecord();
      if (!mounted) return; // ✅ Prevents setState after dispose

      setState(() {
        _record = record;
        _isLoading = false;
      });
    } catch (e) {
      print("❌ Error loading medical record: $e");
      if (!mounted) return; // ✅ Prevents setState after dispose

      setState(() {
        _isLoading = false;
      });
    }
  }


  void _submit() async {
    if (_formKey.currentState!.validate()) {
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

        // new fields
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
        _loadMedicalRecord();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Medical record saved successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Failed to save medical record')),
        );
      }
    }
  }



  Widget _buildSection(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2),
        Text(
          value.isNotEmpty ? value : "Not specified",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildRecordDisplay() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top teal border
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.tealAccent,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Emergency Information",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            // Pre-fill fields with existing record data
                            _controllers['dob']!.text = _record!.dateOfBirth;
                            _controllers['bloodGroup']!.text = _record!.bloodGroup;
                            _controllers['pastSurgeries']!.text = _record!.pastSurgeries;
                            _controllers['medications']!.text = _record!.longTermMedications;
                            _controllers['illnesses']!.text = _record!.ongoingIllnesses;
                            _controllers['allergies']!.text = _record!.allergies;
                            _controllers['otherIssues']!.text = _record!.otherIssues;
                            _controllers['emergencyName']!.text = _record!.emergencyContactName;
                            _controllers['emergencyNumber']!.text = _record!.emergencyContactNumber;
                            _controllers['occupation']!.text = _record!.occupation;
                            _controllers['addiction']!.text = _record!.addiction;
                            _controllers['address']!.text = _record!.address;
                            _smoking = _record!.smoking;
                            _drinking = _record!.drinking;
                            _sugar = _record!.sugar;

                            _isCreating = true; // Switch to form mode
                          });
                        },
                        icon: Icon(Icons.edit, size: 18),
                        label: Text("Edit"),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8),

                  // Blood Group & Last Updated
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSection("Blood Group", _record!.bloodGroup),
                      _buildSection("Last Updated", "28 Jul 2025"),
                    ],
                  ),

                  SizedBox(height: 16),

                  _buildSection("Allergies", _record!.allergies),
                  SizedBox(height: 12),

                  _buildSection("Current Medications", _record!.longTermMedications),
                  SizedBox(height: 12),

                  _buildSection(
                    "Major Surgeries / Conditions",
                    "${_record!.pastSurgeries}${_record!.ongoingIllnesses.isNotEmpty ? ', ' + _record!.ongoingIllnesses : ''}",
                  ),
                  SizedBox(height: 12),

                  // ✅ Emergency Contact
                  _buildSection("Emergency Contact Name", _record!.emergencyContactName),
                  SizedBox(height: 12),
                  _buildSection("Emergency Contact Number", _record!.emergencyContactNumber),
                  SizedBox(height: 16),

                  // ✅ New Fields
                  _buildSection("Occupation", _record!.occupation),
                  SizedBox(height: 12),
                  _buildSection("Addiction", _record!.addiction.isNotEmpty ? _record!.addiction : "None"),
                  SizedBox(height: 12),
                  _buildSection("Address", _record!.address),
                  SizedBox(height: 16),

                  // ✅ Boolean fields
                  _buildSection("Smoking", _record!.smoking ? "Yes" : "No"),
                  SizedBox(height: 12),
                  _buildSection("Drinking", _record!.drinking ? "Yes" : "No"),
                  SizedBox(height: 12),
                  _buildSection("Diabetes (Sugar)", _record!.sugar ? "Yes" : "No"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medical_services_outlined, size: 100, color: Colors.grey),
            SizedBox(height: 20),
            Text("No medical record found.",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
            SizedBox(height: 10),
            Text("Tap below to add your medical information.",
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 30),
            ElevatedButton.icon(
              icon: Icon(Icons.add, color: Colors.white),
              label: Text("Add Medical Record", style: TextStyle(color: Colors.white)),
              onPressed: () {
                setState(() {
                  _isCreating = true;
                });
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  _record == null ? "📝 Create Medical Record" : "✏️ Edit Medical Record",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 16),
                _buildField("Date of Birth (yyyy-mm-dd)", _controllers['dob']!),
                _buildField("Blood Group", _controllers['bloodGroup']!),
                _buildField("Past Surgeries", _controllers['pastSurgeries']!),
                _buildField("Long Term Medications", _controllers['medications']!),
                _buildField("Ongoing Illnesses", _controllers['illnesses']!),
                _buildField("Allergies", _controllers['allergies']!),
                _buildField("Other Issues", _controllers['otherIssues']!),
                _buildField("Emergency Contact Name", _controllers['emergencyName']!),
                _buildField("Emergency Contact Number", _controllers['emergencyNumber']!),
                _buildField("Occupation", _controllers['occupation']!),
                _buildField("Addiction (if any)", _controllers['addiction']!),
                _buildField("Address", _controllers['address']!),

                SizedBox(height: 20),

                // 📌 New Boolean fields (using Switch)
                _buildSwitch("Do you smoke?", "smoking"),
                _buildSwitch("Do you drink alcohol?", "drinking"),
                _buildSwitch("Do you have sugar (diabetes)?", "sugar"),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.save,color: Colors.white,),
                    label: Text(
                  _record == null ? "Submit Record" : "Save Changes",
                    style: TextStyle(fontSize: 16,color: Colors.white),
                  ),
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) =>
        value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Medical Records", style: TextStyle(fontWeight: FontWeight.bold)),
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
    );
  }
}
