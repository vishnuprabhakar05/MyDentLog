import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/patient_model.dart';
import '../providers/patient_provider.dart';

class InputScreen extends StatefulWidget {
  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final TextEditingController _opNoController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _caseSheetController = TextEditingController();

  void _savePatient() {
    final patient = PatientModel(
      opNo: _opNoController.text.trim(),
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      place: _placeController.text.trim(),
      caseSheet: _caseSheetController.text.trim(),
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    Provider.of<PatientProvider>(context, listen: false)
        .addOrUpdatePatient(patient)
        .then((_) => Navigator.pop(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add / Edit Patient")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _opNoController, decoration: InputDecoration(labelText: "OP No")),
            TextField(controller: _nameController, decoration: InputDecoration(labelText: "Name")),
            TextField(controller: _phoneController, decoration: InputDecoration(labelText: "Phone")),
            TextField(controller: _placeController, decoration: InputDecoration(labelText: "Place")),
            TextField(controller: _caseSheetController, decoration: InputDecoration(labelText: "Case Sheet Link")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _savePatient, child: Text("Save"))
          ],
        ),
      ),
    );
  }
}