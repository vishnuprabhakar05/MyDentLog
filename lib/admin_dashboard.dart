import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'login_screen.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref().child("users");

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _selectedRole = "Doctor"; // Default role
  bool _isLoading = false;

  void _addUser() async {
    String name = _nameController.text.trim();
    String emailOrStaffID = _emailController.text.trim();

    if (name.isEmpty || emailOrStaffID.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("All fields are required")));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String uid = _usersRef.push().key!;
      await _usersRef.child(uid).set({
        "name": name,
        "email": emailOrStaffID, // Can be email or staff ID
        "role": _selectedRole,
        "admin": false, // Only admin can create users
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User added successfully")));

      _showMoreUsersDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMoreUsersDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("User Created"),
        content: Text("Do you want to add another user?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _nameController.clear();
              _emailController.clear();
              setState(() {
                _selectedRole = "Doctor"; // Reset default role
              });
            },
            child: Text("Yes, Add Another"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
            },
            child: Text("No, Back to Login"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text("Create a New User", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),

            TextField(controller: _nameController, decoration: InputDecoration(labelText: "Full Name")),
            TextField(controller: _emailController, decoration: InputDecoration(labelText: "Email or Staff ID")),

            DropdownButtonFormField<String>(
              value: _selectedRole,
              items: ["Doctor", "Staff"].map((role) => DropdownMenuItem(value: role, child: Text(role))).toList(),
              onChanged: (value) => setState(() => _selectedRole = value!),
              decoration: InputDecoration(labelText: "Select Role"),
            ),

            SizedBox(height: 20),

            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _addUser,
                    child: Text("Add User"),
                  ),
          ],
        ),
      ),
    );
  }
}
