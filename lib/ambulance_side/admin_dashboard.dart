import 'package:flutter/material.dart';
import 'package:healiora/ambulance_side/active_trip.dart';
import 'package:healiora/ambulance_side/history.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}


class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> activeTrips = [];
  List<Map<String, dynamic>> historyTrips = [];

  late final List<Widget> _pages = [
    dashboard(),     // Dashboard content
    ActiveTrip(),    // Active Trip content
    History(historyTrips: historyTrips),       // History content
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // AppBar
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(Icons.health_and_safety, size: 30, color: Colors.teal),
            const Text(
              "Healiora Ambulance",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 18
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12.0),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.black12,
              child: Icon(Icons.person, color: Colors.black),
            ),
          )
        ],
      ),

      // Body
      body: _pages[_selectedIndex],

      // Static Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        elevation: 8,
        selectedFontSize: 10,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_taxi),
            label: "Active Trip",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "History",
          ),
        ],
      ),
    );
  }

  Widget dashboard(){
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "SOS Requests",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Request Card 1
          _sosCard(
            urgency: "CRITICAL",
            urgencyColor: Colors.red,
            time: "2 min ago",
            name: "John Smith",
            id: "P-2024-001",
            address: "123 Main St, Downtown",
            distance: "2.3 km away",
          ),

          const SizedBox(height: 12),

          // Request Card 2
          _sosCard(
            urgency: "HIGH",
            urgencyColor: Colors.blue,
            time: "5 min ago",
            name: "Sarah Johnson",
            id: "P-2024-002",
            address: "456 Oak Ave, Midtown",
            distance: "4.1 km away",
          ),

          const SizedBox(height: 12),

          // Request Card 3
          _sosCard(
            urgency: "NORMAL",
            urgencyColor: Colors.green,
            time: "8 min ago",
            name: "Mike Davis",
            id: "P-2024-003",
            address: "789 Pine Rd, Uptown",
            distance: "1.8 km away",
          ),
        ],
      ),
    );
  }

  // SOS Request Card Widget
  Widget _sosCard({
    required String urgency,
    required Color urgencyColor,
    required String time,
    required String name,
    required String id,
    required String address,
    required String distance,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // urgency + time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: urgencyColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  urgency,
                  style: TextStyle(
                    color: urgencyColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                time,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // name + id
          Text(
            name,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            "ID: $id",
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 8),

          // location
          Row(
            children: [
              const Icon(Icons.location_on,
                  size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(address),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            distance,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),

          const SizedBox(height: 10),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "Map Preview",
              style: TextStyle(color: Colors.black54),
            ),
          ),

          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              setState(() {
                activeTrips.add({
                  "tripId": "TR-${DateTime.now().millisecondsSinceEpoch}", // generate trip id
                  "patientId": id,
                  "name": name,
                  "address": address,
                  "urgency": urgency,
                  "time": DateTime.now(),
                });
              });

              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    insetPadding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _tripDetailsDialog(
                      name: name,
                      id: id,
                      address: address,
                      urgency: urgency,
                      onComplete: (trip) {
                        setState(() {
                          activeTrips.remove(trip);
                          historyTrips.add(trip);
                        });
                        Navigator.pop(context); // close dialog
                      },
                    ),
                  );
                },
              );
            },
            child: const Text("Accept",style: TextStyle(color: Colors.white),),
          )
        ],
      ),
    );
  }
}
Widget _tripDetailsDialog({
  required String name,
  required String id,
  required String address,
  required String urgency,
  required Function(Map<String, dynamic>) onComplete,
}) {
  final tripData = {
    "tripId": "TR-${DateTime
        .now()
        .millisecondsSinceEpoch}",
    "patientId": id,
    "name": name,
    "address": address,
    "urgency": urgency,
    "time": DateTime.now(),
  };
  {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min, // shrink to content
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text("ID: $id",
                        style: const TextStyle(color: Colors.black54)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(address,
                              style: const TextStyle(color: Colors.black87)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  urgency,
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Allergies & Condition
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Allergies",
                      style: TextStyle(
                          fontSize: 12, color: Colors.black54)),
                  Text("N/A",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Condition",
                      style: TextStyle(
                          fontSize: 12, color: Colors.black54)),
                  Text("Unknown",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Buttons Row 1
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.local_hospital),
                  label: const Text("Notify Hospital"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    onComplete(tripData);
                  },
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text("Mark as Completed",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Buttons Row 2
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.call),
                  label: const Text("Call"),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.navigation),
                  label: const Text("Map"),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text("QR Scan"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
