import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/patient_provider.dart';
import 'providers/user_provider.dart';

import 'screens/login_screen.dart';
import 'screens/search_screen.dart';

import 'firebase_options.dart';

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

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => PatientProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MyDentLog',
        theme: ThemeData(
          useMaterial3: true, 
          colorSchemeSeed: Colors.teal, // Generates dynamic color scheme
          brightness: Brightness.light, // Light mode (change to dark if needed)
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.teal,
          brightness: Brightness.dark, // Dark mode support
        ),
        themeMode: ThemeMode.system, // Auto-switch based on system settings
        initialRoute: '/',
        routes: {
          '/': (context) => LoginScreen(),
          '/search': (context) => SearchScreen(),
        },
      ),
    );
  }
}
