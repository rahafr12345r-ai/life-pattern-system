import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'config/app_theme.dart';
import 'navigation/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const LifePatternApp());
}

class LifePatternApp extends StatelessWidget {
  const LifePatternApp({super.key});

  @override
  Widget build(BuildContext context) {
  return MaterialApp(
      title: 'Life Pattern',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const AuthGate(),
    );
  }
}
