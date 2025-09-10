import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../model/Women/WomenModel.dart';

// Base Controller that fetches real Firebase data
abstract class BaseDynamicController extends GetxController {
  final RxList<WomenProduct> WomenProducts = <WomenProduct>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  late StreamSubscription<QuerySnapshot>? _productSubscription;

  // Override this in each controller to specify the filter criteria
  String get productTypeFilter;
  String get gender => 'Women';

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  void loadProducts() {
    isLoading.value = true;
    error.value = '';
    WomenProducts.clear();

    try {
      Query query = FirebaseFirestore.instance
          .collection('products')
          .where('gender', isEqualTo: gender);

      // Add productType filter if specified
      if (productTypeFilter.isNotEmpty) {
        query = query.where('productType', isEqualTo: productTypeFilter);
      }

      _productSubscription = query
          .limit(50)
          .snapshots()
          .listen(
            (QuerySnapshot snapshot) {
          List<WomenProduct> products = [];

          for (QueryDocumentSnapshot doc in snapshot.docs) {
            try {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

              // Extract image URLs
              List<String> imageUrls = [];
              if (data['imageUrls'] is List) {
                imageUrls = List<String>.from(data['imageUrls']);
              }

              WomenProduct product = WomenProduct(
                id: doc.id,
                name: data['productName'] ?? 'Unknown Product',
                image: imageUrls.isNotEmpty ? imageUrls.first : '',
                category: data['productType'] ?? 'unknown',
                description: _generateDescription(data['productName'], data['productType']),
                gender: data['gender'] ?? 'Women',
                subcategory: data['productType'] ?? 'unknown',
                imageUrls: imageUrls,
                productId: data['productId'],
                productSize: data['productSize'],
                totalImages: data['totalImages'] ?? imageUrls.length,
                userId: data['userId'],
                userName: data['userName'],
                isActive: data['isActive'] ?? true,
                createdAt: data['createdAt'],
              );

              products.add(product);
            } catch (e) {
              print('Error processing document ${doc.id}: $e');
            }
          }

          WomenProducts.value = products;
          isLoading.value = false;
        },
        onError: (e) {
          error.value = 'Failed to load products: $e';
          isLoading.value = false;
          print('Firebase error: $e');
        },
      );
    } catch (e) {
      error.value = 'Exception: $e';
      isLoading.value = false;
      print('Exception in loadProducts: $e');
    }
  }

  String _generateDescription(String? productName, String? productType) {
    if (productName == null || productType == null) {
      return 'Beautiful fashion item';
    }
    return 'Stylish $productName from our $productType collection. Perfect for any occasion.';
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

// Ethnic Wear Controller - Gets products with productType = "kurta" from your Firebase
class EthnicWearController extends BaseDynamicController {
  @override
  String get productTypeFilter => 'kurta'; // This matches your Firebase data
}

// Top Wear Controller - Gets products with productType = "top wear"
class TopWearController extends BaseDynamicController {
  @override
  String get productTypeFilter => 'top wear';
}

// Bottom Wear Controller - Gets products with productType = "bottom wear"
class BottomWearController extends BaseDynamicController {
  @override
  String get productTypeFilter => 'bottom wear';
}

// Jumpsuits Controller - Gets products with productType = "jumpsuit"
class JumpsuitsController extends BaseDynamicController {
  @override
  String get productTypeFilter => 'jumpsuit';
}

// Maternity Controller - Gets products with productType = "maternity"
class MaternityController extends BaseDynamicController {
  @override
  String get productTypeFilter => 'maternity';
}

// Sleep Wear Controller - Gets products with productType = "sleepwear"
class SleepWearController extends BaseDynamicController {
  @override
  String get productTypeFilter => 'sleepwear';
}

// Winter Wear Controller - Gets products with productType = "winterwear"
class WinterWearController extends BaseDynamicController {
  @override
  String get productTypeFilter => 'winterwear';
}

// Active Wear Controller - Gets products with productType = "activewear"
class ActiveWearController extends BaseDynamicController {
  @override
  String get productTypeFilter => 'activewear';
}

// Inner Wear Controller - Gets products with productType = "innerwear"
class InnerWearController extends BaseDynamicController {
  @override
  String get productTypeFilter => 'innerwear';
}

// All Products Controller - Gets ALL products regardless of type
class AllWomenProductsController extends BaseDynamicController {
  @override
  String get productTypeFilter => ''; // Empty means no filter, get all products
}