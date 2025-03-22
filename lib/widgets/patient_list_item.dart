import 'package:flutter/material.dart';
import '../models/patient_model.dart';

class PatientListItem extends StatelessWidget {
  final PatientModel patient;

  const PatientListItem({Key? key, required this.patient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(patient.name, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("OP No: ${patient.opNo} | ${patient.place} | ${patient.phone}"),
        trailing: Icon(Icons.arrow_forward),
        onTap: () {
          // TODO: Navigate to patient details screen (future feature)
        },
      ),
    );
  }
}
