import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../screens/search_screen.dart';

class SettingsScreen extends StatelessWidget {
  final SettingsController controller = Get.put(SettingsController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade900, Colors.blueAccent.shade200],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Back Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                  onPressed: () => Get.off(() => SearchScreen()),
                ),
              ),
            ),
          ),

          // Centered Settings Card
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
                      Icon(Icons.settings, size: 60, color: Colors.white),
                      SizedBox(height: 10),
                      Text(
                        "Application Settings",
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20),

                      // Google Drive Link Input Field
                      _buildSettingItem(
                        title: "Google Drive Link",
                        controller: controller.googleDriveController,
                        isEnabled: controller.isEditing,
                        hintText: "Enter Google Drive link",
                      ),

                      SizedBox(height: 10),

                      // Edit Button
                      Obx(() => IconButton(
                            icon: Icon(controller.isEditing.value ? Icons.check : Icons.edit),
                            color: controller.isEditing.value ? Colors.green : Colors.white,
                            onPressed: () => controller.toggleEditMode(),
                          )),

                      SizedBox(height: 10),

                      // Save Button (Only visible in edit mode)
                      Obx(() => Visibility(
                            visible: controller.isEditing.value,
                            child: SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: controller.saveSettings,
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text("Save Changes", style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          )),
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

  // Setting Item UI
  Widget _buildSettingItem({
    required String title,
    required TextEditingController controller,
    required RxBool isEnabled,
    required String hintText,
  }) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 5),
            TextField(
              controller: controller,
              enabled: isEnabled.value,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ));
  }
}
