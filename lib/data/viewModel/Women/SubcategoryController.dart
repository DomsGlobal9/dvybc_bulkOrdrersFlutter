import 'package:get/get.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/Women/WomenModel.dart';

class SubcategoryController extends GetxController {
  final RxList<WomenProduct> products = <WomenProduct>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  StreamSubscription<QuerySnapshot>? _productSubscription;
  String currentSubcategory = '';
  String currentSubcategoryName = '';

  // Helper methods for UI state
  bool get hasProducts => products.isNotEmpty;
  bool get isEmpty => !isLoading.value && products.isEmpty && error.value.isEmpty;

  void loadProductsBySubcategory(String subcategoryType, String subcategoryName) {
    currentSubcategory = subcategoryType;
    currentSubcategoryName = subcategoryName;
    isLoading.value = true;
    error.value = '';
    products.clear();

    print('🔍 Loading products for subcategory: "$subcategoryType" ($subcategoryName)');

    try {
      _productSubscription?.cancel();

      // Use collectionGroup to query all products from all users
      Query query = FirebaseFirestore.instance.collectionGroup('products');

      // Add filters based on your Firebase structure
      if (subcategoryType.isNotEmpty && subcategoryType != 'all') {
        // Filter by dressType or category based on your Firebase document structure
        query = query.where('dressType', isEqualTo: subcategoryType);
      }

      _productSubscription = query
          .limit(50)
          .snapshots()
          .listen(
            (QuerySnapshot snapshot) {
          print('📊 Collection group query returned ${snapshot.docs.length} documents');

          List<WomenProduct> productList = [];

          for (QueryDocumentSnapshot doc in snapshot.docs) {
            try {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

              // Extract userId from document reference path
              // Path format: users/{userId}/products/{productId}
              String userId = doc.reference.parent.parent!.id;

              print('Processing product ${doc.id} from user $userId');

              // Extract image URLs with multiple fallbacks
              List<String> imageUrls = [];
              if (data['imageUrls'] is List) {
                imageUrls = List<String>.from(data['imageUrls']);
              } else if (data['imageURLs'] is List) {
                imageUrls = List<String>.from(data['imageURLs']);
              } else if (data['images'] is List) {
                imageUrls = List<String>.from(data['images']);
              }

              // Extract selected colors
              List<String> selectedColors = [];
              if (data['selectedColors'] is List) {
                selectedColors = List<String>.from(data['selectedColors']);
              }

              // Extract selected sizes
              List<String> selectedSizes = [];
              if (data['selectedSizes'] is List) {
                selectedSizes = List<String>.from(data['selectedSizes']);
              }

              // Handle price conversion
              int? price;
              if (data['price'] != null) {
                if (data['price'] is String) {
                  price = int.tryParse(data['price']);
                } else if (data['price'] is int) {
                  price = data['price'];
                } else if (data['price'] is double) {
                  price = (data['price'] as double).toInt();
                }
              }

              // Generate product name (prioritize title, fallback to name, then dressType)
              String productName = data['title']?.toString() ??
                  data['name']?.toString() ??
                  data['dressType']?.toString() ??
                  'Fashion Item';

              WomenProduct product = WomenProduct(
                id: doc.id,
                name: productName,
                image: imageUrls.isNotEmpty ? imageUrls.first : '',
                category: data['category']?.toString() ?? 'WOMEN',
                description: data['description']?.toString() ?? _generateDescription(productName, data['dressType']?.toString()),
                gender: data['category']?.toString() ?? 'WOMEN',
                subcategory: data['dressType']?.toString() ?? 'fashion',
                imageUrls: imageUrls,
                productId: doc.id,
                productSize: selectedSizes.isNotEmpty ? selectedSizes.first : null,
                totalImages: imageUrls.length,
                userId: userId, // Store the user ID who created this product
                userName: data['userName']?.toString(),
                isActive: data['isActive'] ?? true,
                price: price,
                design: data['craft']?.toString(), // Map craft to design
                dressType: data['dressType']?.toString(),
                material: data['fabric']?.toString(), // Map fabric to material
                selectedColors: selectedColors,
                selectedSizes: selectedSizes,
                createdAt: data['createdAt'],
                timestamp: data['timestamp'],
                units: data['units'],
              );

              productList.add(product);
            } catch (e) {
              print('❌ Error processing document ${doc.id}: $e');
            }
          }

          print('✅ Found ${productList.length} products for "$subcategoryType"');
          products.value = productList;
          isLoading.value = false;

          if (productList.isEmpty) {
            print('⚠️ No products found for subcategory "$subcategoryType"');
            print('💡 Make sure Firebase has products with dressType = "$subcategoryType"');
          } else {
            productList.take(2).forEach((p) =>
                print('Sample: ${p.name} - User: ${p.userId} - Type: "${p.category}" - DressType: "${p.dressType}"'));
          }
        },
        onError: (e) {
          error.value = 'Failed to load $subcategoryName products: $e';
          isLoading.value = false;
          products.clear();
          print('❌ Error loading $subcategoryType products: $e');
        },
      );
    } catch (e) {
      error.value = 'Failed to load products: $e';
      isLoading.value = false;
      products.clear();
      print('❌ Exception in loadProductsBySubcategory: $e');
    }
  }

