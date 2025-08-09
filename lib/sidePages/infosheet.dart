import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditEmergencyInfoSheet extends StatefulWidget {
  final Function(Map<String, String>) onSave;

  EditEmergencyInfoSheet({required this.onSave});

  @override
  _EditEmergencyInfoSheetState createState() => _EditEmergencyInfoSheetState();
}

class _EditEmergencyInfoSheetState extends State<EditEmergencyInfoSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String _formattedDate = DateFormat('d MMM yyyy').format(DateTime.now());

  String _selectedBloodGroup = "O+";
  final List<String> bloodGroups = ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"];

  final TextEditingController _allergyController =
  TextEditingController(text: "Penicillin, Shellfish");
  final TextEditingController _medicationController =
  TextEditingController(text: "Lisinopril 10mg daily, Metformin 500mg twice daily");
  final TextEditingController _conditionController =
  TextEditingController(text: "Hypertension (2019), Type 2 Diabetes (2021)");

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rerender to show the correct tab content
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _allergyController.dispose();
    _medicationController.dispose();
    _conditionController.dispose();
    super.dispose();
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            controller: controller,
            maxLines: null,
            decoration: InputDecoration(border: InputBorder.none),
          ),
        ),
      ],
    );
  }

  Widget buildTabContent() {
    switch (_tabController.index) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Blood Group", style: TextStyle(fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedBloodGroup,
              items: bloodGroups
                  .map((group) => DropdownMenuItem(value: group, child: Text(group)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBloodGroup = value!;
                });
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        );
      case 1:
        return buildTextField("Known Allergies", _allergyController);
      case 2:
        return buildTextField("Current Medications", _medicationController);
      case 3:
        return buildTextField("Major Surgeries / Conditions", _conditionController);
      default:
        return SizedBox.shrink();
    }
  }

  void handleSave() {
    final Map<String, String> updatedData = {
      "bloodGroup": "${_selectedBloodGroup} • $_formattedDate",
      "allergies": "${_allergyController.text.trim()} • $_formattedDate",
      "medications": "${_medicationController.text.trim()} • $_formattedDate",
      "conditions": "${_conditionController.text.trim()} • $_formattedDate",
    };

    widget.onSave(updatedData);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text("Edit Emergency Info",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),

          // Tab bar
          Container(
            decoration: BoxDecoration(
              color: const Color(0xfff5f8fc),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true, // Allows tabs to take space based on content
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600), // Reduced font size
              unselectedLabelStyle: TextStyle(fontSize: 12),
              tabs: const [
                Tab(child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text("Basic Info"),
                )),
                Tab(child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text("Allergies"),
                )),
                Tab(child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text("Medications"),
                )),
                Tab(child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text("Conditions"),
                )),
              ],
            ),

          ),

          SizedBox(height: 20),
          buildTabContent(),
          SizedBox(height: 20),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff00b09c),
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text("Save Changes", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
