import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';

class UserProvider extends ChangeNotifier {
  List<UserModel> _users = [];
  List<UserModel> get users => _users;

  Future<void> fetchUsers() async {
    _users = await FirebaseService.getUsers();
    notifyListeners();
  }
}