import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/firebase_service.dart';
import '../models/settings_model.dart';

class SettingsController extends GetxController {
  final TextEditingController googleDriveController = TextEditingController();
  var settings = SettingsModel(googleDriveLink: "").obs;
  var isEditing = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  void loadSettings() async {
    settings.value = await FirebaseService.getGoogleDriveLinkFromSettings();
    googleDriveController.text = settings.value.googleDriveLink;
  }

  void toggleEditMode() {
    isEditing.value = !isEditing.value;
  }

  void saveSettings() async {
    settings.value.googleDriveLink = googleDriveController.text.trim();
    await FirebaseService.updateSettings(settings.value);
    isEditing.value = false;
    Get.snackbar("Success", "Settings updated!", backgroundColor: Colors.green, snackPosition: SnackPosition.BOTTOM);
  }
}
