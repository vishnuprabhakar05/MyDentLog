import 'package:firebase_database/firebase_database.dart';
import '../models/patient_model.dart';
import '../models/user_model.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import 'package:image_picker/image_picker.dart';

class FirebaseService {
  static final DatabaseReference _database = FirebaseDatabase.instance.ref();

  /// 🔹 Initialize Firebase
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  
  static Future<List<UserModel>> getUsers() async {
    try {
      DatabaseEvent event = await _database.child('users').once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value is Map) {
        Map<String, dynamic> data = Map<String, dynamic>.from(snapshot.value as Map);
        return data.entries
            .map((entry) => UserModel.fromMap(Map<String, dynamic>.from(entry.value)))
            .toList();
      }
    } catch (e) {
      print(' Error fetching users: $e');
    }
    return [];
  }

  
  static Future<UserModel?> getUserByEmail(String emailOrStaffId) async {
    try {
      DatabaseEvent event =
          await _database.child('users').child(emailOrStaffId.replaceAll('.', ',')).once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value is Map) {
        return UserModel.fromMap(Map<String, dynamic>.from(snapshot.value as Map));
      }
    } catch (e) {
      print(' Error fetching user by email: $e');
    }
    return null;
  }

  
  static Future<void> addUser(UserModel user) async {
    try {
      String key = user.email.replaceAll('.', ','); 
      await _database.child('users').child(key).set(user.toMap());
    } catch (e) {
      print(' Error adding user: $e');
    }
  }

  
  static Future<List<PatientModel>> getPatients() async {
    try {
      DatabaseEvent event = await _database.child('patient_details').once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value is Map) {
        Map<String, dynamic> data = Map<String, dynamic>.from(snapshot.value as Map);
        
        List<PatientModel> patients = data.entries.map((entry) {
          String opNo = entry.key;
          Map<String, dynamic> patientData = Map<String, dynamic>.from(entry.value);
          patientData['opNo'] = opNo; 
          return PatientModel.fromMap(patientData);
        }).toList();

        print(" Patients Loaded: ${patients.length}");
        return patients;
      }
    } catch (e) {
      print(' Error fetching patients: $e');
    }
    return [];
  }

  
  static Future<PatientModel?> getPatientByOpNo(String opNo) async {
    try {
      DatabaseEvent event = await _database.child('patient_details').child(opNo).once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value is Map) {
        return PatientModel.fromMap(Map<String, dynamic>.from(snapshot.value as Map));
      }
    } catch (e) {
      print(' Error fetching patient: $e');
    }
    return null;
  }

  
  static Future<void> addOrUpdatePatient(PatientModel patient) async {
    try {
      await _database.child('patient_details').child(patient.opNo).set(patient.toMap());
    } catch (e) {
      print(' Error adding/updating patient: $e');
    }
  }

  
  static Future<String?> uploadCaseSheet(XFile file) async {
    try {
      // Upload file logic...
      String downloadUrl = "uploaded_file_url"; // Replace with actual URL
      return downloadUrl;
    } catch (e) {
      print(" File upload error: $e");
      return null;
    }
  }

 
  static Future<void> addTreatmentHistory(String opNo, String date, String details) async {
    try {
      await _database.child('patient_details').child(opNo).child('TREATMENT_HISTORY').update({
        date: details,
      });
    } catch (e) {
      print(' Error updating treatment history: $e');
    }
  }
}
