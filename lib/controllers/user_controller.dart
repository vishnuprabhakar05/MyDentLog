import 'package:get/get.dart';
import 'package:my_dentlog_app/models/user_model.dart';
import 'package:my_dentlog_app/services/firebase_service.dart';

class UserController extends GetxController {
  var users = <UserModel>[].obs;

  Future<void> fetchUsers() async {
    users.value = await FirebaseService.getUsers();
  }
}
