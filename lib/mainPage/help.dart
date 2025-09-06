import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help & Support"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // 📞 Contact Support
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Contact Support",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  // Email Support
                  ListTile(
                    leading: const Icon(Icons.email, color: Colors.blue),
                    title: const Text("Email Support"),
                    subtitle: const Text("support@healiora.com"),
                    onTap: () {
                      // TODO: open email intent
                    },
                  ),

                  // Emergency Helpline
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size.fromHeight(45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      // TODO: dial helpline
                    },
                    icon: const Icon(Icons.call, color: Colors.white),
                    label: const Text("1-800-HEALIORA",
                        style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Emergency Helpline Hours: Available 24/7 for urgent medical emergencies and app-related issues.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ❓ Frequently Asked Questions
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Frequently Asked Questions",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  ExpansionTile(
                    title: const Text("What happens when I trigger SOS?"),
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Your emergency contacts and local authorities are alerted immediately with your location."),
                      )
                    ],
                  ),
                  ExpansionTile(
                    title: const Text("Who can see my medical records?"),
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Only you and authorized healthcare professionals can access your records."),
                      )
                    ],
                  ),
                  ExpansionTile(
                    title: const Text("How do I add emergency contacts?"),
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Go to Settings > Emergency Contacts to add or update your contacts."),
                      )
                    ],
                  ),
                  ExpansionTile(
                    title: const Text("How does location sharing work?"),
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Your GPS location is shared only during active SOS or emergency events."),
                      )
                    ],
                  ),
                  ExpansionTile(
                    title: const Text("Can I access my records offline?"),
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Yes, some records are cached for offline use, but updates require internet."),
                      )
                    ],
                  ),
                  ExpansionTile(
                    title: const Text("How secure is my health data?"),
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Your data is encrypted end-to-end and complies with HIPAA and GDPR standards."),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 💡 Quick Tips
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Quick Tips",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),

                  ListTile(
                    leading: Icon(Icons.system_update, color: Colors.blue),
                    title: Text("Keep App Updated"),
                    subtitle: Text("Always use the latest version for the best security and features."),
                  ),
                  ListTile(
                    leading: Icon(Icons.contacts, color: Colors.blue),
                    title: Text("Update Emergency Contacts"),
                    subtitle: Text("Review your emergency contacts regularly to ensure they're current."),
                  ),
                  ListTile(
                    leading: Icon(Icons.location_on, color: Colors.blue),
                    title: Text("Enable Location Services"),
                    subtitle: Text("Allow location access for faster emergency response times."),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
