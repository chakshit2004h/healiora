import 'package:flutter/material.dart';

class History extends StatefulWidget {
  final List<Map<String, dynamic>> historyTrips;
  const History({super.key, required this.historyTrips});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: widget.historyTrips.length,
      itemBuilder: (context, index) {
        final trip = widget.historyTrips[index];
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
