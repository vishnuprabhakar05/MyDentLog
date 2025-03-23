import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/user_model.dart';

class UserCreationScreen extends StatefulWidget {
  @override
  _UserCreationScreenState createState() => _UserCreationScreenState();
}

class _UserCreationScreenState extends State<UserCreationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _selectedRole = "Doctor";
  bool _isLoading = false;

  void _createUser() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    String emailOrId = _emailController.text.trim(); 

    UserModel newUser = UserModel(
      name: _nameController.text.trim(),
      email: emailOrId, 
      role: _selectedRole,
    );

    await FirebaseService.addUser(newUser);

    setState(() => _isLoading = false);
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("User Created"),
          content: Text("Do you want to add another user?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _nameController.clear();
                _emailController.clear();
              },
              child: Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
              child: Text("No"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create New User")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Full Name"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email or Staff ID"),
            ),
            SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedRole,
              items: ["Doctor", "Staff"].map((role) {
                return DropdownMenuItem(value: role, child: Text(role));
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedRole = value!);
              },
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _createUser,
                    child: Text("Add User"),
                  ),
          ],
        ),
      ),
    );
  }
}
