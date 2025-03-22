import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/patient_provider.dart';
import '../widgets/patient_list_item.dart';

class SearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final patientProvider = Provider.of<PatientProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Search Patients')),
      body: ListView.builder(
        itemCount: patientProvider.patients.length,
        itemBuilder: (context, index) {
          return PatientListItem(patient: patientProvider.patients[index]);
        },
      ),
    );
  }
}