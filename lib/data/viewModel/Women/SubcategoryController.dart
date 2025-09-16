// lib/controllers/SubcategoryController.dart - NEW CONTROLLER

import 'package:get/get.dart';
import 'dart:async';
import '../../Services/FirebaseServices.dart';
import '../../model/Women/WomenModel.dart';

class SubcategoryController extends GetxController {
  final RxList<WomenProduct> products = <WomenProduct>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  StreamSubscription<List<WomenProduct>>? _productSubscription;
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

      _productSubscription = FirebaseProductService.getProductsByType(subcategoryType).listen(
            (productList) {
          print('✅ Found ${productList.length} products for "$subcategoryType"');
          products.value = productList;
          isLoading.value = false;

          if (productList.isEmpty) {
            print('⚠️ No products found for subcategory "$subcategoryType"');
            print('💡 Make sure Firebase has products with productType = "$subcategoryType"');
          } else {
            productList.take(2).forEach((p) =>
                print('Sample: ${p.name} - Type: "${p.category}" - Subcategory: "${p.subcategory}"'));
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

  void retryLoading() {
    print('🔄 Retrying to load products for "$currentSubcategory"');
    if (currentSubcategory.isNotEmpty) {
      loadProductsBySubcategory(currentSubcategory, currentSubcategoryName);
    }
  }

  @override
  void onClose() {
    _productSubscription?.cancel();
    super.onClose();
  }
}