  // Load all products from all users (no filtering)
  void loadAllProducts() {
    currentSubcategory = 'all';
    currentSubcategoryName = 'All Products';
    isLoading.value = true;
    error.value = '';
    products.clear();

    print('🔍 Loading all products from all users...');

    try {
      _productSubscription?.cancel();

      _productSubscription = FirebaseFirestore.instance
          .collectionGroup('products')
          .limit(100)
          .snapshots()
          .listen(
            (QuerySnapshot snapshot) {
          print('📊 Found ${snapshot.docs.length} total products');

          List<WomenProduct> productList = [];

          for (QueryDocumentSnapshot doc in snapshot.docs) {
            try {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              String userId = doc.reference.parent.parent!.id;

              // Use the same mapping logic as above
              WomenProduct? product = _mapDocumentToProduct(doc, data, userId);
              if (product != null) {
                productList.add(product);
              }
            } catch (e) {
              print('❌ Error processing document ${doc.id}: $e');
            }
          }

          // Sort by timestamp (newest first)
          productList.sort((a, b) {
            if (a.timestamp != null && b.timestamp != null) {
              if (a.timestamp is Timestamp && b.timestamp is Timestamp) {
                return (b.timestamp as Timestamp).compareTo(a.timestamp as Timestamp);
              }
            }
            return 0;
          });

          products.value = productList;
          isLoading.value = false;
        },
        onError: (e) {
          error.value = 'Failed to load all products: $e';
          isLoading.value = false;
          products.clear();
          print('❌ Error loading all products: $e');
        },
      );
    } catch (e) {
      error.value = 'Failed to load all products: $e';
      isLoading.value = false;
      products.clear();
      print('❌ Exception in loadAllProducts: $e');
    }
  }

  // Load products by category (WOMEN, MEN, etc.)
  void loadProductsByCategory(String category) {
    currentSubcategory = category;
    currentSubcategoryName = category;
    isLoading.value = true;
    error.value = '';
    products.clear();

    print('🔍 Loading products for category: "$category"');

    try {
      _productSubscription?.cancel();

      _productSubscription = FirebaseFirestore.instance
          .collectionGroup('products')
          .where('category', isEqualTo: category)
          .limit(50)
          .snapshots()
          .listen(
            (QuerySnapshot snapshot) {
          List<WomenProduct> productList = [];

          for (QueryDocumentSnapshot doc in snapshot.docs) {
            try {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              String userId = doc.reference.parent.parent!.id;

              WomenProduct? product = _mapDocumentToProduct(doc, data, userId);
              if (product != null) {
                productList.add(product);
              }
            } catch (e) {
              print('❌ Error processing document ${doc.id}: $e');
            }
          }

          products.value = productList;
          isLoading.value = false;
        },
        onError: (e) {
          error.value = 'Failed to load $category products: $e';
          isLoading.value = false;
          products.clear();
        },
      );
    } catch (e) {
      error.value = 'Failed to load products: $e';
      isLoading.value = false;
      products.clear();
    }
  }

  // Helper method to map document to WomenProduct
  WomenProduct? _mapDocumentToProduct(QueryDocumentSnapshot doc, Map<String, dynamic> data, String userId) {
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
        description: data['description']?.toString() ?? _generateDescription(productName, data['dressType']?.toString()),
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

  String _generateDescription(String? productName, String? dressType) {
    if (productName == null) {
      return 'Beautiful fashion item for women';
    }

    String description = 'Stylish $productName';
    if (dressType != null && dressType.isNotEmpty) {
      description += ' in $dressType style';
    }
    description += '. Perfect for modern women who value both comfort and style.';

    return description;
  }

  void retryLoading() {
    print('🔄 Retrying to load products for "$currentSubcategory"');
    if (currentSubcategory.isNotEmpty) {
      if (currentSubcategory == 'all') {
        loadAllProducts();
      } else {
        loadProductsBySubcategory(currentSubcategory, currentSubcategoryName);
      }
    }
  }

  @override
  void onClose() {
    _productSubscription?.cancel();
    super.onClose();
  }
}