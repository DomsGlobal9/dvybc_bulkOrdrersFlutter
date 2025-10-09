// lib/viewModel/Women/ProductDetailViewModel.dart

import 'package:get/get.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/Women/WomenModel.dart';
import '../../model/FilterModel.dart';

class ProductDetailController extends GetxController {
  final RxList<WomenProduct> allProducts = <WomenProduct>[].obs;
  final RxList<WomenProduct> filteredProducts = <WomenProduct>[].obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

  final RxString searchQuery = ''.obs;
  final Rx<FilterModel> activeFilters = FilterModel().obs;
  final RxInt activeFilterCount = 0.obs;
  final RxString selectedSubCategory = ''.obs;
  final RxString currentProductName = ''.obs;

  StreamSubscription<QuerySnapshot>? _productSubscription;

  @override
  void onInit() {
    super.onInit();
    ever(selectedSubCategory, (_) => _applyAllFilters());
    ever(searchQuery, (_) => _applyAllFilters());
    ever(activeFilters, (_) {
      _applyAllFilters();
      _updateActiveFilterCount();
    });
  }

  Future<void> openFilterModal() async {
    try {
      // Pass the current category to the filter view
      final result = await Get.toNamed(
        '/filter',
        arguments: {
          'category': currentProductName.value,
          'filters': activeFilters.value,
        },
      );

      if (result != null && result is FilterModel) {
        activeFilters.value = result;
      }
    } catch (e) {
      print('Error opening filter modal: $e');
      Get.snackbar(
        'Error',
        'Failed to open filters',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void loadProductsForCategory(String productName, String subCategory) {
    isLoading.value = true;
    error.value = '';
    selectedSubCategory.value = subCategory;
    currentProductName.value = productName;
    _productSubscription?.cancel();
    try {
      _productSubscription = FirebaseFirestore.instance
          .collectionGroup('products')
          .limit(500)
          .snapshots()
          .listen(
            (QuerySnapshot snapshot) {
          List<WomenProduct> products = [];
          for (QueryDocumentSnapshot doc in snapshot.docs) {
            try {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              String userId = doc.reference.parent.parent!.id;
              products.add(WomenProduct.fromFirestore(data, doc.id, userId));
            } catch (e) {
              print('Error processing document ${doc.id}: $e');
            }
          }
          allProducts.value = products;
          _applyAllFilters();
          isLoading.value = false;
        },
        onError: (e) {
          error.value = 'Failed to load products: $e';
          isLoading.value = false;
        },
      );
    } catch (e) {
      error.value = 'Failed to load products: $e';
      isLoading.value = false;
    }
  }

  void _applyAllFilters() {
    print("\n--- [START] APPLYING FILTERS ---");
    List<WomenProduct> tempFilteredList = List.from(allProducts);
    print("Total products before filtering: ${tempFilteredList.length}");

    final filters = activeFilters.value;
    print("Active Filters: ${filters.toJson()}");

    // 1. Sub-Category Filter
    if (selectedSubCategory.value.isNotEmpty) {
      final normalizedSelected = selectedSubCategory.value.trim().toLowerCase().replaceAll(RegExp(r's$'), '');
      tempFilteredList = tempFilteredList.where((product) {
        final productType = product.dressType?.trim().toLowerCase().replaceAll(RegExp(r's$'), '') ?? '';
        return productType == normalizedSelected;
      }).toList();
    }
    print("Products after Sub-Category filter: ${tempFilteredList.length}");

    // 2. Dynamic Filters
    if (filters.selectedFabrics.isNotEmpty) {
      tempFilteredList = tempFilteredList.where((product) {
        final productFabric = product.material?.trim().toLowerCase() ?? '';
        if (productFabric.isEmpty) return false;
        bool isMatch = filters.selectedFabrics.any((filterFabric) => productFabric == filterFabric.trim().toLowerCase());
        // DEBUG LOG: Check the first few products
        if (allProducts.indexOf(product) < 3) {
          print("  [Fabric Check] Product: ${product.displayName}, Fabric: '$productFabric', Match: $isMatch");
        }
        return isMatch;
      }).toList();
    }
    print("Products after Fabric filter: ${tempFilteredList.length}");

    if (filters.selectedStyles.isNotEmpty) {
      tempFilteredList = tempFilteredList.where((product) {
        final productStyle = product.design?.trim().toLowerCase() ?? '';
        final productDressType = product.dressType?.trim().toLowerCase() ?? '';
        bool isMatch = filters.selectedStyles.any((filterStyle) {
          final lowerFilter = filterStyle.trim().toLowerCase();
          return productStyle == lowerFilter || productDressType == lowerFilter;
        });
        if (allProducts.indexOf(product) < 3) {
          print("  [Style Check] Product: ${product.displayName}, Style: '$productStyle' or '$productDressType', Match: $isMatch");
        }
        return isMatch;
      }).toList();
    }
    print("Products after Style filter: ${tempFilteredList.length}");

    if (filters.selectedColors.isNotEmpty) {
      tempFilteredList = tempFilteredList.where((product) {
        final productColors = product.selectedColors?.map((c) => c.trim().toLowerCase()).toSet() ?? {};
        if (productColors.isEmpty) return false;
        return filters.selectedColors.any((filterColor) => productColors.contains(filterColor.trim().toLowerCase()));
      }).toList();
    }
    print("Products after Color filter: ${tempFilteredList.length}");

    if (filters.selectedRatings.isNotEmpty) {
      tempFilteredList = tempFilteredList.where((product) {
        int mockRating = (product.id.hashCode % 5) + 1;
        return filters.selectedRatings.any((selectedRating) => mockRating >= selectedRating);
      }).toList();
    }
    print("Products after Rating filter: ${tempFilteredList.length}");

    if (filters.minPrice > 0 || filters.maxPrice < 50000) {
      tempFilteredList = tempFilteredList.where((product) {
        final price = product.price?.toDouble();
        if (price == null) return false;
        return price >= filters.minPrice && price <= filters.maxPrice;
      }).toList();
    }
    print("Products after Price filter: ${tempFilteredList.length}");

    // 3. Search Filter
    if (searchQuery.value.isNotEmpty) {
      final searchLower = searchQuery.value.toLowerCase();
      tempFilteredList = tempFilteredList.where((product) {
        return (product.displayName.toLowerCase().contains(searchLower)) ||
            (product.description.toLowerCase().contains(searchLower)) ||
            (product.dressType?.toLowerCase().contains(searchLower) ?? false) ||
            (product.material?.toLowerCase().contains(searchLower) ?? false) ||
            (product.design?.toLowerCase().contains(searchLower) ?? false);
      }).toList();
    }
    print("Products after Search filter: ${tempFilteredList.length}");

    print("--- [END] FILTERING COMPLETE. Final count: ${tempFilteredList.length} ---\n");
    filteredProducts.value = tempFilteredList;
  }

  void _updateActiveFilterCount() {
    int count = 0;
    final f = activeFilters.value;
    if (f.selectedColors.isNotEmpty) count++;
    if (f.minPrice > 0 || f.maxPrice < 50000) count++;
    if (f.selectedRatings.isNotEmpty) count++;
    if (f.selectedFabrics.isNotEmpty) count++;
    if (f.selectedStyles.isNotEmpty) count++;
    activeFilterCount.value = count;
  }

  void clearAllFilters() {
    searchQuery.value = '';
    activeFilters.value = FilterModel();
  }

  @override
  void onClose() {
    _productSubscription?.cancel();
    super.onClose();
  }
}