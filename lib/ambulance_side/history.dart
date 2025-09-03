import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  List<Map<String, dynamic>> _historyTrips = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchAssignedPatients();
  }

  Future<void> _fetchAssignedPatients() async {
    try {
      final response = await http.get(
        Uri.parse(
            "https://healiorabackend.rawcode.online/api/v1/patient-assignments/me-assigned-patients"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer YOUR_TOKEN_HERE", // 🔑 add auth token here
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          // Adapt this parsing based on your API response format
          _historyTrips = List<Map<String, dynamic>>.from(data["items"].map((p) {
            return {
              "tripId": p["id"].toString(),
              "patientId": p["patient"]["id"].toString(),
              "urgency": p["urgency"] ?? "Normal",
              "address": p["patient"]["address"] ?? "Unknown",
              "time": p["created_at"] ?? "",
            };
          }));
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
        });
        print("Failed: ${response.body}");
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_historyTrips.isEmpty) {
      return const Center(child: Text("No assigned patients yet"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _historyTrips.length,
      itemBuilder: (context, index) {
        final trip = _historyTrips[index];
        return Card(
          color: Colors.white,
          elevation: 5,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: RichText(
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          style: const TextStyle(color: Colors.black),
                          children: [
                            const TextSpan(
                                text: "Trip ",
                                style: TextStyle(fontWeight: FontWeight.w500)),
                            TextSpan(
                                text: trip["tripId"],
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            const TextSpan(text: " • Patient "),
                            TextSpan(
                                text: trip["patientId"],
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        trip["urgency"],
                        style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text("${trip["address"]} → Nearest Hospital"),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "${trip["time"]}",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
