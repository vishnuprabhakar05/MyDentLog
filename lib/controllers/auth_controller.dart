import 'package:get/get.dart';
import 'package:my_dentlog_app/models/user_model.dart';
import 'package:my_dentlog_app/services/firebase_service.dart';
import 'package:my_dentlog_app/screens/search_screen.dart'; 

class AuthController extends GetxController {
  var currentUser = Rxn<UserModel>(); 
  var isLoading = false.obs;

  Future<void> login(String emailOrStaffId) async {
    try {
      isLoading.value = true; 
      print('🔐 Attempting login for: $emailOrStaffId');

      UserModel? user = await FirebaseService.getUserByEmail(emailOrStaffId);

      if (user == null) {
        print(' User not found or unauthorized.');
        Get.snackbar("Login Failed", "Invalid credentials",
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      print('User authenticated: ${user.toMap()}');
      currentUser.value = user;

     
      Get.offAll(() => SearchScreen());
    } catch (e) {
      print(' Login error: $e');
      Get.snackbar("Error", "Something went wrong. Try again.",
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false; 
    }
  }

  void logout() {
    currentUser.value = null;
    Get.offAllNamed('/'); 
  }
}
