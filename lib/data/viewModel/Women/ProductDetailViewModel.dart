// Updated ProductDetailController.dart with filter integration
import 'package:get/get.dart';
import 'dart:async';
import '../../Services/FirebaseServices.dart';
import '../../model/Women/WomenModel.dart';
import '../../model/FilterModel.dart';

class ProductDetailController extends GetxController {
  final RxList<WomenProduct> productVariations = <WomenProduct>[].obs;
  final RxList<WomenProduct> filteredProducts = <WomenProduct>[].obs;
  final RxList<WomenProduct> allProducts = <WomenProduct>[].obs; // Store all products for filtering
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
    // Listen to filter changes and apply them in real-time
    ever(activeFilters, (_) => _applyFiltersToProducts());
  }

  void loadProductVariations(String productName, String category, {String gender = 'Women'}) {
    isLoading.value = true;
    error.value = '';
    _currentGender = gender;
    _currentCategory = category;
    _currentProductName = productName;

    // Set filter category
    activeFilters.value = activeFilters.value.copyWith(category: gender);

    _productSubscription?.cancel();

    try {
      _productSubscription = FirebaseProductService.getProductsByType(category).listen(
            (products) {
          if (products.isNotEmpty) {
            allProducts.value = products;
            productVariations.value = products;
            _applyFiltersToProducts();
            isLoading.value = false;
          } else {
            _loadAllProducts();
          }
        },
        onError: (e) {
          error.value = 'Failed to load product variations: $e';
          isLoading.value = false;
          print('Error loading product variations: $e');
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
        allProducts.value = products;
        productVariations.value = products;
        _applyFiltersToProducts();
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
    _applyFiltersToProducts();
  }

  // Open filter modal
  Future<void> openFilterModal() async {
    final result = await Get.toNamed('/filter', arguments: {
      'category': _currentGender,
    });

    if (result != null && result is FilterModel) {
      activeFilters.value = result;
      _updateActiveFilterCount();
    }
  }

  // Apply filters to products in real-time
  void _applyFiltersToProducts() {
    List<WomenProduct> products = List.from(allProducts);

    // Apply search filter first
    if (searchQuery.value.isNotEmpty) {
      products = products.where((product) =>
      product.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          product.description.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          product.category.toLowerCase().contains(searchQuery.value.toLowerCase())
      ).toList();
    }

    // Apply active filters
    final filters = activeFilters.value;

    // Color filter
    if (filters.selectedColors.isNotEmpty) {
      products = products.where((product) {
        // Assuming product has a color field or you can derive it from name/description
        return filters.selectedColors.any((color) =>
        product.name.toLowerCase().contains(color.toLowerCase()) ||
            product.description.toLowerCase().contains(color.toLowerCase())
        );
      }).toList();
    }

    // Price filter
    if (filters.minPrice > 0 || filters.maxPrice < 10000) {
      products = products.where((product) {
        // Assuming product has a price field
        // Since WomenModel doesn't seem to have price, you might need to add it
        // For now, using a mock price based on product id
        double mockPrice = (product.id.hashCode % 5000).toDouble() + 500;
        return mockPrice >= filters.minPrice && mockPrice <= filters.maxPrice;
      }).toList();
    }

    // Style filter
    if (filters.selectedStyles.isNotEmpty) {
      products = products.where((product) {
        return filters.selectedStyles.any((style) =>
        product.category.toLowerCase().contains(style.toLowerCase()) ||
            product.name.toLowerCase().contains(style.toLowerCase())
        );
      }).toList();
    }

    // Fabric filter
    if (filters.selectedFabrics.isNotEmpty) {
      products = products.where((product) {
        return filters.selectedFabrics.any((fabric) =>
        product.description.toLowerCase().contains(fabric.toLowerCase()) ||
            product.name.toLowerCase().contains(fabric.toLowerCase())
        );
      }).toList();
    }

    // Rating filter (mock implementation)
    if (filters.selectedRatings.isNotEmpty) {
      products = products.where((product) {
        // Mock rating based on product id
        int mockRating = (product.id.hashCode % 5) + 1;
        return filters.selectedRatings.any((rating) => mockRating >= rating);
      }).toList();
    }

    // Delivery time filter (mock implementation)
    if (filters.selectedDeliveryTimes.isNotEmpty) {
      // For demo purposes, all products match delivery time filters
      // In real implementation, you'd check product delivery options
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
    isLoading.value = true;
    error.value = '';
    _currentGender = gender;
    _currentCategory = productType;

    // Update filter category
    activeFilters.value = activeFilters.value.copyWith(category: gender);

    _productSubscription?.cancel();
    _productSubscription = FirebaseProductService.getProductsByType(productType).listen(
          (products) {
        allProducts.value = products;
        productVariations.value = products;
        _applyFiltersToProducts();
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