import 'package:get/get.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Cart/CartController.dart';
import '../../Favorites/FavoritesController.dart';
import '../../model/Women/WomenModel.dart';

// Updated SingleProductController for nested Firebase structure
class SingleProductController extends GetxController {
  final Rx<WomenProduct?> currentProduct = Rx<WomenProduct?>(null);
  final RxString selectedSize = 'M'.obs;
  final Rx<Color> selectedColor = Colors.red.obs;
  final RxBool isFavorite = false.obs;
  final RxInt quantity = 1.obs;
  final RxList<WomenProduct> similarProducts = <WomenProduct>[].obs;
  final RxBool isLoadingSimilar = false.obs;
  final RxString error = ''.obs;

  StreamSubscription<QuerySnapshot>? _similarProductsSubscription;

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
      print('🔍 Loading similar products for: ${product.name}');

      // Query similar products using collectionGroup from all users
      Query query = FirebaseFirestore.instance.collectionGroup('products');

      // Filter by same dressType but exclude current product
      if (product.dressType != null && product.dressType!.isNotEmpty) {
        query = query.where('dressType', isEqualTo: product.dressType);
      }

      _similarProductsSubscription = query
          .limit(20) // Get more to filter out current product
          .snapshots()
          .listen(
            (QuerySnapshot snapshot) {
          print('📦 Found ${snapshot.docs.length} potential similar products');

          List<WomenProduct> similarList = [];

          for (QueryDocumentSnapshot doc in snapshot.docs) {
            try {
              // Skip the current product
              if (doc.id == product.id) continue;

              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              String userId = doc.reference.parent.parent!.id;

              WomenProduct? similarProduct = _mapDocumentToWomenProduct(doc, data, userId);
              if (similarProduct != null) {
                similarList.add(similarProduct);
              }
            } catch (e) {
              print('❌ Error processing similar product ${doc.id}: $e');
            }
          }

          // Limit to 8 similar products
          similarProducts.value = similarList.take(8).toList();
          isLoadingSimilar.value = false;

          print('✅ Loaded ${similarProducts.length} similar products');
        },
        onError: (e) {
          error.value = 'Failed to load similar products: $e';
          isLoadingSimilar.value = false;
          print('❌ Error loading similar products: $e');

          // Fallback to static similar products if Firebase fails
          _generateFallbackSimilarProducts(product);
        },
      );
    } catch (e) {
      error.value = 'Failed to load similar products: $e';
      isLoadingSimilar.value = false;
      print('❌ Exception in loadSimilarProducts: $e');

      // Fallback to static similar products
      _generateFallbackSimilarProducts(product);
    }
  }

  // Map Firestore document to WomenProduct
  WomenProduct? _mapDocumentToWomenProduct(QueryDocumentSnapshot doc, Map<String, dynamic> data, String userId) {
    try {
      // Extract image URLs
      List<String> imageUrls = [];
      if (data['imageUrls'] is List) {
        imageUrls = List<String>.from(data['imageUrls']);
      } else if (data['imageURLs'] is List) {
        imageUrls = List<String>.from(data['imageURLs']);
      }

      // Extract colors and sizes
      List<String> selectedColors = [];
      if (data['selectedColors'] is List) {
        selectedColors = List<String>.from(data['selectedColors']);
      }

      List<String> selectedSizes = [];
      if (data['selectedSizes'] is List) {
        selectedSizes = List<String>.from(data['selectedSizes']);
      }

      // Handle price
      int? price;
      if (data['price'] != null) {
        if (data['price'] is String) {
          price = int.tryParse(data['price']);
        } else if (data['price'] is int) {
          price = data['price'];
        }
      }

      String productName = data['title']?.toString() ??
          data['name']?.toString() ??
          data['dressType']?.toString() ??
          'Fashion Item';

      return WomenProduct(
        id: doc.id,
        name: productName,
        image: imageUrls.isNotEmpty ? imageUrls.first : '',
        category: data['category']?.toString() ?? 'WOMEN',
        description: data['description']?.toString() ?? 'Beautiful fashion item',
        gender: data['category']?.toString() ?? 'WOMEN',
        subcategory: data['dressType']?.toString() ?? 'fashion',
        imageUrls: imageUrls,
        productId: doc.id,
        productSize: selectedSizes.isNotEmpty ? selectedSizes.first : null,
        totalImages: imageUrls.length,
        userId: userId,
        userName: data['userName']?.toString(),
        isActive: data['isActive'] ?? true,
        price: price,
        design: data['craft']?.toString(),
        dressType: data['dressType']?.toString(),
        material: data['fabric']?.toString(),
        selectedColors: selectedColors,
        selectedSizes: selectedSizes,
        createdAt: data['createdAt'],
        timestamp: data['timestamp'],
        units: data['units'],
      );
    } catch (e) {
      print('❌ Error mapping document ${doc.id}: $e');
      return null;
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