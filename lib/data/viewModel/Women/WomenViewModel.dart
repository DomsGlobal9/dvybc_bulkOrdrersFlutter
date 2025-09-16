import 'package:get/get.dart';
import 'dart:async';
import '../../Services/FirebaseServices.dart';
import '../../model/Women/WomenModel.dart';

// Base controller for women's clothing categories
abstract class BaseWomenController extends GetxController {
  final RxList<WomenProduct> WomenProducts = <WomenProduct>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

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
    WomenProducts.clear();

    print('🔍 Loading products for subcategory: "$subcategory"');

    try {
      _productSubscription?.cancel();

      if (subcategory.isEmpty || subcategory == 'all') {
        // Load all products if no specific subcategory
        _productSubscription = FirebaseProductService.getAllProducts().listen(
              (products) {
            print('✅ Loaded ${products.length} products for all categories');
            WomenProducts.value = products;
            isLoading.value = false;

            if (products.isNotEmpty) {
              products.take(3).forEach((p) =>
                  print('Product: ${p.name} - Type: "${p.category}" - Subcategory: "${p.subcategory}"'));
            } else {
              print('⚠️ No products found in Firebase');
            }
          },
          onError: (e) {
            error.value = 'Failed to load products: $e';
            isLoading.value = false;
            WomenProducts.clear();
            print('❌ Error loading all products: $e');
          },
        );
      } else {
        // Load products by specific type
        _productSubscription = FirebaseProductService.getProductsByType(subcategory).listen(
              (products) {
            print('✅ Loaded ${products.length} products for "$subcategory"');
            WomenProducts.value = products;
            isLoading.value = false;

            if (products.isNotEmpty) {
              products.take(3).forEach((p) =>
                  print('Product: ${p.name} - Type: "${p.category}" - Subcategory: "${p.subcategory}"'));
            } else {
              print('⚠️ No products found for subcategory "$subcategory"');
              print('💡 Check if Firebase has products with productType = "$subcategory"');
            }
          },
          onError: (e) {
            error.value = 'Failed to load $subcategory products: $e';
            isLoading.value = false;
            WomenProducts.clear();
            print('❌ Error loading $subcategory products: $e');
          },
        );
      }
    } catch (e) {
      error.value = 'Failed to load products: $e';
      isLoading.value = false;
      WomenProducts.clear();
      print('❌ Exception in loadWomenProducts: $e');
    }
  }

  void retryLoading() {
    print('🔄 Retrying to load products for "$subcategory"');
    loadWomenProducts();
  }

  bool get hasProducts => WomenProducts.isNotEmpty;
  bool get isEmpty => !isLoading.value && WomenProducts.isEmpty && error.value.isEmpty;

  @override
  void onClose() {
    _productSubscription?.cancel();
    super.onClose();
  }
}

// All Products Controller - gets all products without filtering
class AllWomenProductsController extends BaseWomenController {
  @override
  String get subcategory => ''; // Empty string means get all products
}

// Ethnic Wear Controllers
class EthnicWearController extends BaseWomenController {
  @override
  String get subcategory => ''; // Load all ethnic wear products
}

class SareeController extends BaseWomenController {
  @override
  String get subcategory => 'saree';
}

class SalwarController extends BaseWomenController {
  @override
  String get subcategory => 'salwar';
}

class LehengaController extends BaseWomenController {
  @override
  String get subcategory => 'lehenga';
}

class AnarkaliController extends BaseWomenController {
  @override
  String get subcategory => 'anarkali';
}

class DupattaController extends BaseWomenController {
  @override
  String get subcategory => 'dupatta';
}

class EthnicJacketController extends BaseWomenController {
  @override
  String get subcategory => 'ethnic_jacket';
}

class KurtaController extends BaseWomenController {
  @override
  String get subcategory => 'kurta';
}

// Top Wear Controllers
class TopWearController extends BaseWomenController {
  @override
  String get subcategory => 'top_wear'; // Load all top wear
}

class TShirtController extends BaseWomenController {
  @override
  String get subcategory => 'tshirt';
}

class TopController extends BaseWomenController {
  @override
  String get subcategory => 'top';
}

class ShirtController extends BaseWomenController {
  @override
  String get subcategory => 'shirt';
}

class TunicController extends BaseWomenController {
  @override
  String get subcategory => 'tunic';
}

class TankTopController extends BaseWomenController {
  @override
  String get subcategory => 'tank_top';
}

// Bottom Wear Controllers
class BottomWearController extends BaseWomenController {
  @override
  String get subcategory => 'bottom_wear'; // Load all bottom wear
}

