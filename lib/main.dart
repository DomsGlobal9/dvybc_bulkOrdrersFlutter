import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

import 'data/Splash Screen/SplashScreen.dart';
import 'data/routes/routes.dart';


void main() async {
  // Ensure Flutter is initialized

  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Initialize Firebase
    await Firebase.initializeApp();
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'DVYB',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Set initial route to splash screen
      initialRoute: '/splash',
      getPages: [
        // Add splash route
        GetPage(
          name: '/splash',
          page: () => SplashScreen(),
          transition: Transition.fade,
        ),
        // Add all your existing routes
        ...AppRoutes.routes,
      ],
    );
  }
}