import 'package:get/get.dart';
import 'package:my_dentlog_app/models/user_model.dart';
import 'package:my_dentlog_app/services/firebase_service.dart';

class UserController extends GetxController {
  var users = <UserModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers(); 
  }

  
  Future<void> fetchUsers() async {
    isLoading(true);
    try {
      List<UserModel> userList = await FirebaseService.getUsers();
      
      users.clear();      
      users.addAll(userList); 

      print("Users loaded successfully");
    } catch (e) {
      print("Error fetching users: $e");
      Get.snackbar("Error", "Failed to load users.");
    } finally {
      isLoading(false);
    }
  }

  
  Future<bool> createUser(String name, String email, bool isAdmin, String role) async {
    try {
      UserModel newUser = UserModel(
        name: name,
        email: email,
        admin: isAdmin,
        role: role,
      );

      await FirebaseService.database
          .child("users")
          .child(email.replaceAll(".", "_")) 
          .set(newUser.toMap());

      users.add(newUser); 

      print("User successfully created: ${newUser.toMap()}");
      Get.snackbar("Success", "User created successfully!");
      return true;
    } catch (e) {
      print("Error creating user: $e");
      Get.snackbar("Error", "Failed to create user.");
      return false;
    }
  }

  
  Future<void> deleteUser(String email) async {
    try {
      await FirebaseService.database
          .child("users")
          .child(email.replaceAll(".", "_")) 
          .remove();

      users.removeWhere((user) => user.email == email); 

      print("User deleted: $email");
      Get.snackbar("Success", "User deleted successfully!");
    } catch (e) {
      print("Error deleting user: $e");
      Get.snackbar("Error", "Failed to delete user.");
    }
  }
}
