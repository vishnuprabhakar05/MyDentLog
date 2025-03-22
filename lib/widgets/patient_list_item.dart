import 'package:flutter/material.dart';
import '../models/patient_model.dart';

class PatientListItem extends StatelessWidget {
  final PatientModel patient;

  const PatientListItem({Key? key, required this.patient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(patient.name),
      subtitle: Text("OP No: ${patient.opNo} | Phone: ${patient.phone}"),
      trailing: Icon(Icons.arrow_forward),
      onTap: () {
        // Navigate to detailed patient screen (if needed)
      },
    );
  }
}
