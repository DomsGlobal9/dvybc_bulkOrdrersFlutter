import 'package:get/get.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/Women/WomenModel.dart';
import '../../model/FilterModel.dart';

class ProductDetailController extends GetxController {
  final RxList<WomenProduct> productVariations = <WomenProduct>[].obs;
  final RxList<WomenProduct> filteredProducts = <WomenProduct>[].obs;
  final RxList<WomenProduct> allProducts = <WomenProduct>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString error = ''.obs;
  final Rx<FilterModel> activeFilters = FilterModel().obs;
  final RxInt activeFilterCount = 0.obs;

  StreamSubscription<QuerySnapshot>? _productSubscription;
  String _currentGender = 'Women';
  String _currentCategory = '';
  String _currentProductName = '';

  @override
  void onInit() {
    super.onInit();
    ever(activeFilters, (_) => _applyFiltersToProducts());
  }

  void loadProductVariations(String productName, String category, {String gender = 'Women'}) {
    isLoading.value = true;
    error.value = '';
    _currentGender = gender;
    _currentCategory = category;
    _currentProductName = productName;

    print('Loading products for category: "$category", gender: "$gender"');

    activeFilters.value = activeFilters.value.copyWith(category: gender);

    _productSubscription?.cancel();

    try {
      // Use collectionGroup to query all products from all users
      Query query = FirebaseFirestore.instance.collectionGroup('products');

      // If category is specific, filter by that
      if (category.isNotEmpty && category != 'all' && category != 'ethnic_wear') {
        query = query.where('dressType', isEqualTo: category);
      }

      _productSubscription = query
          .limit(100)
          .snapshots()
          .listen(
            (QuerySnapshot snapshot) {
          print('Found ${snapshot.docs.length} products for category "$category"');

          List<WomenProduct> products = [];

          for (QueryDocumentSnapshot doc in snapshot.docs) {
            try {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              String userId = doc.reference.parent.parent!.id;

              WomenProduct? product = _mapDocumentToWomenProduct(doc, data, userId);
              if (product != null) {
                products.add(product);
              }
            } catch (e) {
              print('Error processing document ${doc.id}: $e');
            }
          }

          if (products.isNotEmpty) {
            allProducts.value = products;
            productVariations.value = products;
            _applyFiltersToProducts();
            isLoading.value = false;
          } else {
            print('No products found for category "$category", loading all products');
            _loadAllProducts();
          }
        },
        onError: (e) {
          error.value = 'Failed to load product variations: $e';
          isLoading.value = false;
          print('Error loading products for category "$category": $e');
          _loadAllProducts();
        },
      );
    } catch (e) {
      error.value = 'Failed to load product variations: $e';
      isLoading.value = false;
      print('Exception in loadProductVariations: $e');
      _loadAllProducts();
    }
  }

