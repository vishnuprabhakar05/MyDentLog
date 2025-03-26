import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

import 'controllers/auth_controller.dart';
import 'controllers/patient_controller.dart';
import 'controllers/user_controller.dart';

import 'screens/login_screen.dart';
import 'screens/search_screen.dart';
import 'screens/user_creation_screen.dart';

import 'firebase_options.dart';
import 'config/lab_config.dart';
import 'config/theme_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully");
  } catch (e) {
    print("Firebase initialization error: $e");
  }

  // Initialize GetX Controllers
  Get.put(AuthController());
  Get.put(PatientController());
  Get.put(UserController());

  await LabConfig.loadLabWorkTypes();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyDentLog',
      theme: AppThemes.lightTheme, 
      darkTheme: AppThemes.darkTheme, 
      themeMode: ThemeMode.system, 
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => LoginScreen()),
        GetPage(name: '/search', page: () => SearchScreen()),
        GetPage(name: '/admin', page: () => UserManagementScreen()),
      ],
    );
  }
}
