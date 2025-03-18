import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'search_screen.dart'; // ✅ Import SearchScreen (DO NOT redefine)
import 'firebase_options.dart';

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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SearchScreen(), // ✅ Use imported SearchScreen
    );
  }
}