  void _loadAllProducts() {
    _productSubscription?.cancel();

    try {
      // Use collectionGroup to get all products from all users
      _productSubscription = FirebaseFirestore.instance
          .collectionGroup('products')
          .limit(200)
          .snapshots()
          .listen(
            (QuerySnapshot snapshot) {
          print('Loaded ${snapshot.docs.length} total products from Firebase');

          List<WomenProduct> products = [];

          for (QueryDocumentSnapshot doc in snapshot.docs) {
            try {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              String userId = doc.reference.parent.parent!.id;

              WomenProduct? product = _mapDocumentToWomenProduct(doc, data, userId);
              if (product != null) {
                products.add(product);
              }
            } catch (e) {
              print('Error processing document ${doc.id}: $e');
            }
          }

          allProducts.value = products;

          // Filter products based on current category if it's a main category
          if (_currentCategory == 'ethnic_wear') {
            productVariations.value = _filterEthnicWearProducts(products);
          } else if (_currentCategory == 'top_wear') {
            productVariations.value = _filterTopWearProducts(products);
          } else if (_currentCategory == 'bottom_wear') {
            productVariations.value = _filterBottomWearProducts(products);
          } else if (_currentCategory == 'jumpsuits') {
            productVariations.value = _filterJumpsuitProducts(products);
          } else if (_currentCategory == 'sleep_wear') {
            productVariations.value = _filterSleepWearProducts(products);
          } else if (_currentCategory == 'active_wear') {
            productVariations.value = _filterActiveWearProducts(products);
          } else if (_currentCategory == 'winter_wear') {
            productVariations.value = _filterWinterWearProducts(products);
          } else if (_currentCategory == 'maternity') {
            productVariations.value = _filterMaternityProducts(products);
          } else if (_currentCategory == 'inner_wear') {
            productVariations.value = _filterInnerWearProducts(products);
          } else {
            productVariations.value = products;
          }

          _applyFiltersToProducts();
          isLoading.value = false;
        },
        onError: (e) {
          error.value = 'Failed to load products: $e';
          isLoading.value = false;
          print('Error loading all products: $e');
        },
      );
    } catch (e) {
      error.value = 'Failed to load products: $e';
      isLoading.value = false;
      print('Exception in _loadAllProducts: $e');
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
      print('Error mapping document ${doc.id}: $e');
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

  // Filter methods for each category
  List<WomenProduct> _filterEthnicWearProducts(List<WomenProduct> products) {
    final ethnicTypes = ['saree', 'salwar', 'lehenga', 'anarkali', 'dupatta', 'ethnic_jacket', 'kurta'];
    return products.where((product) =>
        ethnicTypes.any((type) =>
        product.dressType?.toLowerCase().contains(type) == true ||
            product.category.toLowerCase().contains(type) ||
            product.subcategory.toLowerCase().contains(type)
        )
    ).toList();
  }

  List<WomenProduct> _filterTopWearProducts(List<WomenProduct> products) {
    final topTypes = ['tshirt', 'top', 'shirt', 'kurta', 'tunic', 'tank_top', 'blouse'];
    return products.where((product) =>
        topTypes.any((type) =>
        product.dressType?.toLowerCase().contains(type) == true ||
            product.category.toLowerCase().contains(type) ||
            product.subcategory.toLowerCase().contains(type)
        )
    ).toList();
  }

  List<WomenProduct> _filterBottomWearProducts(List<WomenProduct> products) {
    final bottomTypes = ['jeans', 'trouser', 'pants', 'skirt', 'shorts', 'leggings', 'palazzo'];
    return products.where((product) =>
        bottomTypes.any((type) =>
        product.dressType?.toLowerCase().contains(type) == true ||
            product.category.toLowerCase().contains(type) ||
            product.subcategory.toLowerCase().contains(type)
        )
    ).toList();
  }

  List<WomenProduct> _filterJumpsuitProducts(List<WomenProduct> products) {
    final jumpsuitTypes = ['kaftan', 'maxi_dress', 'bodycon', 'aline_dress', 'jumpsuit', 'romper', 'dress'];
    return products.where((product) =>
        jumpsuitTypes.any((type) =>
        product.dressType?.toLowerCase().contains(type) == true ||
            product.category.toLowerCase().contains(type) ||
            product.subcategory.toLowerCase().contains(type)
        )
    ).toList();
  }

  List<WomenProduct> _filterSleepWearProducts(List<WomenProduct> products) {
    final sleepTypes = ['night_suit', 'nightie', 'pyjama', 'loungewear', 'robe', 'sleep'];
    return products.where((product) =>
        sleepTypes.any((type) =>
        product.dressType?.toLowerCase().contains(type) == true ||
            product.category.toLowerCase().contains(type) ||
            product.subcategory.toLowerCase().contains(type)
        )
    ).toList();
  }

  List<WomenProduct> _filterActiveWearProducts(List<WomenProduct> products) {
    final activeTypes = ['sports_bra', 'track_pants', 'workout_tshirt', 'yoga_pants', 'joggers', 'active', 'sport'];
    return products.where((product) =>
        activeTypes.any((type) =>
        product.dressType?.toLowerCase().contains(type) == true ||
            product.category.toLowerCase().contains(type) ||
            product.subcategory.toLowerCase().contains(type)
        )
    ).toList();
  }

  List<WomenProduct> _filterWinterWearProducts(List<WomenProduct> products) {
    final winterTypes = ['sweater', 'cardigan', 'coat', 'jacket', 'poncho', 'shawl', 'winter'];
    return products.where((product) =>
        winterTypes.any((type) =>
        product.dressType?.toLowerCase().contains(type) == true ||
            product.category.toLowerCase().contains(type) ||
            product.subcategory.toLowerCase().contains(type)
        )
    ).toList();
  }

  List<WomenProduct> _filterMaternityProducts(List<WomenProduct> products) {
    final maternityTypes = ['maternity_dress', 'feeding_top', 'maternity_leggings', 'maternity'];
    return products.where((product) =>
        maternityTypes.any((type) =>
        product.dressType?.toLowerCase().contains(type) == true ||
            product.category.toLowerCase().contains(type) ||
            product.subcategory.toLowerCase().contains(type)
        )
    ).toList();
  }

  List<WomenProduct> _filterInnerWearProducts(List<WomenProduct> products) {
    final innerTypes = ['bra', 'panties', 'slip', 'shapewear', 'camisole', 'inner'];
    return products.where((product) =>
        innerTypes.any((type) =>
        product.dressType?.toLowerCase().contains(type) == true ||
            product.category.toLowerCase().contains(type) ||
            product.subcategory.toLowerCase().contains(type)
        )
    ).toList();
  }

  void searchProducts(String query) {
    searchQuery.value = query;
    _applyFiltersToProducts();
  }

  Future<void> openFilterModal() async {
    final result = await Get.toNamed('/filter', arguments: {
      'category': _currentGender,
    });

    if (result != null && result is FilterModel) {
      activeFilters.value = result;
      _updateActiveFilterCount();
    }
  }

  void _applyFiltersToProducts() {
    List<WomenProduct> products = List.from(productVariations);

    if (searchQuery.value.isNotEmpty) {
      products = products.where((product) =>
      product.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          product.description.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          product.category.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          product.dressType?.toLowerCase().contains(searchQuery.value.toLowerCase()) == true ||
          product.material?.toLowerCase().contains(searchQuery.value.toLowerCase()) == true
      ).toList();
    }

    final filters = activeFilters.value;

    if (filters.selectedColors.isNotEmpty) {
      products = products.where((product) {
        return filters.selectedColors.any((color) =>
        product.name.toLowerCase().contains(color.toLowerCase()) ||
            product.description.toLowerCase().contains(color.toLowerCase()) ||
            product.selectedColors?.any((c) => c.toLowerCase().contains(color.toLowerCase())) == true
        );
      }).toList();
    }

    if (filters.minPrice > 0 || filters.maxPrice < 10000) {
      products = products.where((product) {
        double mockPrice = (product.price ?? (product.id.hashCode % 5000).toDouble() + 500).toDouble();
        return mockPrice >= filters.minPrice && mockPrice <= filters.maxPrice;
      }).toList();
    }

    if (filters.selectedStyles.isNotEmpty) {
      products = products.where((product) {
        return filters.selectedStyles.any((style) =>
        product.category.toLowerCase().contains(style.toLowerCase()) ||
            product.name.toLowerCase().contains(style.toLowerCase()) ||
            product.dressType?.toLowerCase().contains(style.toLowerCase()) == true
        );
      }).toList();
    }

    if (filters.selectedFabrics.isNotEmpty) {
      products = products.where((product) {
        return filters.selectedFabrics.any((fabric) =>
        product.description.toLowerCase().contains(fabric.toLowerCase()) ||
            product.name.toLowerCase().contains(fabric.toLowerCase()) ||
            product.material?.toLowerCase().contains(fabric.toLowerCase()) == true
        );
      }).toList();
    }

    if (filters.selectedRatings.isNotEmpty) {
      products = products.where((product) {
        int mockRating = (product.id.hashCode % 5) + 1;
        return filters.selectedRatings.any((rating) => mockRating >= rating);
      }).toList();
    }

    filteredProducts.value = products;
  }

  void _updateActiveFilterCount() {
    int count = 0;
    final filters = activeFilters.value;

    if (filters.selectedColors.isNotEmpty) count++;
    if (filters.selectedRatings.isNotEmpty) count++;
    if (filters.selectedStyles.isNotEmpty) count++;
    if (filters.selectedFabrics.isNotEmpty) count++;
    if (filters.selectedDeliveryTimes.isNotEmpty) count++;
    if (filters.minPrice > 0 || filters.maxPrice < 10000) count++;

    activeFilterCount.value = count;
  }

  void clearAllFilters() {
    activeFilters.value = FilterModel(category: _currentGender);
    activeFilterCount.value = 0;
    _applyFiltersToProducts();
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
    loadProductVariations('', productType, gender: gender);
  }

  @override
  void onClose() {
    _productSubscription?.cancel();
    super.onClose();
  }
}