import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/patient_model.dart';
import '../services/firebase_service.dart';

class InputScreen extends StatefulWidget {
  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _opNoController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  
  String? _caseSheetUrl;
  bool _isLoading = false;
  Map<String, String> _treatmentHistory = {};

  void _pickFile() async {
    final ImagePicker _picker = ImagePicker();
    XFile? file = await _picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      setState(() => _isLoading = true);
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      String? uploadedUrl = await firebaseService.uploadCaseSheet(file);
      setState(() {
        _caseSheetUrl = uploadedUrl;
        _isLoading = false;
      });
      if (uploadedUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("File upload failed")),
        );
      }
    }
  }

  void _openCaseSheet() {
    String date = DateTime.now().toIso8601String().split("T")[0];
    TextEditingController _caseNotesController =
        TextEditingController(text: _treatmentHistory[date] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Treatment History - $date"),
        content: TextField(
          controller: _caseNotesController,
          maxLines: 8,
          decoration: InputDecoration(hintText: "Enter treatment details...", border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() => _treatmentHistory[date] = _caseNotesController.text);
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  void _savePatient() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    String opNo = _opNoController.text.trim();
    final firebaseService = Provider.of<FirebaseService>(context, listen: false);
    PatientModel? existingPatient = await FirebaseService.getPatientByOpNo(opNo);

    Map<String, String> updatedHistory = existingPatient?.treatmentHistory ?? {};
    updatedHistory.addAll(_treatmentHistory);

    final patient = PatientModel(
      opNo: opNo,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      place: _placeController.text.trim(),
      caseSheet: _caseSheetUrl ?? existingPatient?.caseSheet ?? '',
      timestamp: DateTime.now().toIso8601String(),
      treatmentHistory: updatedHistory,
    );

    await FirebaseService.addOrUpdatePatient(patient);

    setState(() => _isLoading = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add / Edit Patient")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Patient Details", style: Theme.of(context).textTheme.headlineSmall),
              SizedBox(height: 15),
              TextFormField(
                controller: _opNoController,
                decoration: InputDecoration(labelText: "OP No", prefixIcon: Icon(Icons.numbers), border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Name", prefixIcon: Icon(Icons.person), border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: "Phone", prefixIcon: Icon(Icons.phone), border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _placeController,
                decoration: InputDecoration(labelText: "Place", prefixIcon: Icon(Icons.location_on), border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickFile,
                icon: Icon(Icons.camera_alt),
                label: Text("Upload Case Sheet"),
              ),
              if (_caseSheetUrl != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text("Uploaded File: $_caseSheetUrl", style: TextStyle(fontSize: 14, color: Colors.green), overflow: TextOverflow.ellipsis),
                ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _openCaseSheet,
                icon: Icon(Icons.edit_note),
                label: Text("Treatment History"),
              ),
              SizedBox(height: 20),
              if (_treatmentHistory.isNotEmpty) ...[
                Text("Past Visits:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ..._treatmentHistory.keys.map((date) => ListTile(
                      title: Text(date),
                      trailing: Icon(Icons.arrow_forward),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Case Sheet - $date"),
                            content: TextField(
                              controller: TextEditingController(text: _treatmentHistory[date]),
                              maxLines: 8,
                              readOnly: true,
                              decoration: InputDecoration(border: OutlineInputBorder()),
                            ),
                            actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("Close"))],
                          ),
                        );
                      },
                    )),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _savePatient,
                  child: _isLoading ? CircularProgressIndicator(color: Colors.white) : Text("Save Patient"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
