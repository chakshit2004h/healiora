import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../ambulance_side/admin_dashboard.dart';
import '../main.dart';
import 'package:healiora/doctor_side/hospital_dashboard.dart';

class PermissionRequestPage extends StatefulWidget {
  final String role; // So we know where to send the user after permission is granted
  const PermissionRequestPage({required this.role});

  @override
  State<PermissionRequestPage> createState() => _PermissionRequestPageState();
}

class _PermissionRequestPageState extends State<PermissionRequestPage> {
  bool _checking = false;

  Future<void> _checkPermissions() async {
    setState(() => _checking = true);

    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.location,
      Permission.phone,
      Permission.storage,
    ].request();

    bool allGranted = statuses.values.every((status) => status.isGranted);

    if (allGranted) {
      _navigateToRolePage();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please allow all permissions to continue")),
      );
    }

    setState(() => _checking = false);
  }

  void _navigateToRolePage() {
    if (widget.role.toLowerCase() == 'patient') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainNav()));
    } else if (widget.role.toLowerCase().contains('hospital') || widget.role.toLowerCase().contains('doctor')) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HospitalDashboard()));
    } else if (widget.role.toLowerCase() == 'admin') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AdminDashboard()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Permissions Required")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.security, size: 80, color: Colors.teal),
            SizedBox(height: 20),
            Text(
              "We need these permissions for the best experience:",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            _permissionTile("Camera", Icons.camera_alt),
            _permissionTile("Location", Icons.location_on),
            _permissionTile("Phone Access", Icons.phone),
            _permissionTile("Storage", Icons.folder),
            SizedBox(height: 30),
            _checking
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _checkPermissions,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
              ),
              child: Text("Allow All Permissions"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _permissionTile(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(title),
    );
  }
}