class JeansController extends BaseWomenController {
  @override
  String get subcategory => 'jeans';
}

class TrouserController extends BaseWomenController {
  @override
  String get subcategory => 'trouser';
}

class SkirtController extends BaseWomenController {
  @override
  String get subcategory => 'skirt';
}

class ShortsController extends BaseWomenController {
  @override
  String get subcategory => 'shorts';
}

class LeggingsController extends BaseWomenController {
  @override
  String get subcategory => 'leggings';
}

class PalazzoController extends BaseWomenController {
  @override
  String get subcategory => 'palazzo';
}

// Jumpsuits & Dresses Controllers
class JumpsuitsController extends BaseWomenController {
  @override
  String get subcategory => 'jumpsuits'; // Load all jumpsuits/dresses
}

class KaftanController extends BaseWomenController {
  @override
  String get subcategory => 'kaftan';
}

class MaxiDressController extends BaseWomenController {
  @override
  String get subcategory => 'maxi_dress';
}

class BodyconController extends BaseWomenController {
  @override
  String get subcategory => 'bodycon';
}

class ALineDressController extends BaseWomenController {
  @override
  String get subcategory => 'aline_dress';
}

class JumpsuitController extends BaseWomenController {
  @override
  String get subcategory => 'jumpsuit';
}

class RomperController extends BaseWomenController {
  @override
  String get subcategory => 'romper';
}

// Sleep Wear Controllers
class SleepWearController extends BaseWomenController {
  @override
  String get subcategory => 'sleep_wear'; // Load all sleep wear
}

class NightSuitController extends BaseWomenController {
  @override
  String get subcategory => 'night_suit';
}

class NightieController extends BaseWomenController {
  @override
  String get subcategory => 'nightie';
}

class PyjamaController extends BaseWomenController {
  @override
  String get subcategory => 'pyjama';
}

class LoungewearController extends BaseWomenController {
  @override
  String get subcategory => 'loungewear';
}

class RobeController extends BaseWomenController {
  @override
  String get subcategory => 'robe';
}

// Active Wear Controllers
class ActiveWearController extends BaseWomenController {
  @override
  String get subcategory => 'active_wear'; // Load all active wear
}

class SportsBraController extends BaseWomenController {
  @override
  String get subcategory => 'sports_bra';
}

class TrackPantsController extends BaseWomenController {
  @override
  String get subcategory => 'track_pants';
}

class WorkoutTShirtController extends BaseWomenController {
  @override
  String get subcategory => 'workout_tshirt';
}

class YogaPantsController extends BaseWomenController {
  @override
  String get subcategory => 'yoga_pants';
}

class JoggersController extends BaseWomenController {
  @override
  String get subcategory => 'joggers';
}

// Winter Wear Controllers
class WinterWearController extends BaseWomenController {
  @override
  String get subcategory => 'winter_wear'; // Load all winter wear
}

class SweaterController extends BaseWomenController {
  @override
  String get subcategory => 'sweater';
}

class CardiganController extends BaseWomenController {
  @override
  String get subcategory => 'cardigan';
}

class CoatController extends BaseWomenController {
  @override
  String get subcategory => 'coat';
}

class JacketController extends BaseWomenController {
  @override
  String get subcategory => 'jacket';
}

class PonchoController extends BaseWomenController {
  @override
  String get subcategory => 'poncho';
}

class ShawlController extends BaseWomenController {
  @override
  String get subcategory => 'shawl';
}

// Maternity Controllers
class MaternityController extends BaseWomenController {
  @override
  String get subcategory => 'maternity'; // Load all maternity
}

class MaternityDressController extends BaseWomenController {
  @override
  String get subcategory => 'maternity_dress';
}

class FeedingTopController extends BaseWomenController {
  @override
  String get subcategory => 'feeding_top';
}

class MaternityLeggingsController extends BaseWomenController {
  @override
  String get subcategory => 'maternity_leggings';
}

// Inner Wear Controllers
class InnerWearController extends BaseWomenController {
  @override
  String get subcategory => 'inner_wear'; // Load all inner wear
}

class BraController extends BaseWomenController {
  @override
  String get subcategory => 'bra';
}

class PantiesController extends BaseWomenController {
  @override
  String get subcategory => 'panties';
}

class SlipController extends BaseWomenController {
  @override
  String get subcategory => 'slip';
}

class ShapewearController extends BaseWomenController {
  @override
  String get subcategory => 'shapewear';
}