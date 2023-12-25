import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:black_death/black_death.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MaterialApp(
      title: 'Black Death',
      home: BlackDeath(),
    ),
  );
}
