import 'package:flutter/material.dart';
import 'package:healiora/doctor_side/patientpage_doctor.dart';
import 'package:healiora/doctor_side/profilepage_doctor.dart';
import 'package:healiora/doctor_side/schedule_doctor.dart';

import '../mainPage/hospital_dashboard.dart';
import 'custombar_doctor.dart';

/// AppShell keeps the BottomNav static for every page
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  final _pages = [
    HospitalDashboard(),
    const PatientpageDoctor(),
    const ScheduleDoctor(),
    const ProfilepageDoctor(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // Keep pages alive & switch with index; bottom bar stays fixed.
        child: IndexedStack(
          index: _index,
          children: _pages,
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
