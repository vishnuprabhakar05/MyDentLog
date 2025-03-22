import 'package:firebase_database/firebase_database.dart';
import '../models/patient_model.dart';
import '../models/user_model.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

class FirebaseService {
  static final DatabaseReference _database = FirebaseDatabase.instance.ref();

  /// Initialize Firebase
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  /// Fetch all users
  static Future<List<UserModel>> getUsers() async {
    try {
      DatabaseEvent event = await _database.child('users').once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null && snapshot.value is Map) {
        Map<dynamic, dynamic> data = snapshot.value as Map;
        return data.entries.map((entry) {
          return UserModel.fromMap(entry.value as Map<String, dynamic>);
        }).toList();
      }
    } catch (e) {
      print('Error fetching users: $e');
    }
    return [];
  }

  /// Fetch a user by email or staff ID
  static Future<UserModel?> getUserByEmail(String email) async {
    try {
      // Convert email to a Firebase-friendly key
      String key = email.replaceAll('.', ','); 

      DatabaseEvent event = await _database.child('users').child(key).once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null && snapshot.value is Map) {
        return UserModel.fromMap(snapshot.value as Map<String, dynamic>);
      }
    } catch (e) {
      print('Error fetching user by email: $e');
    }
    return null;
  }

  /// Add a new user
  static Future<void> addUser(UserModel user) async {
    try {
      // Use email as the key, replacing "." with "," (Firebase does not allow ".")
      String key = user.email.replaceAll('.', ',');

      await _database.child('users').child(key).set(user.toMap());
    } catch (e) {
      print('Error adding user: $e');
    }
  }

  /// Fetch all patient details
  static Future<List<PatientModel>> getPatients() async {
    try {
      DatabaseEvent event = await _database.child('patient_details').once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null && snapshot.value is Map) {
        Map<dynamic, dynamic> data = snapshot.value as Map;
        return data.entries.map((entry) {
          return PatientModel.fromMap(entry.value as Map<String, dynamic>);
        }).toList();
      }
    } catch (e) {
      print('Error fetching patients: $e');
    }
    return [];
  }

  /// Fetch a single patient by OP number
  static Future<PatientModel?> getPatientByOpNo(String opNo) async {
    try {
      DatabaseEvent event =
          await _database.child('patient_details').child(opNo).once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null && snapshot.value is Map) {
        return PatientModel.fromMap(snapshot.value as Map<String, dynamic>);
      }
    } catch (e) {
      print('Error fetching patient: $e');
    }
    return null;
  }

  /// Add or update a patient
  static Future<void> addOrUpdatePatient(PatientModel patient) async {
    try {
      await _database.child('patient_details').child(patient.opNo).set(patient.toMap());
    } catch (e) {
      print('Error adding/updating patient: $e');
    }
  }
}
