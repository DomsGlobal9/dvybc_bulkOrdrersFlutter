// Updated ProductDetailController.dart with proper filtering
import 'package:get/get.dart';
import 'dart:async';
import '../../Services/FirebaseServices.dart';
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

  StreamSubscription<List<WomenProduct>>? _productSubscription;
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

    print('🔍 Loading products for category: "$category", gender: "$gender"');

    activeFilters.value = activeFilters.value.copyWith(category: gender);

    _productSubscription?.cancel();

    try {
      // If category is a specific product type, filter by that
      if (category.isNotEmpty && category != 'all' && category != 'ethnic_wear') {
        _productSubscription = FirebaseProductService.getProductsByType(category).listen(
              (products) {
            print('✅ Found ${products.length} products for category "$category"');
            if (products.isNotEmpty) {
              allProducts.value = products;
              productVariations.value = products;
              _applyFiltersToProducts();
              isLoading.value = false;
            } else {
              print('⚠️ No products found for category "$category", loading all products');
              _loadAllProducts();
            }
          },
          onError: (e) {
            error.value = 'Failed to load product variations: $e';
            isLoading.value = false;
            print('❌ Error loading products for category "$category": $e');
            _loadAllProducts();
          },
        );
      } else {
        // Load all products and filter by main category
        _loadAllProducts();
      }
    } catch (e) {
      error.value = 'Failed to load product variations: $e';
      isLoading.value = false;
      print('❌ Exception in loadProductVariations: $e');
      _loadAllProducts();
    }
  }

  void _loadAllProducts() {
    _productSubscription?.cancel();
    _productSubscription = FirebaseProductService.getAllProducts().listen(
          (products) {
        print('✅ Loaded ${products.length} total products from Firebase');
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
        print('❌ Error loading all products: $e');
      },
    );
  }

  // Filter methods for each category
  List<WomenProduct> _filterEthnicWearProducts(List<WomenProduct> products) {
    final ethnicTypes = ['saree', 'salwar', 'lehenga', 'anarkali', 'dupatta', 'ethnic_jacket', 'kurta'];
    return products.where((product) =>
        ethnicTypes.any((type) =>
        product.category.toLowerCase().contains(type) ||
            product.subcategory.toLowerCase().contains(type)
        )
    ).toList();
  }

  List<WomenProduct> _filterTopWearProducts(List<WomenProduct> products) {
    final topTypes = ['tshirt', 'top', 'shirt', 'kurta', 'tunic', 'tank_top', 'blouse'];
    return products.where((product) =>
        topTypes.any((type) =>
        product.category.toLowerCase().contains(type) ||
            product.subcategory.toLowerCase().contains(type)
        )
    ).toList();
  }

  List<WomenProduct> _filterBottomWearProducts(List<WomenProduct> products) {
    final bottomTypes = ['jeans', 'trouser', 'pants', 'skirt', 'shorts', 'leggings', 'palazzo'];
    return products.where((product) =>
        bottomTypes.any((type) =>
        product.category.toLowerCase().contains(type) ||
            product.subcategory.toLowerCase().contains(type)
        )
    ).toList();
  }

  List<WomenProduct> _filterJumpsuitProducts(List<WomenProduct> products) {
    final jumpsuitTypes = ['kaftan', 'maxi_dress', 'bodycon', 'aline_dress', 'jumpsuit', 'romper', 'dress'];
    return products.where((product) =>
        jumpsuitTypes.any((type) =>
        product.category.toLowerCase().contains(type) ||
            product.subcategory.toLowerCase().contains(type)
        )
    ).toList();
  }

  List<WomenProduct> _filterSleepWearProducts(List<WomenProduct> products) {
    final sleepTypes = ['night_suit', 'nightie', 'pyjama', 'loungewear', 'robe', 'sleep'];
    return products.where((product) =>
        sleepTypes.any((type) =>
        product.category.toLowerCase().contains(type) ||
            product.subcategory.toLowerCase().contains(type)
        )
    ).toList();
  }

  List<WomenProduct> _filterActiveWearProducts(List<WomenProduct> products) {
    final activeTypes = ['sports_bra', 'track_pants', 'workout_tshirt', 'yoga_pants', 'joggers', 'active', 'sport'];
    return products.where((product) =>
        activeTypes.any((type) =>
        product.category.toLowerCase().contains(type) ||
            product.subcategory.toLowerCase().contains(type)
        )
    ).toList();
  }

  List<WomenProduct> _filterWinterWearProducts(List<WomenProduct> products) {
    final winterTypes = ['sweater', 'cardigan', 'coat', 'jacket', 'poncho', 'shawl', 'winter'];
    return products.where((product) =>
        winterTypes.any((type) =>
        product.category.toLowerCase().contains(type) ||
            product.subcategory.toLowerCase().contains(type)
        )
    ).toList();
  }

  List<WomenProduct> _filterMaternityProducts(List<WomenProduct> products) {
    final maternityTypes = ['maternity_dress', 'feeding_top', 'maternity_leggings', 'maternity'];
    return products.where((product) =>
        maternityTypes.any((type) =>
        product.category.toLowerCase().contains(type) ||
            product.subcategory.toLowerCase().contains(type)
        )
    ).toList();
  }

  List<WomenProduct> _filterInnerWearProducts(List<WomenProduct> products) {
    final innerTypes = ['bra', 'panties', 'slip', 'shapewear', 'camisole', 'inner'];
    return products.where((product) =>
        innerTypes.any((type) =>
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
          product.category.toLowerCase().contains(searchQuery.value.toLowerCase())
      ).toList();
    }

    final filters = activeFilters.value;

    if (filters.selectedColors.isNotEmpty) {
      products = products.where((product) {
        return filters.selectedColors.any((color) =>
        product.name.toLowerCase().contains(color.toLowerCase()) ||
            product.description.toLowerCase().contains(color.toLowerCase())
        );
      }).toList();
    }

    if (filters.minPrice > 0 || filters.maxPrice < 10000) {
      products = products.where((product) {
        double mockPrice = (product.id.hashCode % 5000).toDouble() + 500;
        return mockPrice >= filters.minPrice && mockPrice <= filters.maxPrice;
      }).toList();
    }

    if (filters.selectedStyles.isNotEmpty) {
      products = products.where((product) {
        return filters.selectedStyles.any((style) =>
        product.category.toLowerCase().contains(style.toLowerCase()) ||
            product.name.toLowerCase().contains(style.toLowerCase())
        );
      }).toList();
    }

    if (filters.selectedFabrics.isNotEmpty) {
      products = products.where((product) {
        return filters.selectedFabrics.any((fabric) =>
        product.description.toLowerCase().contains(fabric.toLowerCase()) ||
            product.name.toLowerCase().contains(fabric.toLowerCase())
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