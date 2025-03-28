import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/patient_model.dart';
import '../screens/input_screen.dart';
import '../controllers/patient_controller.dart';

class PatientListItem extends StatelessWidget {
  final PatientModel patient;
  final PatientController patientController = Get.find();

  PatientListItem({Key? key, required this.patient}) : super(key: key);

  void _confirmDelete() {
    Get.defaultDialog(
      title: "Confirm Delete",
      middleText: "Are you sure you want to delete ${patient.name}?",
      textCancel: "Cancel",
      textConfirm: "Delete",
      confirmTextColor: Colors.white,
      onConfirm: () {
        patientController.deletePatient(patient.opNo);
        Get.back();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(
          patient.name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text("OP No: ${patient.opNo}"),
            Text("${patient.place} • ${patient.phone}"),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // View Button
            IconButton(
              icon: Icon(Icons.visibility, color: Colors.blue),
              tooltip: 'View Details',
              onPressed: () {
                Get.to(
                  () => InputScreen(),
                  arguments: {
                    'patient': patient,
                    'isReadOnly': true,
                  },
                );
              },
            ),
            
            // Edit Button
            IconButton(
              icon: Icon(Icons.edit, color: Colors.green),
              tooltip: 'Edit Patient',
              onPressed: () {
                Get.to(
                  () => InputScreen(),
                  arguments: {
                    'patient': patient,
                    'isReadOnly': false,
                  },
                );
              },
            ),
            
            // Delete Button
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              tooltip: 'Delete Patient',
              onPressed: _confirmDelete, // Now matches VoidCallback type
            ),
          ],
        ),
      ),
    );
  }
}