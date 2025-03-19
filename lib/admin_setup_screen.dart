import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'admin_dashboard.dart';

class AdminSetupScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child("users");

  void _setupAdmin(BuildContext context) async {
    try {
      final UserCredential userCredential = await _auth.signInWithPopup(GoogleAuthProvider());
      final User? user = userCredential.user;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Google Sign-In failed")));
        return;
      }

      // Check if admin already exists
      DatabaseEvent event = await _dbRef.orderByChild("admin").equalTo(true).once();
      if (event.snapshot.value != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Admin already exists!")));
        return;
      }

      // ✅ Store the first user as Admin
      await _dbRef.child(user.uid).set({
        "email": user.email,
        "role": "admin",
        "admin": true,
      });

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminDashboard()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Setup")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _setupAdmin(context),
          child: Text("Login as Admin"),
        ),
      ),
    );
  }
}
