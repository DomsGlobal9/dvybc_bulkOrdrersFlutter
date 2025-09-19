import 'package:flutter/material.dart';
import 'package:flutter_dvybc/data/views/Profile/ProfileView.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

import 'data/Splash Screen/SplashScreen.dart';
import 'data/routes/routes.dart';
import 'data/views/auth/forgotPasswordView.dart';


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
  Get.put(AuthViewModel());
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

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: 'DVYB',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       // Set initial route to splash screen
//       initialRoute: '/profile',
//       getPages: [
//         // Add splash route
//         GetPage(
//           name: '/profile',
//           page: () => ProfileView(),
//           transition: Transition.fade,
//         ),
//         // Add all your existing routes
//         ...AppRoutes.routes,
//       ],
//     );
//   }
// }