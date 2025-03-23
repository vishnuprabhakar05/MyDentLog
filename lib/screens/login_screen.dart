import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../screens/search_screen.dart';

class LoginScreen extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade900, Colors.blueAccent.shade200],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          /// Glassmorphism Card
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: 350,
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
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
                        style: TextStyle(color: Colors.white),
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

                      
                      Obx(() {
                        return authController.isLoading.value
                            ? CircularProgressIndicator(color: Colors.white)
                            : FilledButton.icon(
                                onPressed: () async {
                                  await authController.login(_emailController.text.trim());
                                  Get.offAll(() => SearchScreen()); 
                                },
                                icon: Icon(Icons.login, color: Colors.white),
                                label: Text("Login", style: TextStyle(color: Colors.white)),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.blueAccent.shade700,
                                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                      }),

                      SizedBox(height: 10),
                      TextButton(
                        onPressed: () => Get.toNamed('/admin'),
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
