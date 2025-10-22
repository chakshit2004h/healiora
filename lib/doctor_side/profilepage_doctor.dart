import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:healiora/mainPage/login.dart';
import 'dart:convert';
import '../services/auth_services.dart';

class DoctorProfilePage extends StatefulWidget {
  const DoctorProfilePage({super.key});

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  bool emergencyAlerts = false;
  Map<String, dynamic>? doctorProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await AuthService().getDoctorProfile();
    if (mounted) {
      setState(() {
        doctorProfile = profile;
        isLoading = false;
      });
    }
  }

  Future<void> _showPasswordChangeDialog() async {
    final oldController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    final codeController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;
    bool isCodeSent = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 12,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.8,
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Change Password",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                            const SizedBox(height: 20),

                            if (!isCodeSent) ...[
                              TextFormField(
                                controller: oldController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: "Current Password",
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (v) => v == null || v.isEmpty
                                    ? "Please enter your current password"
                                    : null,
                              ),
                              const SizedBox(height: 14),

                              TextFormField(
                                controller: newController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: "New Password",
                                  prefixIcon: const Icon(Icons.lock),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (v) => v == null || v.length < 6
                                    ? "Password must be at least 6 characters"
                                    : null,
                              ),
                              const SizedBox(height: 14),

                              TextFormField(
                                controller: confirmController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: "Confirm Password",
                                  prefixIcon:
                                  const Icon(Icons.lock_person_outlined),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (v) => v != newController.text
                                    ? "Passwords do not match"
                                    : null,
                              ),
                              const SizedBox(height: 10),

                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                  Border.all(color: Colors.blue.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline,
                                        color: Colors.blue.shade700, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "A verification code will be sent to your registered email address",
                                        style: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                  Border.all(color: Colors.green.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.email_outlined,
                                        color: Colors.green.shade700, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "Verification code sent to ${doctorProfile?['email'] ?? 'your email'}",
                                        style: TextStyle(
                                          color: Colors.green.shade700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: codeController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: "Enter Verification Code",
                                  prefixIcon:
                                  const Icon(Icons.verified_user_outlined),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  hintText: "Enter 6-digit code",
                                ),
                                validator: (v) => v == null || v.isEmpty
                                    ? "Please enter the verification code"
                                    : v.length < 4
                                    ? "Please enter a valid code"
                                    : null,
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: isSubmitting
                                    ? null
                                    : () async {
                                  setStateDialog(() => isSubmitting = true);
                                  try {
                                    final success = await AuthService()
                                        .requestPasswordChange(
                                      currentPassword:
                                      oldController.text.trim(),
                                      newPassword:
                                      newController.text.trim(),
                                      confirmPassword:
                                      confirmController.text.trim(),
                                    );

                                    if (success) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "Verification code resent!"),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "Error resending code: $e"),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } finally {
                                    setStateDialog(
                                            () => isSubmitting = false);
                                  }
                                },
                                child: const Text("Resend Code"),
                              ),
                            ],

                            const SizedBox(height: 24),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: isSubmitting
                                      ? null
                                      : () => Navigator.pop(context),
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: isSubmitting
                                      ? null
                                      : () async {
                                    if (!isCodeSent) {
                                      if (!formKey.currentState!
                                          .validate()) return;
                                      setStateDialog(
                                              () => isSubmitting = true);

                                      try {
                                        final success = await AuthService()
                                            .requestPasswordChange(
                                          currentPassword:
                                          oldController.text.trim(),
                                          newPassword:
                                          newController.text.trim(),
                                          confirmPassword:
                                          confirmController.text.trim(),
                                        );

                                        if (success) {
                                          setStateDialog(() {
                                            isCodeSent = true;
                                            isSubmitting = false;
                                          });
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "Verification code sent to your email!"),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "Failed to send verification code."),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          setStateDialog(() =>
                                          isSubmitting = false);
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text("Error: $e"),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        setStateDialog(
                                                () => isSubmitting = false);
                                      }
                                    } else {
                                      if (!formKey.currentState!
                                          .validate()) return;
                                      setStateDialog(
                                              () => isSubmitting = true);

                                      try {
                                        final success = await AuthService()
                                            .verifyPasswordChangeCode(
                                          code: codeController.text.trim(),
                                        );

                                        if (success) {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              backgroundColor:
                                              Colors.green,
                                              content: Text(
                                                  "Password changed successfully!"),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "Invalid verification code."),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          setStateDialog(() =>
                                          isSubmitting = false);
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text("Error: $e"),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        setStateDialog(
                                                () => isSubmitting = false);
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                  ),
                                  child: isSubmitting
                                      ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                      : Text(
                                    isCodeSent
                                        ? "Verify & Update"
                                        : "Send Code",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (doctorProfile == null) {
      return const Scaffold(
        body: Center(child: Text("Failed to load profile")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Profile Card
            Card(
              color: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              shadowColor: Colors.blueAccent.withOpacity(0.1),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0, top: 10),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundImage: AssetImage("assets/doctor.png"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "${doctorProfile!['name'] ?? 'Unknown'}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(width: 6),
                              if (doctorProfile!['verified'] == true)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    "Verified",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                              doctorProfile!['specialization'] ??
                                  "Emergency Medicine",
                              style: const TextStyle(
                                  color: Colors.black87, fontSize: 13)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.email_outlined,
                                  size: 16, color: Colors.black54),
                              const SizedBox(width: 6),
                              Text(doctorProfile!['email'] ?? "N/A",
                                  style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.phone_outlined,
                                  size: 16, color: Colors.black54),
                              const SizedBox(width: 6),
                              Text(doctorProfile!['phone_number'] ?? "N/A",
                                  style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            _sectionTitle("Professional details"),
            _card(_infoRow(Icons.school_outlined, "Qualifications",
                doctorProfile!['education'] ?? "N/A")),
            _card(_infoRow(Icons.local_hospital_outlined,
                "Hospital / Department",
                "${doctorProfile!['hospital'] ?? 'N/A'} / ${doctorProfile!['specialization'] ?? 'N/A'}")),

            const SizedBox(height: 6),
            _card(
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: _showPasswordChangeDialog,
                child: _buttonRow(
                    Icons.lock_outline, "Change password / Security", "Manage"),
              ),
            ),

            const SizedBox(height: 20),
            const Divider(thickness: 1),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) =>Login()));
                },
                child: const Text("Logout",
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helpers
  Widget _card(Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black12.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.black87)),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.black54),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.black54, fontSize: 12)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500)),
              ]),
        )
      ],
    );
  }

  Widget _buttonRow(IconData icon, String title, String action,
      {String? subtitle, bool disabled = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            if (subtitle != null)
              Text(subtitle,
                  style:
                  const TextStyle(color: Colors.black54, fontSize: 12)),
          ]),
        ]),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(
                color: disabled ? Colors.grey : Colors.blue, width: 1),
            borderRadius: BorderRadius.circular(6),
            color: disabled ? Colors.grey.shade200 : Colors.transparent,
          ),
          child: Text(
            action,
            style: TextStyle(
              fontSize: 13,
              color: disabled ? Colors.grey : Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        )
      ],
    );
  }
}
