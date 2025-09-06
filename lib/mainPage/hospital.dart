import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_services.dart'; // import your AuthService

class HospitalPage extends StatefulWidget {
  @override
  _HospitalPageState createState() => _HospitalPageState();
}

class _HospitalPageState extends State<HospitalPage> {
  final AuthService authService = AuthService();

  final List<String> filters = [
    'Emergency Available',
    'Government',
    'Private',
    'ICU Beds',
    '24/7'
  ];
  final Set<String> selected = {};
  String searchQuery = '';

  List<Hospital> allHospitals = [];
  bool isLoading = false;

  // Replace these with your actual lat/lng or get dynamically
  final double latitude = 28.7041;
  final double longitude = 77.1025;

  @override
  void initState() {
    super.initState();
    fetchHospitals();
  }

  Future<void> fetchHospitals() async {
    setState(() {
      isLoading = true;
    });

    try {
      // ✅ 1. Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print("❌ Location permission denied");
          setState(() => isLoading = false);
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        print("❌ Location permission permanently denied");
        setState(() => isLoading = false);
        return;
      }

      // ✅ 2. Get current location
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print("📍 Location: ${pos.latitude}, ${pos.longitude}");

      // ✅ 3. Fetch hospitals with dynamic coords
      final hospitalsJson = await authService.getNearbyHospitals(
        pos.latitude,
        pos.longitude,
      );

      // ✅ 4. Parse hospitals
      final fetchedHospitals = hospitalsJson.map<Hospital>((json) {
        return Hospital(
          json['name'] ?? 'Unknown',
          List<String>.from(json['specialties'] ?? []),
          isGovernment: json['isGovernment'] ?? false,
          twentyFourSeven: json['twentyFourSeven'] ?? false,
          address: json['address'] ?? '',
          distanceKm: (json['distanceKm'] ?? 0).toDouble(),
        );
      }).toList();

      setState(() {
        allHospitals = fetchedHospitals;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("❌ Error fetching hospitals: $e");
    }
  }
  @override
  Widget build(BuildContext context) {
    final filtered = allHospitals.where((hosp) {
      final matchesSearch = hosp.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          hosp.specialties.any((s) => s.toLowerCase().contains(searchQuery.toLowerCase()));

      if (!matchesSearch) return false;
      if (selected.contains('Emergency Available') &&
          !hosp.specialties.contains('Emergency')) return false;
      if (selected.contains('ICU Beds') &&
          !hosp.specialties.contains('ICU')) return false;
      if (selected.contains('Government') && !hosp.isGovernment) return false;
      if (selected.contains('Private') && hosp.isGovernment) return false;
      if (selected.contains('24/7') && !hosp.twentyFourSeven) return false;

      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Color(0xFFF6FEFD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Search hospitals by name or specialty',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Color(0xFFF1F5F9),
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 12),
              itemCount: filters.length,
              separatorBuilder: (_, __) => SizedBox(width: 8),
              itemBuilder: (_, i) {
                final f = filters[i];
                final isSel = selected.contains(f);
                return FilterChip(
                  label: Text(f),
                  selected: isSel,
                  backgroundColor: Colors.grey[200],
                  selectedColor: Colors.blueAccent,
                  labelStyle: TextStyle(color: isSel ? Colors.white : Colors.black),
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        selected.add(f);
                      } else {
                        selected.remove(f);
                      }
                    });
                  },
                );
              },
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
              child: Text(
                'No hospital found of your matching criteria',
                style: TextStyle(fontSize: 16),
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (_, idx) {
                final h = filtered[idx];
                return GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (_) => HospitalDetailsSheet(hospital: h),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.local_hospital, color: Colors.white),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    h.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on, size: 16, color: Colors.grey),
                                      SizedBox(width: 4),
                                      Text(
                                        "${h.distanceKm.toStringAsFixed(1)} km",
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.bookmark_border, color: Colors.grey[600]),
                          ],
                        ),
                        SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: h.specialties
                              .map(
                                (s) => Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                s,
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          )
                              .toList(),
                        ),
                        SizedBox(height: 12),
                        Text(
                          h.address,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            if (h.specialties.contains('Emergency'))
                              Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    "Emergency",
                                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            if (h.specialties.contains('Emergency')) SizedBox(width: 8),
                            if (h.twentyFourSeven)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Color(0xFFE0F8E9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "24/7 Open",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: h.isGovernment ? Color(0xFFE5EDFB) : Color(0xFFF3E8FF),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                h.isGovernment ? "Government" : "Private",
                                style: TextStyle(
                                  color: h.isGovernment ? Colors.blue : Color(0xFF9B59B6),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Hospital {
  final String name;
  final List<String> specialties;
  final bool isGovernment;
  final bool twentyFourSeven;
  final double distanceKm;
  final String address;

  Hospital(
      this.name,
      this.specialties, {
        required this.isGovernment,
        required this.twentyFourSeven,
        required this.address,
        required this.distanceKm,
      });
}

class HospitalDetailsSheet extends StatelessWidget {
  final Hospital hospital;

  const HospitalDetailsSheet({required this.hospital});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, controller) => SingleChildScrollView(
        controller: controller,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.local_hospital, color: Colors.white),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hospital.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 6,
              children: hospital.specialties.map((s) => Chip(label: Text(s))).toList(),
            ),
            SizedBox(height: 16),
            Text(
              'Contact & Location',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text(hospital.address),
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text('+1 (555) 123-4567'),
              onTap: () => launchUrl(Uri.parse('tel:+15551234567')),
            ),
            ListTile(
              leading: Icon(Icons.access_time),
              title: Text(hospital.twentyFourSeven ? '24/7 Open' : 'Limited Hours'),
            ),
            SizedBox(height: 16),
            Text(
              'About',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Leading hospital providing comprehensive care with emergency services and specialized departments.',
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.call),
                    label: Text('Call Now'),
                    onPressed: () => launchUrl(Uri.parse('tel:+15551234567')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.map),
                    label: Text('View on Map'),
                    onPressed: () {
                      final query = Uri.encodeComponent(hospital.address);
                      launchUrl(
                        Uri.parse('https://www.google.com/maps/search/?api=1&query=$query'),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
