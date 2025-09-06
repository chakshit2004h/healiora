import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:healiora/mainPage/login.dart';

import 'ambulance_side/admin_dashboard.dart';
import 'doctor_side/hospital_dashboard.dart';
import 'mainPage/homepage.dart';
import 'mainPage/hospital.dart';
import 'mainPage/profile.dart';
import 'mainPage/records.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = FlutterSecureStorage();
  final token = await storage.read(key: 'token');
  final role = await storage.read(key: 'role');
  print("DEBUG: token = $token");
  print("DEBUG: role = $role");

  runApp(MyApp(isLoggedIn: token != null,role: role));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? role;

  const MyApp({super.key, required this.isLoggedIn, this.role});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? _getHomeForRole(role) : Login(),
    );
  }
  Widget _getHomeForRole(String? role) {
    switch (role) {
      case 'doctor':
        return HospitalDashboard();
      case 'ambulance':
        return AdminDashboard();
      case 'patient':
        return MainNav(); // bottom nav for patient
      default:
        return Login(); // fallback
    }
  }
}

class MainNav extends StatefulWidget {
  @override
  _MainNavState createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    RecordsPage(),
    HospitalPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: SizedBox(
        height: 80,
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: _currentIndex,
          selectedItemColor: Color(0xFF009688), // teal color like in your image
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Records'),
            BottomNavigationBarItem(icon: Icon(Icons.local_hospital), label: 'Hospitals'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
