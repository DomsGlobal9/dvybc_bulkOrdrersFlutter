import 'package:get/get.dart';
import 'dart:async';
import '../../Services/FirebaseServices.dart';
import '../../model/Women/WomenModel.dart';

// Base controller for women's clothing categories
abstract class BaseWomenController extends GetxController {
  final RxList<WomenProduct> WomenProducts = <WomenProduct>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // FIXED: Changed from 'late' to nullable with proper initialization
  StreamSubscription<List<WomenProduct>>? _productSubscription;

  String get subcategory;

  @override
  void onInit() {
    super.onInit();
    loadWomenProducts();
  }

  void loadWomenProducts() {
    isLoading.value = true;
    error.value = '';

    try {
      // Cancel previous subscription if exists - NOW SAFE
      _productSubscription?.cancel();

      if (subcategory.isEmpty || subcategory == 'all') {
        // Load all products if no specific subcategory
        _productSubscription = FirebaseProductService.getAllProducts().listen(
              (products) {
            WomenProducts.value = products;
            isLoading.value = false;
            print('Loaded ${products.length} products for all categories');
          },
          onError: (e) {
            error.value = 'Failed to load products: $e';
            isLoading.value = false;
            print('Error loading all products: $e');
          },
        );
      } else {
        // Load products by specific type
        _productSubscription = FirebaseProductService.getProductsByType(subcategory).listen(
              (products) {
            WomenProducts.value = products;
            isLoading.value = false;
            print('Loaded ${products.length} products for $subcategory');
          },
          onError: (e) {
            error.value = 'Failed to load $subcategory products: $e';
            isLoading.value = false;
            print('Error loading $subcategory products: $e');
          },
        );
      }
    } catch (e) {
      error.value = 'Failed to load products: $e';
      isLoading.value = false;
      print('Error in loadWomenProducts: $e');
    }
  }

  void retryLoading() {
    loadWomenProducts();
  }

  @override
  void onClose() {
    // FIXED: Safe to cancel now since it's nullable
    _productSubscription?.cancel();
    super.onClose();
  }
}

// Ethnic Wear Controller - Maps to 'kurta' in your Firebase
class EthnicWearController extends BaseWomenController {
  @override
  String get subcategory => ''; // This matches your Firebase productType
}

// Top Wear Controller
class TopWearController extends BaseWomenController {
  @override
  String get subcategory => 'top wear';
}

// Bottom Wear Controller
class BottomWearController extends BaseWomenController {
  @override
  String get subcategory => 'bottom wear';
}

// Jumpsuits Controller
class JumpsuitsController extends BaseWomenController {
  @override
  String get subcategory => 'jumpsuit';
}

// Maternity Controller
class MaternityController extends BaseWomenController {
  @override
  String get subcategory => 'maternity';
}

// Sleep Wear Controller
class SleepWearController extends BaseWomenController {
  @override
  String get subcategory => 'sleepwear';
}

// Winter Wear Controller
class WinterWearController extends BaseWomenController {
  @override
  String get subcategory => 'winterwear';
}

// Active Wear Controller
class ActiveWearController extends BaseWomenController {
  @override
  String get subcategory => 'activewear';
}

// Inner Wear Controller
class InnerWearController extends BaseWomenController {
  @override
  String get subcategory => 'innerwear';
}

// All Products Controller
class AllWomenProductsController extends BaseWomenController {
  @override
  String get subcategory => ''; // Empty string means get all products
}