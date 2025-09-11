import 'package:get/get.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../../Cart/CartController.dart';
import '../../Favorites/FavoritesController.dart';
import '../../Services/FirebaseServices.dart';
import '../../model/Women/WomenModel.dart';


// Fixed SingleProductController
class SingleProductController extends GetxController {
  final Rx<WomenProduct?> currentProduct = Rx<WomenProduct?>(null);
  final RxString selectedSize = 'M'.obs;
  final Rx<Color> selectedColor = Colors.red.obs;
  final RxBool isFavorite = false.obs;
  final RxInt quantity = 1.obs;
  final RxList<WomenProduct> similarProducts = <WomenProduct>[].obs;
  final RxBool isLoadingSimilar = false.obs;
  final RxString error = ''.obs;

  late StreamSubscription<List<WomenProduct>>? _similarProductsSubscription;

  // Get controller instances with lazy initialization
  FavoritesController get _favoritesController =>
      Get.put(FavoritesController());

  CartController get _cartController => Get.put(CartController());

  // Available options
  final List<String> availableSizes = ['XS', 'S', 'M', 'L', 'XL', '2XL'];
  final List<Color> availableColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.pink,
  ];

  void initializeProduct(WomenProduct product) {
    currentProduct.value = product;
    // Check if product is already in favorites
    isFavorite.value = _favoritesController.isWomenProductFavorited(product);
    loadSimilarProducts(product);
  }

  void loadSimilarProducts(WomenProduct product) {
    isLoadingSimilar.value = true;
    error.value = '';

    // Cancel previous subscription if exists
    _similarProductsSubscription?.cancel();

    try {
      // Get similar products of the same type
      _similarProductsSubscription = FirebaseProductService.getProductsByType(product.category).listen(
            (products) {
          // Filter out the current product and limit to 8 similar products
          List<WomenProduct> filteredProducts = products
              .where((p) => p.id != product.id)
              .take(8)
              .toList();

          similarProducts.value = filteredProducts;
          isLoadingSimilar.value = false;
        },
        onError: (e) {
          error.value = 'Failed to load similar products: $e';
          isLoadingSimilar.value = false;
          print('Error loading similar products: $e');

          // Fallback to static similar products if Firebase fails
          _generateFallbackSimilarProducts(product);
        },
      );
    } catch (e) {
      error.value = 'Failed to load similar products: $e';
      isLoadingSimilar.value = false;
      print('Error in loadSimilarProducts: $e');

      // Fallback to static similar products
      _generateFallbackSimilarProducts(product);
    }
  }

  void _generateFallbackSimilarProducts(WomenProduct product) {
    // Create some fallback similar products
    List<WomenProduct> similar = [
      WomenProduct(
        id: 'fallback_1',
        name: 'Similar ${product.category}',
        image: '',
        category: product.category,
        description: 'Similar product in ${product.category} category',
        gender: product.gender,
        subcategory: product.subcategory,
      ),
      WomenProduct(
        id: 'fallback_2',
        name: 'Related ${product.category}',
        image: '',
        category: product.category,
        description: 'Related product in ${product.category} category',
        gender: product.gender,
        subcategory: product.subcategory,
      ),
    ];

    similarProducts.value = similar;
    isLoadingSimilar.value = false;
  }

  void selectColor(Color color) {
    selectedColor.value = color;
  }

  void selectSize(String size) {
    selectedSize.value = size;
  }

  void toggleFavorite() {
    if (currentProduct.value != null) {
      // Toggle in favorites controller
      _favoritesController.toggleWomenProductFavorite(
        currentProduct.value!,
        getRandomPrice(),
      );

      // Update local state
      isFavorite.value =
          _favoritesController.isWomenProductFavorited(currentProduct.value!);
    }
  }

  void incrementQuantity() {
    quantity.value++;
  }

  void decrementQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  void addToCart() {
    if (currentProduct.value != null) {
      // Add to cart with selected options
      _cartController.addWomenProductToCart(
        currentProduct.value!,
        getRandomPrice(),
        selectedSize.value,
        selectedColor.value,
      );

      Get.snackbar(
        'Added to Cart',
        '${currentProduct.value!.name} has been added to your cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Color(0xFF10B981),
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    }
  }

  void buyNow() {
    // Validate selection for non-saree items
    if (!currentProduct.value!.name.toLowerCase().contains('saree') &&
        selectedSize.value.isEmpty) {
      Get.snackbar(
        'Size Required',
        'Please select a size before proceeding',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Add to cart first
    if (currentProduct.value != null) {
      _cartController.addWomenProductToCart(
        currentProduct.value!,
        getRandomPrice(),
        selectedSize.value,
        selectedColor.value,
      );
    }

    Get.snackbar(
      'Proceeding to Checkout',
      'Taking you to checkout for ${currentProduct.value?.name}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Color(0xFF3B82F6),
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );

    // Navigate to cart/checkout
    Future.delayed(Duration(seconds: 1), () {
      Get.toNamed('/cart');
    });
  }

  void retrySimilarProducts() {
    if (currentProduct.value != null) {
      loadSimilarProducts(currentProduct.value!);
    }
  }

  String getRandomPrice() {
    // Generate random price based on product type
    List<int> prices = [
      299, 399, 499, 599, 699, 799, 899, 999,
      1199, 1299, 1499, 1699, 1899, 2099, 2299
    ];
    return prices[currentProduct.value!.id.hashCode.abs() % prices.length]
        .toString();
  }

  String getRandomOriginalPrice() {
    int currentPrice = int.parse(getRandomPrice());
    int originalPrice = (currentPrice * 1.4).round(); // 40% markup
    return originalPrice.toString();
  }

  String getDiscount() {
    int currentPrice = int.parse(getRandomPrice());
    int originalPrice = int.parse(getRandomOriginalPrice());
    int discount = (((originalPrice - currentPrice) / originalPrice) * 100)
        .round();
    return discount.toString();
  }

  @override
  void onClose() {
    _similarProductsSubscription?.cancel();
    super.onClose();
  }
}

// Fixed ProductDetailController
class ProductDetailController extends GetxController {
  final RxList<WomenProduct> productVariations = <WomenProduct>[].obs;
  final RxList<WomenProduct> filteredProducts = <WomenProduct>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString error = ''.obs;

  late StreamSubscription<List<WomenProduct>>? _productSubscription;
  String _currentGender = 'Women';
  String _currentCategory = '';
  String _currentProductName = '';

  @override
  void onInit() {
    super.onInit();
  }

  void loadProductVariations(String productName, String category, {String gender = 'Women'}) {
    isLoading.value = true;
    error.value = '';
    _currentGender = gender;
    _currentCategory = category;
    _currentProductName = productName;

    // Cancel previous subscription if exists
    _productSubscription?.cancel();

    try {
      // First try to get products by type (category)
      _productSubscription = FirebaseProductService.getProductsByType(category).listen(
            (products) {
          if (products.isNotEmpty) {
            productVariations.value = products;
            filteredProducts.value = products;
            isLoading.value = false;
          } else {
            // If no products of this type, get all products
            _loadAllProducts();
          }
        },
        onError: (e) {
          error.value = 'Failed to load product variations: $e';
          isLoading.value = false;
          print('Error loading product variations: $e');
          // Fallback to all products
          _loadAllProducts();
        },
      );
    } catch (e) {
      error.value = 'Failed to load product variations: $e';
      isLoading.value = false;
      print('Error in loadProductVariations: $e');
      _loadAllProducts();
    }
  }

  void _loadAllProducts() {
    _productSubscription?.cancel();
    _productSubscription = FirebaseProductService.getAllProducts().listen(
          (products) {
        productVariations.value = products;
        filteredProducts.value = products;
        isLoading.value = false;
      },
      onError: (e) {
        error.value = 'Failed to load products: $e';
        isLoading.value = false;
        print('Error loading all products: $e');
      },
    );
  }

  void searchProducts(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredProducts.value = productVariations;
    } else {
      filteredProducts.value = productVariations
          .where((product) =>
      product.name.toLowerCase().contains(query.toLowerCase()) ||
          product.description.toLowerCase().contains(query.toLowerCase()) ||
          product.category.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  void retryLoading() {
    if (_currentProductName.isNotEmpty && _currentCategory.isNotEmpty) {
      loadProductVariations(_currentProductName, _currentCategory, gender: _currentGender);
    } else {
      _loadAllProducts();
    }
  }

  void loadProductsForGender(String productName, String category, String gender) {
    loadProductVariations(productName, category, gender: gender);
  }

  void loadProductsByType(String productType, {String gender = 'Women'}) {
    isLoading.value = true;
    error.value = '';
    _currentGender = gender;
    _currentCategory = productType;

    _productSubscription?.cancel();
    _productSubscription = FirebaseProductService.getProductsByType(productType).listen(
          (products) {
        productVariations.value = products;
        filteredProducts.value = products;
        isLoading.value = false;
      },
      onError: (e) {
        error.value = 'Failed to load products by type: $e';
        isLoading.value = false;
        print('Error loading products by type: $e');
      },
    );
  }

  @override
  void onClose() {
    _productSubscription?.cancel();
    super.onClose();
  }
}

// Fixed WomenViewModel Controllers
abstract class BaseCategoryController extends GetxController {
  final RxList<WomenProduct> WomenProducts = <WomenProduct>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  late StreamSubscription<List<WomenProduct>>? _productSubscription;

  String get categoryName;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  void loadProducts() {
    isLoading.value = true;
    error.value = '';

    // Cancel previous subscription if exists
    _productSubscription?.cancel();

    try {
      if (categoryName.isEmpty) {
        // Load all products if no specific category
        _productSubscription = FirebaseProductService.getAllProducts().listen(
              (products) {
            WomenProducts.value = products;
            isLoading.value = false;
          },
          onError: (e) {
            error.value = 'Failed to load products: $e';
            isLoading.value = false;
            print('Error loading products: $e');
          },
        );
      } else {
        // Load products by specific type
        _productSubscription = FirebaseProductService.getProductsByType(categoryName).listen(
              (products) {
            WomenProducts.value = products;
            isLoading.value = false;
          },
          onError: (e) {
            error.value = 'Failed to load $categoryName products: $e';
            isLoading.value = false;
            print('Error loading $categoryName products: $e');
          },
        );
      }
    } catch (e) {
      error.value = 'Failed to load $categoryName products: $e';
      isLoading.value = false;
      print('Error in load$categoryName: $e');
    }
  }

  void retryLoading() {
    loadProducts();
  }

  @override
  void onClose() {
    _productSubscription?.cancel();
    super.onClose();
  }
}

// Updated Category Controllers
class EthnicWearController extends BaseCategoryController {
  @override
  String get categoryName => 'kurta'; // Based on your Firebase data
}

class TopWearController extends BaseCategoryController {
  @override
  String get categoryName => 'top wear';
}

class BottomWearController extends BaseCategoryController {
  @override
  String get categoryName => 'bottom wear';
}

class JumpsuitsController extends BaseCategoryController {
  @override
  String get categoryName => 'jumpsuit';
}

class MaternityController extends BaseCategoryController {
  @override
  String get categoryName => 'maternity';
}

class SleepWearController extends BaseCategoryController {
  @override
  String get categoryName => 'sleepwear';
}

class WinterWearController extends BaseCategoryController {
  @override
  String get categoryName => 'winterwear';
}

class ActiveWearController extends BaseCategoryController {
  @override
  String get categoryName => 'activewear';
}

class InnerWearController extends BaseCategoryController {
  @override
  String get categoryName => 'innerwear';
}

// Universal Women Products Controller (for all categories)
class WomenProductsController extends BaseCategoryController {
  @override
  String get categoryName => ''; // Empty means get all products
}