import 'package:flutter/material.dart';
import 'package:homy/entry.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:homy/get_di.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp();
  Map<String, Map<String, String>> languages = await di.init();
  runApp(App(languages: languages));
}

