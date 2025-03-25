import 'package:get/get.dart';
import '../models/patient_model.dart';
import 'package:firebase_database/firebase_database.dart';

class PatientController extends GetxController {
  var patients = <PatientModel>[].obs;
  var filteredPatients = <PatientModel>[].obs;
  var isLoading = false.obs;
  final DatabaseReference _database = FirebaseDatabase.instance.ref(); 

  @override
  void onInit() {
    super.onInit();
    fetchPatients(); 
  }

  void fetchPatients() {
  isLoading.value = true;

  _database.child('patient_details').onValue.listen((event) {
    if (event.snapshot.value == null) {
      patients.clear();
      filteredPatients.clear();
      print("No patients found.");
    } else if (event.snapshot.value is Map) {
      Map<String, dynamic> data = Map<String, dynamic>.from(event.snapshot.value as Map);
      
      patients.value = data.entries.map((entry) {
        try {
          return PatientModel.fromMap(Map<String, dynamic>.from(entry.value));
        } catch (e) {
          print("Error parsing patient data: $e");
          return null;
        }
      }).whereType<PatientModel>().toList(); // Remove null values safely

      filteredPatients.value = patients;
      print("Patients Updated: ${patients.length}");
    } else {
      print("Unexpected data format in Firebase.");
    }
    isLoading.value = false;
  }, onError: (error) {
    print("Error fetching patients: $error");
    isLoading.value = false;
  });
}

  void filterPatients(String query) {
    if (query.isEmpty) {
      filteredPatients.value = patients;
    } else {
      filteredPatients.value = patients.where((patient) =>
          patient.name.toLowerCase().contains(query.toLowerCase()) ||
          patient.opNo.toLowerCase().contains(query.toLowerCase()) ||
          patient.phone.toLowerCase().contains(query.toLowerCase()) ||
          patient.place.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
  }
  
  Future<void> deletePatient(String opNo) async {
    try {
      isLoading.value = true;
      await _database.child('patient_details/$opNo').remove();
      
      
      patients.removeWhere((patient) => patient.opNo == opNo);
      filteredPatients.removeWhere((patient) => patient.opNo == opNo);

      Get.snackbar("Success", "Patient deleted successfully", backgroundColor: Get.theme.snackBarTheme.backgroundColor);
    } catch (e) {
      Get.snackbar("Error", "Failed to delete patient: $e", backgroundColor: Get.theme.snackBarTheme.backgroundColor);
    } finally {
      isLoading.value = false;
    }
  }
}