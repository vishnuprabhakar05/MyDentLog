import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:my_dentlog_app/models/settings_model.dart';
import '../models/patient_model.dart';
import '../models/user_model.dart';
import '../models/lab_model.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import 'package:image_picker/image_picker.dart';
import 'google_drive_service.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:my_dentlog_app/models/appointment_model.dart';
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
    // Get the configured Google Drive folder ID from settings
    final settings = await getGoogleDriveLinkFromSettings();
    
    if (settings.googleDriveLink.isEmpty) {
      throw Exception('Google Drive folder not configured in settings');
    }

    // Extract the folder ID from the Google Drive link
    final folderId = _extractFolderIdFromUrl(settings.googleDriveLink);
    
    if (folderId == null) {
      throw Exception('Invalid Google Drive folder URL in settings');
    }

    if (kIsWeb) {
      // For web, pass the XFile directly
      return await GoogleDriveService.uploadFile(file, folderId: folderId);
    } else {
      // For mobile, convert to File
      final File convertedFile = File(file.path);
      return await GoogleDriveService.uploadFile(convertedFile, folderId: folderId);
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error uploading case sheet: $e');
    }
    rethrow;
  }
}

// Helper method to extract folder ID from Google Drive URL
static String? _extractFolderIdFromUrl(String url) {
  try {
    // Handle URL with or without protocol
    String cleanUrl = url.trim();
    if (!cleanUrl.startsWith('http')) {
      cleanUrl = 'https://$cleanUrl';
    }

    final uri = Uri.parse(cleanUrl);
    
    // Handle different Google Drive URL formats
    if (uri.pathSegments.contains('folders')) {
      // Example: https://drive.google.com/drive/folders/1cMBWeY2ZoiMUzmAfSNsL0eRK6peE3-sd?usp=drive_link
      return uri.pathSegments.last;
    }
    
    // If it's just the ID (last resort)
    final idMatch = RegExp(r'[-\w]{25,}').firstMatch(url);
    if (idMatch != null) {
      return idMatch.group(0);
    }
    
    return null;
  } catch (e) {
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
            role: userData['role'] ?? 'staff',
            admin: (userData['admin'] is bool) ? userData['admin'] : false,
            phone: userData['phone'] ?? '',
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

  // Fetch Google Drive link from Firebase
  static Future<SettingsModel> getGoogleDriveLinkFromSettings() async {
    DataSnapshot snapshot = await database.child("settings").get();
    if (snapshot.exists) {
      return SettingsModel.fromMap(snapshot.value as Map<dynamic, dynamic>);
    }
    return SettingsModel(googleDriveLink: "");
  }

  // Update settings in Firebase
  static Future<void> updateSettings(SettingsModel settings) async {
    await database.child("settings").update(settings.toMap());
  }  
  


  //APPOINTMENTS
  // Add these methods to your existing FirebaseService class

static Future<void> addOrUpdateAppointment(AppointmentModel appointment) async {
  try {
    if (appointment.appointId.isEmpty) {
      // New appointment
      DatabaseReference ref = database.child('appointments').push();
      await ref.set(appointment.toMap()..['appointId'] = ref.key);
    } else {
      // Existing appointment
      await database.child('appointments').child(appointment.appointId).update(appointment.toMap());
    }
  } catch (e) {
    print('Error adding/updating appointment: $e');
    rethrow;
  }
}

static Future<void> deleteAppointment(String appointId) async {
  try {
    await database.child('appointments').child(appointId).remove();
  } catch (e) {
    print('Error deleting appointment: $e');
    rethrow;
  }
}

static Future<List<AppointmentModel>> getAppointments() async {
  try {
    DatabaseEvent event = await database.child('appointments').once();
    DataSnapshot snapshot = event.snapshot;

    if (snapshot.value is Map) {
      Map<String, dynamic> data = Map<String, dynamic>.from(snapshot.value as Map);
      
      return data.entries.map((entry) {
        try {
          Map<String, dynamic> appointmentData = Map<String, dynamic>.from(entry.value);
          appointmentData['appointId'] = entry.key;
          return AppointmentModel.fromMap(appointmentData);
        } catch (e) {
          print("Error parsing appointment data: $e");
          return null;
        }
      }).whereType<AppointmentModel>().toList();
    }
  } catch (e) {
    print('Error fetching appointments: $e');
  }
  return [];
}

static Stream<List<AppointmentModel>> getAppointmentsStream() {
  return database.child('appointments').onValue.map((event) {
    if (event.snapshot.value is Map) {
      Map<String, dynamic> data = Map<String, dynamic>.from(event.snapshot.value as Map);
      
      return data.entries.map((entry) {
        try {
          Map<String, dynamic> appointmentData = Map<String, dynamic>.from(entry.value);
          appointmentData['appointId'] = entry.key;
          return AppointmentModel.fromMap(appointmentData);
        } catch (e) {
          print("Error parsing appointment data: $e");
          return null;
        }
      }).whereType<AppointmentModel>().toList();
    }
    return [];
  });
}

static Future<void> toggleAppointmentStatus(String appointId, bool completed) async {
  try {
    await database.child('appointments').child(appointId).update({
      'completed': completed
    });
  } catch (e) {
    print('Error toggling appointment status: $e');
    rethrow;
  }
}

static Future<List<UserModel>> filterDoctorsForAppointments() async {
  final users = await getUsers();
  return users.where((user) => user.role.toLowerCase() == 'doctor').toList();
}

}