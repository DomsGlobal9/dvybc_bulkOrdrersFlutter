import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/Women/WomenModel.dart';
import '../../Cart/Cart/CartController.dart';
import '../../Favorites/FavoritesController.dart';
import '../../routes/routes.dart';
import '../tabview/tabviews.dart';
import 'CustomAppBar.dart';

// This legacy Product class is kept for compatibility with other controllers
class Product {
  final String title;
  final String price;
  final String imagePath;
  final bool isAccessory;
  bool isFavorited;

  Product({
    required this.title,
    required this.price,
    required this.imagePath,
    this.isAccessory = false,
    this.isFavorited = false,
  });
}

class Category {
  final String title;
  final String imagePath;

  Category({
    required this.title,
    required this.imagePath,
  });
}

class HomeController extends GetxController with GetSingleTickerProviderStateMixin {
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;
  StreamSubscription<QuerySnapshot>? _productSubscription;

  var categories = <Category>[
    Category(title: 'WOMEN', imagePath: 'assets/images/womenfl.jpg'),
    Category(title: 'MEN', imagePath: 'assets/images/jodpuri.jpg'),
    Category(title: 'KIDS', imagePath: 'assets/images/kids.jpg'),
    Category(title: 'Accessories', imagePath: 'assets/images/acces.jpg'),
  ].obs;

  var dailyDeals = <WomenProduct>[].obs;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  DateTime? _lastPressedAt;

  @override
  void onInit() {
    super.onInit();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    _fetchDailyDeals();
  }

  void _fetchDailyDeals() async {
    isLoading.value = true;
    error.value = '';
    final prefs = await SharedPreferences.getInstance();

    final lastFetchMillis = prefs.getInt('lastDealsFetchTime') ?? 0;
    final lastFetchTime = DateTime.fromMillisecondsSinceEpoch(lastFetchMillis);
    final now = DateTime.now();

    if (now.difference(lastFetchTime).inHours >= 24) {
      _fetchNewDealsFromFirestore(prefs);
    } else {
      _loadCachedDeals(prefs);
    }
  }

  void _fetchNewDealsFromFirestore(SharedPreferences prefs) {
    _productSubscription = FirebaseFirestore.instance
        .collectionGroup('products')
        .limit(50)
        .snapshots()
        .listen((snapshot) async {
      List<WomenProduct> fetchedProducts = [];
      for (var doc in snapshot.docs) {
        try {
          String userId = doc.reference.parent.parent!.id;
          fetchedProducts.add(WomenProduct.fromFirestore(doc.data() as Map<String, dynamic>, doc.id, userId));
        } catch (e) { /* silent fail */ }
      }

      fetchedProducts.shuffle();
      dailyDeals.value = fetchedProducts.take(4).toList();

      if (dailyDeals.isNotEmpty) {
        List<String> dealIds = dailyDeals.map((p) => p.id).toList();
        await prefs.setStringList('savedDealIds', dealIds);
        await prefs.setInt('lastDealsFetchTime', DateTime.now().millisecondsSinceEpoch);
      }
      isLoading.value = false;
      _productSubscription?.cancel();
    }, onError: (e) {
      error.value = "Failed to load deals: $e";
      isLoading.value = false;
    });
  }

