import 'package:flutter/material.dart';

class EmergencySOSDialog extends StatelessWidget {
  const EmergencySOSDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button (X)
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.close, size: 20),
              ),
            ),
            const SizedBox(height: 10),

            // Warning icon and title
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.warning, color: Colors.red, size: 24),
                SizedBox(width: 8),
                Text(
                  "Emergency SOS",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 8),

            const Text(
              "This will immediately notify:",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 15),

            // Emergency services
            Row(
              children: const [
                Icon(Icons.call, color: Colors.blue),
                SizedBox(width: 10),
                Text("Emergency services (108)"),
              ],
            ),
            const SizedBox(height: 10),

            // Nearby hospitals
            Row(
              children: const [
                Icon(Icons.local_hospital, color: Colors.blue),
                SizedBox(width: 10),
                Text("Nearby hospitals"),
              ],
            ),
            const SizedBox(height: 10),

            // Emergency contacts
            Row(
              children: const [
                Icon(Icons.person, color: Colors.blue),
                SizedBox(width: 10),
                Text("Your emergency contacts"),
              ],
            ),
            const SizedBox(height: 25),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Cancel",style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      // Your SOS logic here
                      Navigator.of(context).pop(); // Close after action
                    },
                    child: const Text("Send SOS",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
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
