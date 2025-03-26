import 'package:get/get.dart';
import 'package:my_dentlog_app/models/user_model.dart';
import 'package:my_dentlog_app/services/firebase_service.dart';

class AuthController extends GetxController {
  var currentUser = Rxn<UserModel>(); 
  var isLoading = false.obs;

  
  Future<bool> login(String emailOrStaffId) async {
  isLoading.value = true;
  try {
    var user = await FirebaseService.getUserByEmail(emailOrStaffId);
    isLoading.value = false;

    if (user != null) {
      currentUser.value = user;  
      return true;  
    } else {
      return false; 
    }
  } catch (e) {
    isLoading.value = false;
    return false; 
  }
}

  
  Future<bool> verifyAdmin(String email) async {
    try {
      isLoading.value = true;
      print('Checking if $email is an admin...');

      UserModel? user = await FirebaseService.getUserByEmail(email);

      if (user != null && user.admin) {
        print('Admin verified: ${user.email}');
        return true;
      } else {
        print('Admin verification failed for: $email');
        return false;
      }
    } catch (e) {
      print('Error verifying admin: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  
  void logout() {
    currentUser.value = null;
    Get.offAllNamed('/');
  }
}
