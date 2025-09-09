import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'app/app.dart';
import 'providers/ai_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Force logout on app start to require fresh login every time
  await FirebaseAuth.instance.signOut();
  
  // Initialize AI Provider
  try {
    await AIProvider().initialize();
  } catch (e) {
    debugPrint('Warning: AI Provider initialization failed: $e');
  }
  
  runApp(const DeliverySystemApp());
}