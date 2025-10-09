import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import '../Cart/Address/CheckoutAddressView.dart';
import '../Cart/payment/CheckoutPaymentView.dart';
import '../Cart/Checkout/CheckoutReviewView.dart';
import '../Favorites/FavoritesView.dart';
import '../views/Filters/FilterController.dart';
import '../Splash Screen/SplashScreen.dart';
import '../TryOn/VirtualTryOnScreen.dart';
import '../views/Filters/FilterView.dart';
import '../views/Offers/BoysJacketsView.dart';
import '../views/Offers/InfantsView.dart';
import '../views/Offers/dressesView.dart';
import '../views/Offers/jacketsView.dart';
import '../views/Offers/kurtasView.dart';
import '../views/Offers/lehengaView.dart';
import '../views/Offers/sherwanisView.dart';
import '../views/Offers/OffersView.dart';
import '../views/Profile/MyOrders/MyOrderController.dart';
import '../views/Profile/MyOrders/MyOrderView.dart';
import '../views/Profile/ProfileView.dart';
import '../views/auth/forgotPasswordView.dart';
import '../views/auth/loginView.dart';
import '../views/auth/register.dart';
import '../views/categories/WomenWear/SingleProductDeatilView.dart';
import '../views/categories/WomenWear/WProductDetailView.dart';
import '../views/categories/WomenWear/WomenSubcategoryView.dart';
import '../views/categories/WomenWear/womencat.dart';
import '../views/categories/kidscat.dart' hide InfantsView;
import '../views/categories/womenScreen.dart' hide EthnicWearView;
import '../views/tabview/tabviews.dart';
import '../Cart/Cart/CartController.dart';
import '../Cart/Cart/CartView.dart';

// RouteManager is now in main.dart - no need to duplicate it here

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

  // Virtual Try-On route
  static const virtualTryOn = '/virtual-tryon';

  // Checkout routes
  static const checkoutReview = '/checkout-review';
  static const checkoutAddress = '/checkout-address';
  static const checkoutPayment = '/checkout-payment';

  //Filters
  static const filter = '/filter';

  // My Order ROUTE
  static const myOrders = '/my-orders';

  static final routes = [
    // Splash route
    GetPage(
      name: splash,
      page: () => SplashScreen(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(milliseconds: 300),
      binding: BindingsBuilder(() {
        _clearAllControllers();
      }),
    ),

    // Authentication routes
    GetPage(
      name: login,
      page: () => LoginScreen(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(milliseconds: 300),
      binding: BindingsBuilder(() {
        _clearAuthControllers();
      }),
    ),
    GetPage(
      name: forgotPassword,
      page: () => ForgotPasswordScreen(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 300),
      binding: BindingsBuilder(() {
        _clearAuthControllers();
      }),
    ),
    GetPage(
      name: register,
      page: () => RegisterScreen(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 300),
      binding: BindingsBuilder(() {
        _clearAuthControllers();
      }),
    ),

    // Main app routes
    GetPage(
      name: home,
      page: () => CustomTabView(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 300),
      binding: BindingsBuilder(() {
        _clearAuthControllers();
        _initializeAppControllers();
      }),
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

    // Women's subcategory route
    GetPage(
      name: '/women-subcategory',
      page: () => WomenSubcategoryView(
        mainCategory: Get.arguments?['category'] ?? 'Ethnic wear',
        onBackPressed: null,
      ),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 300),
    ),

    // Women's individual category routes
    GetPage(
      name: ethnicWear,
      page: () => const EthnicWearView(),
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

    // Virtual Try-On route
    GetPage(
      name: virtualTryOn,
      page: () => const VirtualTryOnView(),
      transition: Transition.cupertino,
      transitionDuration: Duration(milliseconds: 300),
    ),

    // Shopping routes
    GetPage(
      name: cart,
      page: () => CartView(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 300),
      binding: BindingsBuilder(() {
        Get.lazyPut<CartController>(() => CartController(), fenix: true);
      }),
    ),
    GetPage(
      name: favorites,
      page: () => FavoritesView(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 300),
    ),

    // Checkout routes
    GetPage(
      name: checkoutReview,
      page: () => CheckoutReviewView(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 300),
      binding: BindingsBuilder(() {
        Get.lazyPut<CartController>(() => CartController(), fenix: true);
      }),
    ),
    GetPage(
      name: checkoutAddress,
      page: () => CheckoutAddressView(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: checkoutPayment,
      page: () => CheckoutPaymentView(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 300),
      binding: BindingsBuilder(() {
        Get.lazyPut<CartController>(() => CartController(), fenix: true);
      }),
    ),
    GetPage(
      name: myOrders,
      page: () => MyOrderView(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 300),
      binding: BindingsBuilder(() {
        Get.lazyPut<MyOrderController>(() => MyOrderController(), fenix: true);
      }),
    ),

    // Filters
    GetPage(
      name: '/filter',
      page: () => const FilterView(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 300),
      binding: BindingsBuilder(() {
        Get.lazyPut<FilterController>(() => FilterController());
      }),
    ),
  ];

  // Helper methods for controller management
  static void _clearAllControllers() {
    try {
      if (Get.isRegistered<LoginController>()) {
        Get.delete<LoginController>(force: true);
      }
      if (Get.isRegistered<RegisterController>()) {
        Get.delete<RegisterController>(force: true);
      }
      if (Get.isRegistered<CartController>()) {
        Get.delete<CartController>(force: true);
      }
      if (Get.isRegistered<FilterController>()) {
        Get.delete<FilterController>(force: true);
      }
      print('All controllers cleared successfully');
    } catch (e) {
      print('Error clearing controllers: $e');
    }
  }

  static void _clearAuthControllers() {
    try {
      if (Get.isRegistered<LoginController>()) {
        Get.delete<LoginController>(force: true);
      }
      if (Get.isRegistered<RegisterController>()) {
        Get.delete<RegisterController>(force: true);
      }
      print('Auth controllers cleared successfully');
    } catch (e) {
      print('Error clearing auth controllers: $e');
    }
  }

  static void _initializeAppControllers() {
    try {
      if (!Get.isRegistered<CartController>()) {
        Get.lazyPut<CartController>(() => CartController(), fenix: true);
      }
      print('App controllers initialized successfully');
    } catch (e) {
      print('Error initializing app controllers: $e');
    }
  }

  // Helper method to navigate with complete controller cleanup
  static void navigateToAuth(String routeName) {
    _clearAllControllers();
    Get.offAllNamed(routeName);
  }

  // Helper to navigate and save route
  static Future<void> navigateToWithSave(String routeName) async {
    await RouteManager.saveRoute(routeName);
    Get.toNamed(routeName);
  }

  // Helper method to navigate to main app with proper initialization
  static Future<void> navigateToHome() async {
    _clearAuthControllers();
    _initializeAppControllers();
    await RouteManager.setLoggedIn(true);
    await RouteManager.saveRoute(home);
    Get.offAllNamed(home);
  }

  // NEW: Helper method for login navigation
  static Future<void> navigateAfterLogin() async {
    _clearAuthControllers();
    _initializeAppControllers();
    await RouteManager.setLoggedIn(true);
    await RouteManager.saveRoute(home);
    Get.offAllNamed(home);
  }

  // Helper method for logout - clears everything and goes to login
  static Future<void> logout() async {
    _clearAllControllers();
    await _clearStoredData();
    await RouteManager.clearRouteData();
    Get.offAllNamed(login);
  }

  static Future<void> _clearStoredData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_token');
      await prefs.remove('user_data');
      print('Stored data cleared successfully');
    } catch (e) {
      print('Error clearing stored data: $e');
    }
  }
}