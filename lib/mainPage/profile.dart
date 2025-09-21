import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:healiora/mainPage/help.dart';
import 'package:healiora/mainPage/login.dart';
import 'package:healiora/mainPage/setting_page.dart';
import '../services/auth_services.dart';
import '../sidePages/user_card.dart'; // make sure this has getUserData()

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<UserProfile?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = AuthService().getUserData(); // fetch API data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: false,
      ),
      body: FutureBuilder<UserProfile?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("❌ Error: ${snapshot.error}"));
          }
          final user = snapshot.data;
          if (user == null) {
            return const Center(child: Text("No user data found"));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Manage your account and preferences",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 20),

                // ✅ User Profile Card with API data
                Card(
                  color: Colors.white,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: const Color(0xffe6f0f2),
                              child: Text(
                                user.fullName.isNotEmpty
                                    ? user.fullName[0].toUpperCase()
                                    : "U",
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.fullName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.phoneNumber.isNotEmpty
                                      ? user.phoneNumber
                                      : "N/A",
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user.email,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final updatedUser = await showDialog<UserProfile>(
                                context: context,
                                builder: (context) {
                                  final nameController = TextEditingController(text: user.fullName);
                                  final phoneController = TextEditingController(text: user.phoneNumber);
                                  final emailController = TextEditingController(text: user.email);
                                  final ageController = TextEditingController(text: user.age.toString());
                                  String gender = user.gender; // "Male" or "Female"

                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    title: const Text("Edit Profile"),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          TextField(
                                            controller: nameController,
                                            decoration: const InputDecoration(labelText: "Name"),
                                          ),
                                          TextField(
                                            controller: phoneController,
                                            decoration: const InputDecoration(labelText: "Phone"),
                                          ),
                                          TextField(
                                            controller: emailController,
                                            decoration: const InputDecoration(labelText: "Email"),
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextField(
                                                  controller: ageController,
                                                  keyboardType: TextInputType.number,
                                                  decoration: const InputDecoration(labelText: "Age"),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: DropdownButtonFormField<String>(
                                                  value: gender,
                                                  items: ["Male", "Female", "Other"]
                                                      .map((g) => DropdownMenuItem(
                                                    value: g,
                                                    child: Text(g),
                                                  ))
                                                      .toList(),
                                                  onChanged: (val) {
                                                    if (val != null) gender = val;
                                                  },
                                                  decoration: const InputDecoration(labelText: "Gender"),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, null),
                                        child: const Text("Cancel"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          // ✅ create updated user object
                                          final updated = UserProfile(
                                            fullName: nameController.text,
                                            phoneNumber: phoneController.text,
                                            email: emailController.text,
                                            age: user.age,
                                            gender: gender,
                                            role: user.role,
                                            id: user.id,
                                          );
                                          Navigator.pop(context, updated);
                                        },
                                        child: const Text("Save Changes"),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (updatedUser != null) {
                                // ✅ refresh state with updated user
                                setState(() {
                                  _userFuture = Future.value(updatedUser);
                                });
                              }
                            },

                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text("Edit Profile"),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ✅ Options
                ProfileOptionCard(
                  icon: Icons.settings,
                  title: "Settings",
                  subtitle: "Notification preferences and account settings",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
                  },
                ),
                const SizedBox(height: 12),
                ProfileOptionCard(
                  icon: Icons.help_outline,
                  title: "Help & Support",
                  subtitle: "FAQs and contact support",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => HelpSupportPage()));
                  },
                ),
                const SizedBox(height: 12),
                ProfileOptionCard(
                  icon: Icons.logout,
                  title: "Sign Out",
                  subtitle: "Log out of your account",
                  onTap: () async{
                    final storage = FlutterSecureStorage();
                    await storage.delete(key: 'token');
                    await storage.delete(key: 'role');
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login()));
                  },
                  isLogout: true,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ProfileOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isLogout;

  const ProfileOptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: isLogout ? Colors.red : Colors.blue,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isLogout ? Colors.red : Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isLogout ? Colors.red[300] : Colors.grey,
            fontSize: 13,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