  void _loadCachedDeals(SharedPreferences prefs) async {
    final savedDealIds = prefs.getStringList('savedDealIds');
    if (savedDealIds == null || savedDealIds.isEmpty) {
      _fetchNewDealsFromFirestore(prefs);
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collectionGroup('products')
          .where(FieldPath.documentId, whereIn: savedDealIds)
          .get();

      List<WomenProduct> cachedProducts = [];
      for (var doc in snapshot.docs) {
        try {
          String userId = doc.reference.parent.parent!.id;
          cachedProducts.add(WomenProduct.fromFirestore(doc.data() as Map<String, dynamic>, doc.id, userId));
        } catch (e) { /* silent fail */ }
      }
      dailyDeals.value = cachedProducts;
    } catch (e) {
      error.value = "Failed to load cached deals: $e";
      _fetchNewDealsFromFirestore(prefs);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _animationController.dispose();
    _productSubscription?.cancel();
    super.onClose();
  }

  void onCategoryPressed(String category) {
    Get.find<TabControllerX>().onTabTapped(2, category: category);
  }

  void onProductPressed(WomenProduct product) {
    Get.toNamed(AppRoutes.productSingle, arguments: {'product': product});
  }

  Product _convertToLegacyProduct(WomenProduct product) {
    return Product(title: product.displayName, price: '₹${product.price ?? 0}', imagePath: product.image);
  }

  void onFavoritePressed(WomenProduct product) {
    final favController = Get.put(FavoritesController());
    favController.toggleProductFavorite(_convertToLegacyProduct(product));
  }

  void onAddToCartPressed(WomenProduct product) {
    final cartController = Get.put(CartController());
    cartController.addProductToCart(_convertToLegacyProduct(product));
  }

  bool handleBackPress() {
    final now = DateTime.now();
    final shouldExit = _lastPressedAt == null || now.difference(_lastPressedAt!).inSeconds > 2;
    if (shouldExit) {
      _lastPressedAt = now;
      Get.snackbar('Press back again to exit', '', duration: const Duration(seconds: 2), snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.black87, colorText: Colors.white, margin: const EdgeInsets.all(10));
      return false;
    }
    return true;
  }
}

class HomeScreen extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldExit = controller.handleBackPress();
        if (shouldExit) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: CustomAppBar(),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: const SizedBox(height: 20)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: screenHeight * 0.65,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/homePic.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: SizedBox(
                        width: 300,
                        child: ElevatedButton(
                          onPressed: () => Get.find<TabControllerX>().onTabTapped(2),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B778C),
                            padding: const EdgeInsets.all(15),
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                            elevation: 4,
                          ),
                          child: const Text("View", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 32)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[400])),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Find Your Preference', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ),
                    Expanded(child: Divider(color: Colors.grey[400])),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 20)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.85),
                delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildCategoryCard(controller.categories[index], controller),
                  childCount: controller.categories.length,
                ),
              ),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 32)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Best Seller', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                    GestureDetector(
                      onTap: () => Get.find<TabControllerX>().onTabTapped(2),
                      child: const Text(
                          'Show all',
                          style: TextStyle(
                              color: Color(0xFF9B9B9B),
                              fontWeight: FontWeight.w400,
                              fontSize: 13
                          )
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 16)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              sliver: Obx(() {
                if (controller.isLoading.value) {
                  return _buildSliverShimmerGrid();
                }
                if (controller.dailyDeals.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text("No items available right now."))),
                  );
                }
                return SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200.0, mainAxisSpacing: 16.0, crossAxisSpacing: 16.0, childAspectRatio: 0.58),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildProductCard(controller.dailyDeals[index], controller),
                    childCount: controller.dailyDeals.length,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // --- FIX: Restored the code for this widget ---
  Widget _buildCategoryCard(Category category, HomeController controller) {
    return GestureDetector(
      onTap: () => controller.onCategoryPressed(category.title),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4))
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                category.imagePath,
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.3),
                colorBlendMode: BlendMode.darken,
              ),
              Center(
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    category.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverShimmerGrid() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200.0, mainAxisSpacing: 16.0, crossAxisSpacing: 16.0, childAspectRatio: 0.58),
      delegate: SliverChildBuilderDelegate(
            (context, index) => Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4))),
        ),
        childCount: 4,
      ),
    );
  }

  Widget _buildProductCard(WomenProduct product, HomeController controller) {
    return GestureDetector(
      onTap: () => controller.onProductPressed(product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: product.image.isNotEmpty
                        ? Image.network(
                      product.image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: Center(child: Icon(Icons.broken_image, color: Colors.grey[400]))),
                    )
                        : Container(
                        color: Colors.grey[200],
                        child: Center(child: Icon(Icons.image_not_supported, color: Colors.grey[400]))),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => controller.onFavoritePressed(product),
                      child: Obx(() {
                        final favController = Get.put(FavoritesController());
                        final legacyProduct = controller._convertToLegacyProduct(product);
                        final isFav = favController.isProductFavorited(legacyProduct);
                        return Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: Colors.white,
                          size: 23,
                          shadows: const [
                            Shadow(color: Colors.black54, blurRadius: 8)
                          ],
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.displayName,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w400
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${product.price ?? 0}',
                    style: const TextStyle(
                        color: Color(0xFF19567C),
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}