import 'dart:io';
import 'package:healiora/mainPage/records.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:healiora/sidePages/medicalPage.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/ambulance_services.dart';
import '../services/auth_services.dart';
import '../sidePages/emergencybutton.dart';
import '../sidePages/user_card.dart';
import 'hospital.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin{
  late Future<UserProfile?> _userFuture;
  List<dynamic> _nearbyHospitals = [];
  bool _loadingHospitals = true;

  Future<void> requestLocationPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      status = await Permission.location.request();
    }

    if (status.isGranted) {
      print("✅ Location permission granted");
    } else {
      print("❌ Location permission denied");
    }
  }

  Future<void> _fetchNearbyHospitals() async {
    try {
      print("Requesting permission...");
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print("❌ Location permission denied");
          setState(() => _loadingHospitals = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print("❌ Location permissions permanently denied");
        setState(() => _loadingHospitals = false);
        return;
      }

      print("Getting current position...");
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print("📍 Position obtained: ${position.latitude}, ${position.longitude}");

      print("Fetching hospitals...");
      final hospitals = await AuthService().getNearbyHospitals(
        position.latitude,
        position.longitude,
      );
      print("✅ Hospitals fetched: $hospitals");

      setState(() {
        _nearbyHospitals = hospitals;
        _loadingHospitals = false;
      });
    } catch (e) {
      print("❌ Error fetching hospitals: $e");
      setState(() => _loadingHospitals = false);
    }
  }

  Future<void> testApiCall() async {
    try {
      print("Calling getNearbyHospitals with static lat/lng");
      final hospitals = await AuthService().getNearbyHospitals(28.7041, 77.1025);
      print("Hospitals response: $hospitals");
      if (hospitals.isEmpty) {
        print("No hospitals found in API response");
      }
    } catch (e) {
      print("API call failed: $e");
    }
  }
  Future<UserProfile?> userFuture = AuthService().getUserData();
  IO.Socket? socket;

  @override
  void initState() {
    super.initState();
    _fetchNearbyHospitals();
    _userFuture = AuthService().getUserData();
    // load user data
    userFuture = AuthService().getUserData();

    // once user is loaded, initialize socket with token
    userFuture.then((user) async {
      if (user != null) {
        String? token = await AuthService().getToken(); // fetch token
        if (token != null) {
          _initSocket(user.id.toString(), token);
        }
      }
    });
  }

  void _initSocket(String patientId, String token) {
    socket = IO.io(
      'https://healiorabackend.rawcode.online',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({
        "userId": patientId,
        "role": "patient",
        "token": token,
      })
          .disableAutoConnect()
          .build(),
    );

    socket?.connect();

    socket?.onConnect((_) {
      print('✅ Socket connected as patient $patientId');
    });

    socket?.onDisconnect((_) {
      print('❌ Socket disconnected');
    });
  }
  @override
  void dispose() {
    socket?.disconnect();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              _buildProfileCard(),
              SizedBox(height: 16),
              _buildEmergencyButton(context),
              SizedBox(height: 16),
              _buildMedicalRecordsCard(context),
              SizedBox(height: 16),
              _buildHospitalsCard(),
              SizedBox(height: 16),
              _buildAppointmentsCard(),
              SizedBox(height: 16),
              _buildHealthTipCard(),
              SizedBox(height: 16),
              _buildQuickActionsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return FutureBuilder<UserProfile?>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xffe7f1ff),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 12),
                Text("Loading profile..."),
              ],
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xffe7f1ff),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 12),
                Text("Failed to load profile"),
              ],
            ),
          );
        }

        final user = snapshot.data!;

        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xffe7f1ff),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.grey),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.fullName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(user.phoneNumber.isNotEmpty ? user.phoneNumber : "+91 98765 43210"),
                    Text(user.email),
                    Text("${user.age} years • ${user.gender}", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              Icon(Icons.settings, color: Colors.grey),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmergencyButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(Icons.warning_amber_rounded, color: Colors.white),
        label: Text(
          "Trigger Emergency SOS",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.redAccent),
                    SizedBox(height: 16),
                    Text("Sending SOS request...", style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
          );

          try {
            final user = await AuthService().getUserData();
            if (user == null) {
              Navigator.pop(context);
              print("❌ No user data found");
              return;
            }

            var position = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high);

            final ambulanceService = AmbulanceService(user.id.toString());
            await ambulanceService.init();   // ✅ make sure socket is connected

            ambulanceService.updateLocation(position.latitude, position.longitude);

            ambulanceService.requestAmbulance({
              "symptoms": "Chest pain, difficulty breathing",
              "severity": "high",
              "notes": "Patient is conscious but in pain",
              "patient_name": user.fullName,
              "patient_phone": user.phoneNumber,
              "patient_age": user.age,
              "patient_gender": user.gender,
            }, lat: position.latitude, lng: position.longitude);

            Navigator.pop(context);

            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("🚨 SOS Sent"),
                content: Text("Ambulance request sent for ${user.fullName}."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("OK"),
                  )
                ],
              ),
            );
          } catch (e) {
            Navigator.pop(context);
            print("❌ Error sending SOS: $e");

            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("Error"),
                content: Text("Failed to send SOS. Please try again."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("OK"),
                  )
                ],
              ),
            );
          }
        },

        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }



  Widget _buildMedicalRecordsCard(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final user = await AuthService().getUserData();
        if (user != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecordsPage(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to load user data")),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xfff4f8ff),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.folder, color: Colors.orange),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Your Medical Records", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("Tap to view emergency info & history"),
                  SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildHospitalsCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xfff8faff),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Hospitals Near You", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 12),

          if (_nearbyHospitals.isEmpty)
            Center(child: Text("No hospitals found nearby"))
          else
            Column(
              children: _nearbyHospitals.take(2).map((hospital) {
                return _buildHospitalTile(
                  hospital['name'] ?? "Unknown",
                  "${(hospital['distance_km'] ?? 0).toString()} km",
                  "Available",
                  Colors.blue[100]!,
                );
              }).toList(),
            ),

          SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => HospitalPage()));
              },
              child: Text("View All Hospitals",style: TextStyle(color: Colors.blue),),
              style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.blue, width: 1), // 🔹 Blue border
              ),
              elevation: 0,
            ),),
          )
        ],
      ),
    );
  }

  Widget _buildHospitalTile(String name, String distance, String tag, Color tagColor) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(name),
      subtitle: Text(distance),
      trailing: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: tagColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(tag, style: TextStyle(fontSize: 12)),
      ),
    );
  }

  Widget _buildAppointmentsCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xfff4f7fb),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month, color: Colors.blue),
              SizedBox(width: 8),
              Text("Upcoming Appointments", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 20),
          Icon(Icons.calendar_today, size: 40, color: Colors.grey),
          SizedBox(height: 8),
          Text("No appointments linked yet."),
          Text("Coming soon with hospital integration", style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildHealthTipCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xffeaf4ff),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.blue, size: 30),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("💡 Daily Health Tip", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text("Deep breathing for 5 minutes daily can reduce stress significantly."),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xfff8faff),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Quick Actions", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionItem(Icons.qr_code, "Share Profile QR",comingSoon: true),
              _buildActionItem(Icons.shield_outlined, "View Insurance", comingSoon: true),
              _buildActionItem(Icons.insert_drive_file, "Link Health Records",comingSoon: true),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String label, {bool comingSoon = false}) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blue[300]),
        SizedBox(height: 6),
        Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 13)),
        if (comingSoon)
          Container(
            margin: EdgeInsets.only(top: 6),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              border: Border.all(color: Colors.orange),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text("Coming Soon", style: TextStyle(fontSize: 10, color: Colors.orange)),
          )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
Widget _buildHealthTipCard() {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Color(0xffeaf4ff),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.lightbulb_outline, color: Colors.blue, size: 30),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("💡 Daily Health Tip", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text("Deep breathing for 5 minutes daily can reduce stress significantly."),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildQuickActionsCard() {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Color(0xfff8faff),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Quick Actions", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActionItem(Icons.qr_code, "Share Profile QR"),
            _buildActionItem(Icons.verified_user_outlined, "View Insurance", isComingSoon: true),
            _buildActionItem(Icons.insert_drive_file_outlined, "Link Health Records"),
          ],
        )
      ],
    ),
  );
}

Widget _buildActionItem(IconData icon, String title, {bool isComingSoon = false}) {
  return Column(
    children: [
      Icon(icon, size: 32, color: Colors.blueAccent.withOpacity(0.6)),
      SizedBox(height: 6),
      Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 13)),
      if (isComingSoon)
        Container(
          margin: EdgeInsets.only(top: 4),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange),
          ),
          child: Text("Coming Soon", style: TextStyle(fontSize: 10, color: Colors.orange)),
        ),
    ],
  );
}
