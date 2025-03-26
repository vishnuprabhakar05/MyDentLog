import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../screens/search_screen.dart';
import '../screens/user_creation_screen.dart';

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
                          color: Color.fromRGBO(76, 175, 80, 1),
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
                                  String emailOrStaffId = _emailController.text.trim();

                                  if (emailOrStaffId.isEmpty) {
                                    Get.snackbar(
                                      "Error",
                                      "Please enter Email or Staff ID",
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                    );
                                    return;
                                  }

                                  bool loginSuccess = await authController.login(emailOrStaffId);

                                  if (loginSuccess) {
                                    
                                    Get.offAll(() => SearchScreen());
                                  } else {
                                    Get.snackbar(
                                      "Login Failed",
                                      "Invalid credentials. Please try again.",
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                    );
                                  }
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
                        onPressed: () {
                          _showAdminVerificationDialog(context);
                        },
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

  
  void _showAdminVerificationDialog(BuildContext context) {
    TextEditingController adminEmailController = TextEditingController();

    Get.defaultDialog(
      title: "Admin Verification",
      content: Column(
        children: [
          TextField(
            controller: adminEmailController,
            decoration: InputDecoration(
              labelText: "Enter Admin Email",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          Obx(() {
            return authController.isLoading.value
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      bool isAdmin = await authController.verifyAdmin(adminEmailController.text.trim());
                      if (isAdmin) {
                        Get.back(); // Close the dialog before navigating
                        Get.to(() => UserManagementScreen());
                      } else {
                        Get.snackbar(
                          "Error",
                          "Access denied! Only admins can sign up new users.",
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
                    child: Text("Verify"),
                  );
          }),
        ],
      ),
    );
  }
}
