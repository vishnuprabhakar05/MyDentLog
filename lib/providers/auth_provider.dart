import 'package:flutter/material.dart';
import 'package:my_dentlog_app/services/firebase_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  Future<bool> login(String emailOrStaffId) async {
  try {
    print('🔐 Attempting login for: $emailOrStaffId'); 

    UserModel? user = await FirebaseService.getUserByEmail(emailOrStaffId);

    if (user == null) {
      print('User not found or unauthorized.');
      return false;
    }

    print('User authenticated: ${user.toMap()}'); 

    _currentUser = user;
    notifyListeners();
    return true;
  } catch (e) {
    print('Login error: $e');
    return false;
  }
}

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}