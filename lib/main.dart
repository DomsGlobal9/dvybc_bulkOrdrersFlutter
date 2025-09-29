import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dvybc/data/views/Profile/ProfileView.dart';
import 'package:flutter_dvybc/data/views/home/homeScreen.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/Splash Screen/SplashScreen.dart';
import 'data/routes/routes.dart';
import 'data/views/auth/forgotPasswordView.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  Get.put(AuthViewModel());

  runApp(MyApp());
}

// Route Manager Class
class RouteManager {
  static const String _lastRouteKey = 'last_route';
  static const String _isFirstTimeKey = 'is_first_time';
  static const String _isLoggedInKey = 'is_logged_in';

  // Save current route
  static Future<void> saveRoute(String route) async {
    if (route.isEmpty || route == '/splash') return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastRouteKey, route);
      print('Route saved: $route');
    } catch (e) {
      print('Error saving route: $e');
    }
  }

  // Get initial route on app start
  static Future<String> getInitialRoute() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final isFirstTime = prefs.getBool(_isFirstTimeKey) ?? true;
      if (isFirstTime) {
        await prefs.setBool(_isFirstTimeKey, false);
        return '/splash';
      }

      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      final lastRoute = prefs.getString(_lastRouteKey);

      if (isLoggedIn && lastRoute != null && lastRoute != '/splash') {
        print('Restoring last route: $lastRoute');
        return lastRoute;
      }

      return isLoggedIn ? '/home' : '/login';
    } catch (e) {
      print('Error getting initial route: $e');
      return '/splash';
    }
  }

  // Set login status
  static Future<void> setLoggedIn(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, value);
    } catch (e) {
      print('Error setting login status: $e');
    }
  }

  // Clear all route data
  static Future<void> clearRouteData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastRouteKey);
      await prefs.setBool(_isLoggedInKey, false);
    } catch (e) {
      print('Error clearing route data: $e');
    }
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: RouteManager.getInitialRoute(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        return GetMaterialApp(
          title: 'DVYB',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          initialRoute: snapshot.data!,
          getPages: [
            GetPage(
              name: '/splash',
              page: () => SplashScreen(),
              transition: Transition.fade,
            ),
            ...AppRoutes.routes,
          ],
        );
      },
    );
  }
}