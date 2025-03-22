import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
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
  String? _caseSheetPath;

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any, // Allows all types of files
    );

    if (result != null) {
      setState(() {
        _caseSheetPath = result.files.single.path;
      });
    }
  }

  void _savePatient() {
    final patient = PatientModel(
      opNo: _opNoController.text.trim(),
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      place: _placeController.text.trim(),
      caseSheet: _caseSheetPath ?? '', // Store file path
      timestamp: DateTime.now().toIso8601String(),
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
            TextField(
                controller: _opNoController,
                decoration: InputDecoration(labelText: "OP No")),
            TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Name")),
            TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: "Phone")),
            TextField(
                controller: _placeController,
                decoration: InputDecoration(labelText: "Place")),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickFile,
              child: Text("Upload Case Sheet"),
            ),
            if (_caseSheetPath != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "Selected File: ${_caseSheetPath!.split('/').last}",
                  style: TextStyle(fontSize: 14, color: Colors.green),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _savePatient, child: Text("Save"))
          ],
        ),
      ),
    );
  }
}
