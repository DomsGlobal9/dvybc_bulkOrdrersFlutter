// import 'package:get/get.dart';
// import 'dart:async';
// import '../Services/FirebaseServices.dart';
// import '../model/Women/WomenModel.dart';
//
// class ProductsController extends GetxController {
//   // Observable lists
//   final RxList<WomenProduct> allProducts = <WomenProduct>[].obs;
//   final RxList<WomenProduct> filteredProducts = <WomenProduct>[].obs;
//   final RxList<WomenProduct> userProducts = <WomenProduct>[].obs;
//
//   // Loading and error states
//   final RxBool isLoading = false.obs;
//   final RxString error = ''.obs;
//   final RxBool isCreatingTestData = false.obs;
//
//   // Filter states
//   final RxString searchTerm = ''.obs;
//   final RxString selectedCategory = 'ALL'.obs;
//   final RxString selectedDressType = 'ALL'.obs;
//   final RxString selectedFabric = 'ALL'.obs;
//   final RxString selectedCraft = 'ALL'.obs;
//
//   // Filter options (dynamically loaded)
//   final RxList<String> availableDressTypes = <String>[].obs;
//   final RxList<String> availableFabrics = <String>[].obs;
//   final RxList<String> availableCategories = <String>[].obs;
//
//   // Debug info
//   final RxMap<String, dynamic> debugInfo = <String, dynamic>{}.obs;
//
//   // Subscriptions
//   StreamSubscription<List<WomenProduct>>? _allProductsSubscription;
//   StreamSubscription<List<WomenProduct>>? _userProductsSubscription;
//
//   @override
//   void onInit() {
//     super.onInit();
//
//     // Set up reactive filters
//     ever(searchTerm, (_) => _applyFilters());
//     ever(selectedCategory, (_) => _applyFilters());
//     ever(selectedDressType, (_) => _applyFilters());
//     ever(selectedFabric, (_) => _applyFilters());
//     ever(selectedCraft, (_) => _applyFilters());
//
//     // Load initial data
//     fetchAllProducts();
//     loadFilterOptions();
//   }
//
//   // Fetch all products from all users (like React collectionGroup)
//   void fetchAllProducts() {
//     print('🚀 Starting to fetch all products...');
//
//     isLoading.value = true;
//     error.value = '';
//
//     try {
//       _allProductsSubscription?.cancel();
//
//       _allProductsSubscription = FirebaseProductService.getAllProducts().listen(
//             (products) {
//           print('✅ Received ${products.length} products from all users');
//           allProducts.value = products;
//           _applyFilters();
//           isLoading.value = false;
//
//           if (products.isNotEmpty) {
//             print(
//                 'Sample products: ${products.take(3).map((p) => '${p.name} (${p
//                     .userId})').toList()}');
//           }
//         },
//         onError: (e) {
//           print('❌ Error fetching all products: $e');
//           error.value = 'Failed to load products: $e';
//           isLoading.value = false;
//           allProducts.clear();
//         },
//       );
//     } catch (e) {
//       print('❌ Exception in fetchAllProducts: $e');
//       error.value = 'Failed to load products: $e';
//       isLoading.value = false;
//     }
//   }
//
//   // Fetch products from a specific user
//   void fetchProductsByUser(String userId) {
//     print('🔍 Fetching products for user: $userId');
//
//     isLoading.value = true;
//     error.value = '';
//
//     try {
//       _userProductsSubscription?.cancel();
//
//       _userProductsSubscription =
//           FirebaseProductService.getProductsByUser(userId).listen(
//                 (products) {
//               print('✅ Received ${products.length} products from user $userId');
//               userProducts.value = products;
//               isLoading.value = false;
//             },
//             onError: (e) {
//               print('❌ Error fetching products for user $userId: $e');
//               error.value = 'Failed to load user products: $e';
//               isLoading.value = false;
//               userProducts.clear();
//             },
//           );
//     } catch (e) {
//       print('❌ Exception in fetchProductsByUser: $e');
//       error.value = 'Failed to load user products: $e';
//       isLoading.value = false;
//     }
//   }
//
//   // Load filter options dynamically from Firebase
//   void loadFilterOptions() async {
//     try {
//       print('📋 Loading filter options...');
//
//       // Load available categories
//       final categories = await FirebaseProductService.getCategories();
//       availableCategories.value = ['ALL', ...categories];
//
//       // Load available dress types
//       final dressTypes = await FirebaseProductService.getDressTypes();
//       availableDressTypes.value = ['ALL', ...dressTypes];
//
//       // Load available fabrics
//       final fabrics = await FirebaseProductService.getFabrics();
//       availableFabrics.value = ['ALL', ...fabrics];
//
//       print('✅ Filter options loaded successfully');
//     } catch (e) {
//       print('❌ Error loading filter options: $e');
//     }
//   }
//
//   // Apply filters to products (like React implementation)
//   void _applyFilters() {
//     List<WomenProduct> products = List.from(allProducts);
//
//     // Apply search filter
//     if (searchTerm.value.isNotEmpty) {
//       final query = searchTerm.value.toLowerCase();
//       products = products.where((product) =>
//       product.name.toLowerCase().contains(query) ||
//           product.description.toLowerCase().contains(query) ||
//           product.dressType?.toLowerCase().contains(query) == true ||
//           product.material?.toLowerCase().contains(query) == true ||
//           product.craft?.toLowerCase().contains(query) == true
//       ).toList();
//     }
//
//     // Apply category filter
//     if (selectedCategory.value != 'ALL') {
//       products = products.where((product) =>
//       product.category.toLowerCase() == selectedCategory.value.toLowerCase()
//       ).toList();
//     }
//
//     // Apply dress type filter
//     if (selectedDressType.value != 'ALL') {
//       products = products.where((product) =>
//       product.dressType?.toLowerCase() == selectedDressType.value.toLowerCase()
//       ).toList();
//     }
//
//     // Apply fabric filter
//     if (selectedFabric.value != 'ALL') {
//       products = products.where((product) =>
//       product?.material?.toLowerCase() == selectedFabric.value.toLowerCase() ||
//           product?.fabric?.toLowerCase() == selectedFabric.value.toLowerCase()
//       ).toList();
//     }
//
//     // Apply craft filter
//     if (selectedCraft.value != 'ALL') {
//       products = products.where((product) =>
//       product.design?.toLowerCase() == selectedCraft.value.toLowerCase() ||
//           product.craft?.toLowerCase() == selectedCraft.value.toLowerCase()
//       ).toList();
//     }
//
//     // Sort by timestamp (newest first) like React implementation
//     products.sort((a, b) {
//       if (a.timestamp != null && b.timestamp != null) {
//         if (a.timestamp is Timestamp && b.timestamp is Timestamp) {
//           return (b.timestamp as Timestamp).compareTo(a.timestamp as Timestamp);
//         }
//       }
//       return 0;
//     });
//
//     filteredProducts.value = products;
//     print('🔍 Applied filters: ${products.length} products after filtering');
//   }
//
//   // Search products
//   void searchProducts(String query) {
//     searchTerm.value = query;
//   }
//
//   // Set category filter
//   void setCategory(String category) {
//     selectedCategory.value = category;
//   }
//
//   // Set dress type filter
//   void setDressType(String dressType) {
//     selectedDressType.value = dressType;
//   }
//
//   // Set fabric filter
//   void setFabric(String fabric) {
//     selectedFabric.value = fabric;
//   }
//
//   // Set craft filter
//   void setCraft(String craft) {
//     selectedCraft.value = craft;
//   }
//
//   // Clear all filters
//   void clearAllFilters() {
//     searchTerm.value = '';
//     selectedCategory.value = 'ALL';
//     selectedDressType.value = 'ALL';
//     selectedFabric.value = 'ALL';
//     selectedCraft.value = 'ALL';
//   }
//
//   // Get active filter count
//   int get activeFilterCount {
//     int count = 0;
//     if (searchTerm.value.isNotEmpty) count++;
//     if (selectedCategory.value != 'ALL') count++;
//     if (selectedDressType.value != 'ALL') count++;
//     if (selectedFabric.value != 'ALL') count++;
//     if (selectedCraft.value != 'ALL') count++;
//     return count;
//   }
//
//   // Get products by category
//   void getProductsByCategory(String category) {
//     isLoading.value = true;
//     error.value = '';
//
//     try {
//       _allProductsSubscription?.cancel();
//
//       _allProductsSubscription =
//           FirebaseProductService.getProductsByCategory(category).listen(
//                 (products) {
//               print('✅ Received ${products
//                   .length} products for category $category');
//               allProducts.value = products;
//               filteredProducts.value = products;
//               isLoading.value = false;
//             },
//             onError: (e) {
//               print('❌ Error fetching products by category: $e');
//               error.value = 'Failed to load products: $e';
//               isLoading.value = false;
//             },
//           );
//     } catch (e) {
//       print('❌ Exception in getProductsByCategory: $e');
//       error.value = 'Failed to load products: $e';
//       isLoading.value = false;
//     }
//   }
//
//   // Get products by dress type
//   void getProductsByDressType(String dressType) {
//     isLoading.value = true;
//     error.value = '';
//
//     try {
//       _allProductsSubscription?.cancel();
//
//       _allProductsSubscription =
//           FirebaseProductService.getProductsByDressType(dressType).listen(
//                 (products) {
//               print('✅ Received ${products
//                   .length} products for dress type $dressType');
//               allProducts.value = products;
//               filteredProducts.value = products;
//               isLoading.value = false;
//             },
//             onError: (e) {
//               print('❌ Error fetching products by dress type: $e');
//               error.value = 'Failed to load products: $e';
//               isLoading.value = false;
//             },
//           );
//     } catch (e) {
//       print('❌ Exception in getProductsByDressType: $e');
//       error.value = 'Failed to load products: $e';
//       isLoading.value = false;
//     }
//   }
//
//   // Debug Firebase structure
//   void debugFirebaseStructure() async {
//     try {
//       print('🔍 Running Firebase debug...');
//       final debug = await FirebaseProductService.debugFirebaseStructure();
//       debugInfo.value = debug;
//       print('✅ Debug completed: $debug');
//     } catch (e) {
//       print('❌ Debug failed: $e');
//       debugInfo.value = {'error': e.toString()};
//     }
//   }
//
//   // Retry loading
//   void retryLoading() {
//     print('🔄 Retrying to load products...');
//     fetchAllProducts();
//   }
//
//   // Check if products are empty
//   bool get isEmpty =>
//       !isLoading.value && allProducts.isEmpty && error.value.isEmpty;
//
//   // Check if has products
//   bool get hasProducts => allProducts.isNotEmpty;
//
//   // Get filtered products count
//   int get filteredCount => filteredProducts.length;
//
//   // Get total products count
//   int get totalCount => allProducts.length;
//
//   @override
//   void onClose() {
//     _allProductsSubscription?.cancel();
//     _userProductsSubscription?.cancel();
//     super.onClose();
//   }
// }
//
// class Timestamp {
//   int compareTo(Timestamp timestamp) {}
// }