import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';
import 'login_screen.dart';
import 'admin_setup_screen.dart';
import 'admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyDentLog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AuthWrapper(), // ✅ Decides which screen to show
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Future<bool> _isAdminRegistered() async {
    DatabaseEvent event = await _dbRef.child("users").orderByChild("admin").equalTo(true).once();
    return event.snapshot.value != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isAdminRegistered(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData && !snapshot.data!) {
          return AdminSetupScreen(); // ✅ First-time admin setup
        }
        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            if (snapshot.hasData) {
              return AdminDashboard(); // ✅ Admin gets dashboard after login
            }
            return LoginScreen();
          },
        );
      },
    );
  }
}
