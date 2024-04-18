import 'package:my_app/firebase_options.dart';
import 'package:my_app/log/forgotpassword.dart';
import 'package:my_app/log/login.dart';
import 'package:my_app/log/signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        home: SafeArea(child: Scaffold(body: LogIn())),
        debugShowCheckedModeBanner: false);
  }
}
