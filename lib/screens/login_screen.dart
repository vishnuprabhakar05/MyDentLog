import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  /// 🔹 Handles login logic
  void _login(BuildContext context) async {
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool success = await authProvider.login(_emailController.text.trim());

    setState(() => _isLoading = false);

    if (success) {
      print(" Login successful, navigating to SearchScreen");
      Navigator.pushReplacementNamed(context, '/search'); // Navigate to search
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid credentials or not authorized'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); //  Get the theme

    return Scaffold(
      body: Stack(
        children: [
          ///  Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade900, Colors.blueAccent.shade200],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          /// 🌟 Glassmorphism Card
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Blur effect
                child: Container(
                  width: 350,
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2), // Glass effect
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.medical_services_rounded, size: 60, color: Colors.white), 
                      SizedBox(height: 20),
                      Text(
                        "MyDentLog",
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _emailController,
                        style: TextStyle(color: Colors.white), // Text color
                        decoration: InputDecoration(
                          labelText: "Email or Staff ID",
                          labelStyle: TextStyle(color: Colors.white),
                          prefixIcon: Icon(Icons.email_outlined, color: Colors.white),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : FilledButton.icon(
                              onPressed: () => _login(context),
                              icon: Icon(Icons.login, color: Colors.white),
                              label: Text("Login", style: TextStyle(color: Colors.white)),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.blueAccent.shade700,
                                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                      SizedBox(height: 10),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/admin'),
                        child: Text("Signup (Admin Only)", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
