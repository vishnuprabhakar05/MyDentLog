import 'package:flutter/material.dart';
import '../models/patient_model.dart';
import '../services/firebase_service.dart';

class PatientProvider extends ChangeNotifier {
  List<PatientModel> _patients = [];
  bool _isLoading = false;

  List<PatientModel> get patients => _patients;
  bool get isLoading => _isLoading;

  /// Fetch all patients from Firebase
  Future<void> fetchPatients() async {
  _isLoading = true;
  notifyListeners(); 

  final fetchedPatients = await FirebaseService.getPatients();

  _isLoading = false;
  _patients = fetchedPatients;

  if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
    notifyListeners(); 
  }
}

  /// Add or update a patient
  Future<void> addOrUpdatePatient(PatientModel patient) async {
    await FirebaseService.addOrUpdatePatient(patient);
    await fetchPatients(); // Refresh the list
  }
}
