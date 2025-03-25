import 'package:firebase_database/firebase_database.dart';
import '../models/patient_model.dart';
import '../models/user_model.dart';
import '../models/lab_model.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import 'package:image_picker/image_picker.dart';

class FirebaseService {
  static final DatabaseReference database = FirebaseDatabase.instance.ref();

  
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  
  static Future<UserModel?> getUserByEmail(String emailOrStaffId) async {
    try {
      DatabaseEvent event =
          await database.child('users').child(emailOrStaffId.replaceAll('.', '_')).once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value is Map) {
        return UserModel.fromMap(Map<String, dynamic>.from(snapshot.value as Map));
      }
    } catch (e) {
      print('Error fetching user by email: $e');
    }
    return null;
  }

  
  static Future<bool> createUser(UserModel user) async {
    try {
      String key = user.email.replaceAll('.', '_');
      await database.child('users').child(key).set(user.toMap());
      print("User successfully added: ${user.toMap()}");
      return true;
    } catch (e) {
      print('Error saving user: $e');
      return false;
    }
  }

  
  static Future<List<PatientModel>> getPatients() async {
    try {
      DatabaseEvent event = await database.child('patient_details').once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value is Map) {
        Map<String, dynamic> data = Map<String, dynamic>.from(snapshot.value as Map);
        
        List<PatientModel> patients = data.entries.map((entry) {
          String opNo = entry.key;
          Map<String, dynamic> patientData = Map<String, dynamic>.from(entry.value);
          patientData['opNo'] = opNo;
          return PatientModel.fromMap(patientData);
        }).toList();

        print("Patients Loaded: ${patients.length}");
        return patients;
      }
    } catch (e) {
      print('Error fetching patients: $e');
    }
    return [];
  }

  
  static Future<PatientModel?> getPatientByOpNo(String opNo) async {
    try {
      DatabaseEvent event = await database.child('patient_details').child(opNo).once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value is Map) {
        return PatientModel.fromMap(Map<String, dynamic>.from(snapshot.value as Map));
      }
    } catch (e) {
      print('Error fetching patient: $e');
    }
    return null;
  }

  
  static Future<void> addOrUpdatePatient(PatientModel patient) async {
    try {
      await database.child('patient_details').child(patient.opNo).set(patient.toMap());
    } catch (e) {
      print('Error adding/updating patient: $e');
    }
  }

  
  static Future<String?> uploadCaseSheet(XFile file) async {
    try {
      
      String downloadUrl = "uploaded_file_url"; 
      return downloadUrl;
    } catch (e) {
      print("File upload error: $e");
      return null;
    }
  }

  
  static Future<void> addTreatmentHistory(String opNo, String date, String details) async {
    try {
      await database.child('patient_details').child(opNo).child('TREATMENT_HISTORY').update({
        date: details,
      });
    } catch (e) {
      print('Error updating treatment history: $e');
    }
  }

  
  static Future<List<UserModel>> getUsers() async {
  try {
    DatabaseEvent event = await database.child('users').once();
    DataSnapshot snapshot = event.snapshot;

    if (snapshot.value is Map) {
      Map<String, dynamic> data = Map<String, dynamic>.from(snapshot.value as Map);

      return data.entries.map((entry) {
        Map<String, dynamic> userData = Map<String, dynamic>.from(entry.value);

        
        return UserModel(
          name: userData['name'] ?? '',
          email: userData['email'] ?? '',
          role: userData['role'] ?? 'staff', // Default role if missing
          admin: (userData['admin'] is bool) ? userData['admin'] : false, // Ensure boolean
        );
      }).toList();
    }
  } catch (e) {
    print('Error fetching users: $e');
  }
  return [];
}

  
  static Future<bool> updateUser(String email, UserModel updatedUser) async {
    try {
      String key = email.replaceAll('.', '_');
      await database.child('users').child(key).update(updatedUser.toMap());
      print("User updated: ${updatedUser.toMap()}");
      return true;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  
  static Future<bool> deleteUser(String email) async {
    try {
      String key = email.replaceAll('.', '_');
      await database.child('users').child(key).remove();
      print("User deleted: $email");
      return true;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  Future<void> addLab(LabModel lab) async {
  DatabaseReference ref = database.child("lab_details").push();
  await ref.set({
    "labId": ref.key,
    "labName": lab.labName,
    "phone": lab.phone ?? "",
    "location": lab.location ?? "",
    "workTypes": lab.workTypes, 
  });
}

  
  Future<void> updateLab(LabModel lab) async {
  await database.child("lab_details").child(lab.labId!).update({
    "labName": lab.labName,
    "phone": lab.phone ?? "",
    "location": lab.location ?? "",
    "workTypes": lab.workTypes, 
  });
}

  Future<void> deleteLab(String labId) async {
    await database.child("lab_details/$labId").remove();
  }

  
   Future<List<LabModel>> getLabs() async {
    DataSnapshot snapshot = await database.child("lab_details").get();
    if (snapshot.exists) {
      Map<dynamic, dynamic> labsMap = snapshot.value as Map<dynamic, dynamic>;
      return labsMap.entries.map((e) => LabModel.fromMap(Map<String, dynamic>.from(e.value))).toList();
    }
    return [];
  }
}
