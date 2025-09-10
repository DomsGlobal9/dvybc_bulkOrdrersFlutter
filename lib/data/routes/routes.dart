import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Controllers/FavoritesController.dart';
import '../Controllers/FavoritesView.dart';
import '../Controllers/FilterController.dart';
import '../views/Filters/FilterView.dart';
import '../views/Offers/BoysJacketsView.dart';
import '../views/Offers/InfantsView.dart';
import '../views/Offers/dressesView.dart';
import '../views/Offers/jacketsView.dart';
import '../views/Offers/kurtasView.dart';
import '../views/Offers/lehengaView.dart';
import '../views/Offers/sherwanisView.dart';
import '../views/Offers/OffersView.dart';
import '../views/Profile/ProfileView.dart';
import '../views/auth/forgotPasswordView.dart';
import '../views/auth/loginView.dart';
import '../views/auth/register.dart';
import '../views/categories/WomenWear/SingleProductDeatilView.dart';
import '../views/categories/WomenWear/WProductDetailView.dart';
import '../views/categories/WomenWear/womencat.dart';
import '../views/categories/kidscat.dart' hide InfantsView;
import '../views/tabview/tabviews.dart';
import '../Controllers/CartController.dart';
import '../Controllers/CartView.dart';

// Splash Screen class
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    await Future.delayed(Duration(seconds: 2));

    try {
      final prefs = await SharedPreferences.getInstance();
      bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      if (isLoggedIn) {
        Get.offAllNamed('/home');
      } else {
        Get.offAllNamed('/login');
      }
    } catch (e) {
      print('Error checking login status: $e');
      Get.offAllNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'DVYB',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E5A96),
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(
              color: Color(0xFF1E5A96),
            ),
          ],
        ),
      ),
    );
  }
}

class AppRoutes {
  // Route constants
  static const splash = '/splash';
  static const login = '/login';
  static const forgotPassword = '/forgot-password';
  static const register = '/register';
  static const home = '/home';
  static const category = '/category';
  static const profile = '/profile';
  static const offers = '/offers';
  static const categories = '/categories';
  static const lehengas = '/lehengas';
  static const dresses = '/dresses';
  static const kurtas = '/kurtas';
  static const jackets = '/jackets';
  static const sherwanis = '/sherwanis';
  static const infants = '/infants';
  static const boysJackets = '/boys_jackets';

  // Kids category routes
  static const boys = '/boys';
  static const girls = '/girls';
  static const infantsCategory = '/infants-category';

  // Women's category routes
  static const ethnicWear = '/ethnic-wear';
  static const topWear = '/top-wear';
  static const bottomWear = '/bottom-wear';
  static const jumpsuits = '/jumpsuits';
  static const maternity = '/maternity';
  static const sleepWear = '/sleep-wear';
  static const winterWear = '/winter-wear';
  static const activeWear = '/active-wear';
  static const innerWear = '/inner-wear';
  static const favorites = '/favorites';

  // Product detail routes
  static const productDetail = '/product-detail';
  static const productSingle = '/product-single';
  static const cart = '/cart';

  //Filters
  static const filter = '/filter';

  static final routes = [
    // Splash route
    GetPage(
      name: splash,
      page: () => SplashScreen(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(milliseconds: 300),
    ),

    // Authentication routes
    GetPage(
      name: login,
      page: () => LoginScreen(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(milliseconds: 300),
      binding: BindingsBuilder(() {
        // Clear any existing controllers to prevent conflicts
        Get.delete<LoginController>(force: true);
      }),
    ),
    GetPage(
      name: forgotPassword,
      page: () => ForgotPasswordScreen(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: register,
      page: () => RegisterScreen(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 300),
      binding: BindingsBuilder(() {
        // Clear any existing controllers to prevent conflicts
        Get.delete<RegisterController>(force: true);
      }),
    ),

    // Main app routes
    GetPage(
      name: home,
      page: () => CustomTabView(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 300),
    ),

    // Offer routes
    GetPage(
      name: lehengas,
      page: () => const LehengasView(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: dresses,
      page: () => const DressesView(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: kurtas,
      page: () => const KurtasView(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: jackets,
      page: () => const JacketsView(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: sherwanis,
      page: () => const SherwanisView(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: infants,
      page: () => const InfantsView(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: boysJackets,
      page: () => const BoysJacketsView(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 300),
    ),

    // Profile and main sections
    GetPage(
      name: profile,
      page: () => ProfileView(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: offers,
      page: () => Offersview(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: categories,
      page: () => CustomTabView(initialTab: 2),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 300),
    ),

    // Kids category routes
    GetPage(
      name: boys,
      page: () => const BoysView(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: girls,
      page: () => const GirlsView(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: infantsCategory,
      page: () => const InfantsView(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 300),
    ),

    // Women's category routes
    GetPage(
      name: ethnicWear,
      page: () => const EthnicWearView(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: topWear,
      page: () => const TopWearView(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: bottomWear,
      page: () => const BottomWearView(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: jumpsuits,
      page: () => const JumpsuitsView(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: maternity,
      page: () => const MaternityView(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: sleepWear,
      page: () => const SleepWearView(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: winterWear,
      page: () => const WinterWearView(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: activeWear,
      page: () => const ActiveWearView(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: innerWear,
      page: () => const InnerWearView(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 300),
    ),

    // Product detail routes
    GetPage(
      name: productDetail,
      page: () => const ProductDetailView(),
      transition: Transition.topLevel,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: productSingle,
      page: () => const SingleProductView(),
      transition: Transition.cupertino,
      transitionDuration: Duration(milliseconds: 300),
    ),

    // Shopping routes
    GetPage(
      name: cart,
      page: () => CartView(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: favorites,
      page: () => FavoritesView(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 300),
    ),
    //Filters
    GetPage(
      name: filter,
      page: () => FilterView(
        category: Get.arguments['category'] ?? 'Women',
      ),
      transition: Transition.downToUp,
      transitionDuration: Duration(milliseconds: 300),
      binding: BindingsBuilder(() {
        Get.lazyPut<FilterController>(() => FilterController());
      }),
    ),
  ];

  // Helper method to navigate with controller cleanup
  static void navigateToAuth(String routeName) {
    // Clean up existing auth controllers
    Get.delete<LoginController>(force: true);
    Get.delete<RegisterController>(force: true);

    // Navigate to the route
    Get.offAllNamed(routeName);
  }

  // Helper method to navigate to main app
  static void navigateToHome() {
    // Clean up auth controllers
    Get.delete<LoginController>(force: true);
    Get.delete<RegisterController>(force: true);

    // Navigate to home
    Get.offAllNamed(home);
  }
}

// Add this to your main.dart file's imports
//import 'package:shared_preferences/shared_preferences.dart';