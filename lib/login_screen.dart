import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'admin_dashboard.dart';
import 'search_screen.dart';  


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child("users");

  void _login() async {
    try {
      String email = emailController.text.trim();
      if (email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter your email or staff ID")));
        return;
      }

      // Check if user exists in Firebase Database
      DatabaseEvent event = await _dbRef.orderByChild("email").equalTo(email).once();
      if (event.snapshot.value == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User not found or not approved!")));
        return;
      }

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SearchScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login Failed: $e")));
    }
  }

  void _showAdminAuthDialog() {
    TextEditingController adminEmailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Enter Admin Email"),
        content: TextField(
          controller: adminEmailController,
          decoration: InputDecoration(labelText: "Admin Email"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              _verifyAdmin(adminEmailController.text.trim());
            },
            child: Text("Proceed"),
          ),
        ],
      ),
    );
  }

  void _verifyAdmin(String adminEmail) async {
    if (adminEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter Admin Email")));
      return;
    }

    DatabaseEvent event = await _dbRef.orderByChild("email").equalTo(adminEmail).once();
    if (event.snapshot.value != null) {
      Map data = event.snapshot.value as Map;
      bool isAdmin = data.values.first["admin"] ?? false;
      if (isAdmin) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => AdminDashboard()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Access Denied! Not an Admin.")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Admin Email Not Found!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: InputDecoration(labelText: "Email or Staff ID")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: Text("Login")),
            SizedBox(height: 10),
            TextButton(
              onPressed: _showAdminAuthDialog,
              child: Text("Sign Up (Admin Only)"),
            ),
          ],
        ),
      ),
    );
  }
}
