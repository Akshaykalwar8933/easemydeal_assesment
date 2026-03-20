import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'core/di/injection.dart';
import 'firebase_options.dart';
import 'presentation/screens/reels_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase is already connected - just initialize
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register all dependencies
  AppInjection.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Reels App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: ReelsScreen(),
    );
  }
}
