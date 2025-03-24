import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/patient_controller.dart';
import '../controllers/auth_controller.dart';
import '../screens/login_screen.dart';
import 'package:my_dentlog_app/widgets/patient_list_item.dart';
import 'package:my_dentlog_app/screens/input_screen.dart' as screens;
import 'package:my_dentlog_app/screens/labs_screen.dart';

class SearchScreen extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();
  final PatientController patientController = Get.put(PatientController());
  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade900, Colors.blueAccent.shade200],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Search bar and logout button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            // Search bar
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                style: TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: "Search OP No, Name, Phone, Place",
                                  hintStyle: TextStyle(color: Colors.white70),
                                  prefixIcon: Icon(Icons.search, color: Colors.white),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.2),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                onChanged: patientController.filterPatients,
                              ),
                            ),

                            SizedBox(width: 10),

                            // Logout button
                            IconButton(
                              icon: Icon(Icons.logout, color: Colors.white),
                              onPressed: () {
                                authController.logout();
                                Get.offAll(() => LoginScreen());
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Patient list
                Expanded(
                  child: Obx(() {
                    if (patientController.isLoading.value) {
                      return Center(child: CircularProgressIndicator(color: Colors.white));
                    } else if (patientController.filteredPatients.isEmpty) {
                      return Center(child: Text("No patients found", style: TextStyle(color: Colors.white)));
                    } else {
                      return ListView.builder(
                        itemCount: patientController.filteredPatients.length,
                        itemBuilder: (context, index) {
                          return PatientListItem(patient: patientController.filteredPatients[index]);
                        },
                      );
                    }
                  }),
                ),
              ],
            ),
          ),
        ],
      ),

      // Floating action button with a popup menu for "New Patient" and "Add Lab"
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: Icon(Icons.person_add, color: Colors.blueAccent),
                      title: Text("New Patient"),
                      onTap: () {
                        Navigator.pop(context); // Close modal
                        Get.to(() => screens.InputScreen(), arguments: {'patient': null, 'isReadOnly': false});
                      },
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.medical_services, color: Colors.blueAccent),
                      title: Text("Add Lab"),
                      onTap: () {
                        Navigator.pop(context); // Close modal
                        Get.to(() => LabsScreen());
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        icon: Icon(Icons.add, color: Colors.white),
        label: Text("Add", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent.shade700,
      ),
    );
  }
}
