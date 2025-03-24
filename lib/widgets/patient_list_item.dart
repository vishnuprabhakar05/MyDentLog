import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/patient_model.dart';
import '../screens/input_screen.dart' as screens;
import '../controllers/patient_controller.dart';

class PatientListItem extends StatelessWidget {
  final PatientModel patient;
  final PatientController patientController = Get.find();

  PatientListItem({Key? key, required this.patient}) : super(key: key);

  void _confirmDelete(BuildContext context) {
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
      onCancel: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(patient.name, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("OP No: ${patient.opNo} | ${patient.place} | ${patient.phone}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Edit Button
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                Get.to(() => screens.InputScreen(), arguments: {'patient': patient, 'isReadOnly': false});
              },
            ),

            
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: () {
                Get.to(() => screens.InputScreen(), arguments: {'patient': patient, 'isReadOnly': true});
              },
            ),

            
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _confirmDelete(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
