import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import 'user_creation_screen.dart'; // New screen for adding users

class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final TextEditingController _adminEmailController = TextEditingController();
  bool _isVerifying = false;

  void _verifyAdmin() async {
    setState(() => _isVerifying = true);

    var user = await FirebaseService.getUserByEmail(_adminEmailController.text.trim());

    setState(() => _isVerifying = false);

    if (user != null && user.role == "admin") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserCreationScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unauthorized admin email!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Verification")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Enter Admin Email",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _adminEmailController,
                decoration: InputDecoration(
                  labelText: "Admin Email",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              _isVerifying
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _verifyAdmin,
                      child: Text("Verify & Proceed"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}