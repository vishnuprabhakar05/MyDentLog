import 'dart:convert';
import 'package:flutter/services.dart';

class LabConfig {
  static List<String> workTypes = [];

  static Future<void> loadLabWorkTypes() async {
    try {
      String jsonString = await rootBundle.loadString('lib/assets/lab_work_type.json');
      Map<String, dynamic> jsonData = json.decode(jsonString);
      workTypes = List<String>.from(jsonData['work_types']);
    } catch (e) {
      print("Error loading lab work types: $e");
      workTypes = [];
    }
  }
}
