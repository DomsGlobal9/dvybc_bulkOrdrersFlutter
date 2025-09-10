import 'package:get/get.dart';
import 'dart:async';
import '../Services/FirebaseServices.dart';
import '../model/Women/WomenModel.dart';

class SimpleTestController extends GetxController {
  final RxList<WomenProduct> WomenProducts = <WomenProduct>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxString status = 'Starting...'.obs;

  // FIXED: Changed from 'late' to nullable
  StreamSubscription<List<WomenProduct>>? _subscription;

  @override
  void onInit() {
    super.onInit();
    print('SimpleTestController: Starting...');
    loadAllProducts();
  }

  void loadAllProducts() {
    print('SimpleTestController: loadAllProducts() called');
    status.value = 'Loading products...';
    isLoading.value = true;
    error.value = '';

    // Cancel previous subscription if exists - NOW SAFE
    _subscription?.cancel();

    try {
      print('Calling FirebaseProductService.getAllProducts()');

      _subscription = FirebaseProductService.getAllProducts().listen(
            (products) {
          print('Controller received ${products.length} products');
          status.value = 'Found ${products.length} products';
          WomenProducts.value = products;
          isLoading.value = false;

          // Print first few products for debugging
          for (int i = 0; i < products.length && i < 3; i++) {
            print('Product $i: ${products[i].name} - ${products[i].category}');
          }
        },
        onError: (e) {
          print('Controller error: $e');
          status.value = 'Error: $e';
          error.value = e.toString();
          isLoading.value = false;
        },
      );
    } catch (e) {
      print('Controller exception: $e');
      status.value = 'Exception: $e';
      error.value = e.toString();
      isLoading.value = false;
    }
  }

  void retryLoading() {
    print('Retrying...');
    loadAllProducts();
  }

  @override
  void onClose() {
    // FIXED: Safe to cancel now since it's nullable
    _subscription?.cancel();
    super.onClose();
  }
}