import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:my_dentlog_app/services/google_drive_service.dart';

class InputScreen extends StatefulWidget {
  final Map<String, dynamic>? patientData;

  InputScreen({this.patientData});

  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("patient_details");
  final TextEditingController _opNoController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  
  final GoogleDriveService _driveService = GoogleDriveService();
  String? _caseSheetUrl;

  @override
  void initState() {
    super.initState();
    if (widget.patientData != null) {
      _opNoController.text = widget.patientData!["OP_NO"];
      _nameController.text = widget.patientData!["NAME"];
      _phoneController.text = widget.patientData!["PHONE"];
      _placeController.text = widget.patientData!["PLACE"];
      _caseSheetUrl = widget.patientData!["CASE_SHEET"];
    }
  }

  Future<void> _uploadCaseSheet() async {
    String? fileUrl = await _driveService.uploadFile();
    if (fileUrl != null) {
      setState(() {
        _caseSheetUrl = fileUrl;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("File uploaded successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload file")),
      );
    }
  }

  void _savePatientDetails() {
    String opNo = _opNoController.text.trim();
    String name = _nameController.text.trim();
    String phone = _phoneController.text.trim();
    String place = _placeController.text.trim();

    if (opNo.isEmpty || name.isEmpty || phone.isEmpty || place.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    Map<String, dynamic> patientData = {
      "NAME": name,
      "PHONE": phone,
      "PLACE": place,
      "CASE_SHEET": _caseSheetUrl ?? "",
      "TIMESTAMP": DateTime.now().toIso8601String(),
    };

    _dbRef.child(opNo).set(patientData).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Patient details saved successfully")),
      );
      Navigator.pop(context);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save data: $error")),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.patientData == null ? "Add Patient Details" : "Edit Patient Details")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _opNoController,
              decoration: InputDecoration(labelText: "OP Number (Required)"),
              enabled: widget.patientData == null,
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Name (Required)"),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: "Phone (Required)"),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: _placeController,
              decoration: InputDecoration(labelText: "Place (Required)"),
            ),
            if (_caseSheetUrl != null) 
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text("File uploaded: $_caseSheetUrl", style: TextStyle(color: Colors.green)),
              ),
            ElevatedButton(
              onPressed: _uploadCaseSheet,
              child: Text("Upload Case Sheet"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _savePatientDetails,
              child: Text(widget.patientData == null ? "Save" : "Update"),
            ),
          ],
        ),
      ),
    );
  }
}
