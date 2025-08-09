import 'package:flutter/material.dart';
import 'package:healiora/main.dart';
import 'package:healiora/mainPage/admin_dashboard.dart';
import 'package:healiora/mainPage/hospital_dashboard.dart';

import '../services/auth_services.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isLogin = true;
  bool isPhoneLogin = true;
  String email = '';
  String password = '';
  String fullName = '';
  String emergencyNumber = '';
  String age = '';
  String gender = 'Male';
  String phonenumber = '';
  bool isLoading = false;



  void handleLogin() async {
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Email and password required")));
      return;
    }

    setState(() => isLoading = true);

    try {
      final auth = AuthService();
      final success = await auth.login(email, password);

      print('🔍 Login result: $success');

      if (success) {
        final userData = await auth.getUserData();
        print('👤 User data: $userData');

        if (userData != null) {
          final fullName = userData.fullName ?? '';
          await auth.saveName(fullName);

          String role = userData.role;
          if (role.toLowerCase() == 'patient') {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainNav()));
          } else if (role.toLowerCase().contains('hospital') || role.toLowerCase().contains('doctor')) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HospitalDashboard()));
          } else if (role.toLowerCase() == 'admin') {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AdminDashboard()));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Unknown role: $role")));
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login failed")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }


  void handleSignup() async {
    if (fullName.isEmpty || email.isEmpty || password.isEmpty || emergencyNumber.isEmpty || age.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("All fields are required")));
      return;
    }

    setState(() => isLoading = true);

    try {
      final auth = AuthService();
      final signupName = await auth.signup(
        fullName: fullName,
        email: email,
        password: password,
        phoneNumber: phonenumber,
        emergencyContact: emergencyNumber,
        age: age,
        gender: gender,
      );

      if (signupName != null) {
        final success = await auth.login(email, password);
        if (success) {
          await auth.saveName(signupName);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Signup successful")));
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainNav()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login failed after signup")));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Signup failed")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF2F7),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.health_and_safety, size: 64, color: Colors.teal),
                  const SizedBox(height: 12),
                  const Text("Healiora", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  Text("Your Health, Our Priority", style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      toggleButton("Login", isLogin, () => setState(() => isLogin = true)),
                      toggleButton("Sign Up", !isLogin, () => setState(() => isLogin = false)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isLogin ? buildLoginForm() : buildSignUpForm(),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.teal),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildGenderDropdown() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonFormField<String>(
        value: gender,
        icon: const Icon(Icons.arrow_drop_down),
        decoration: const InputDecoration(
          icon: Icon(Icons.transgender),
          border: InputBorder.none,
        ),
        items: ['Male', 'Female', 'Other'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (val) {
          if (val != null) {
            setState(() {
              gender = val;
            });
          }
        },
      ),
    );
  }


  Widget toggleButton(String text, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
  Widget buildOrDivider() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Divider(
            thickness: 1,
            color: Colors.grey.shade400,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            "or continue with",
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
        Expanded(
          child: Divider(
            thickness: 1,
            color: Colors.grey.shade400,
          ),
        ),
      ],
    );
  }

  Widget buildLoginForm() {
    return formCard(
      children: [
        const Text("Welcome Back", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text("Sign in to access your health records", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 20),
        phoneEmailToggle(),
        const SizedBox(height: 10),
        buildInput(isPhoneLogin ? "Mobile Number" : "Email", isPhoneLogin ? Icons.phone : Icons.email,
            onChanged: (val) => email = val),
        buildInput("Password", Icons.lock, isPassword: true, onChanged: (val) => password = val),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: const Text("Forgot Password?", style: TextStyle(color: Colors.teal)),
          ),
        ),
        buildPrimaryButton("Sign In", onPressed: handleLogin),
        const SizedBox(height: 10),
        buildOrDivider(),
        const SizedBox(height: 10),
        buildGoogleButton(),
      ],
    );
  }

  Widget buildSignUpForm() {
    return formCard(
      children: [
        const Text("Create Account", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text("Join Healiora for better healthcare", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 20),
        buildInput("Full Name", Icons.person, onChanged: (val) => fullName = val),
        phoneEmailToggle(),
        const SizedBox(height: 10),
        buildInput(
          isPhoneLogin ? "Mobile Number" : "Email",
          isPhoneLogin ? Icons.phone : Icons.email,
          onChanged: (val) => email = val,
        ),
        buildInput("Password", Icons.lock, isPassword: true, onChanged: (val) => password = val),
        buildInput("Confirm Password", Icons.lock_outline, isPassword: true),
        buildInput("Phone number", Icons.phone, onChanged: (val) => phonenumber = val),
        buildInput("Emergency Contact Number", Icons.contact_phone, onChanged: (val) => emergencyNumber = val),
        buildInput("Age", Icons.cake, onChanged: (val) => age = val),

        buildGenderDropdown(),
        buildPrimaryButton("Sign Up", onPressed: handleSignup),
        const SizedBox(height: 10),
        buildOrDivider(),
        const SizedBox(height: 10),
        buildGoogleButton(),
      ],
    );
  }


  Widget phoneEmailToggle() {
    return Row(
      children: [
        Expanded(
          child: TextButton.icon(
            onPressed: () => setState(() => isPhoneLogin = true),
            icon: Icon(Icons.phone, color: isPhoneLogin ? Colors.teal : Colors.grey),
            label: Text("Phone", style: TextStyle(color: isPhoneLogin ? Colors.teal : Colors.grey)),
          ),
        ),
        Expanded(
          child: TextButton.icon(
            onPressed: () => setState(() => isPhoneLogin = false),
            icon: Icon(Icons.email, color: !isPhoneLogin ? Colors.teal : Colors.grey),
            label: Text("Email", style: TextStyle(color: !isPhoneLogin ? Colors.teal : Colors.grey)),
          ),
        ),
      ],
    );
  }

  Widget buildInput(String hint, IconData icon, {bool isPassword = false, Function(String)? onChanged}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        obscureText: isPassword,
        onChanged: onChanged,
        decoration: InputDecoration(
          icon: Icon(icon),
          hintText: hint,
          border: InputBorder.none,
        ),
      ),
    );
  }


  Widget buildPrimaryButton(String text, {required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.teal.shade200, Colors.teal.shade700]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }

  Widget buildGoogleButton() {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Image.asset(
        'assets/images/google.png',
        height: 20,
        width: 20,
      ),
      label: const Text("Continue with Google"),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }


  Widget formCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

