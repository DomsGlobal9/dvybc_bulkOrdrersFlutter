import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../Favorites/FavoritesController.dart';
import '../../Favorites/FavoritesView.dart';
import '../../Cart/CartController.dart';
import '../../routes/routes.dart';
import '../tabview/tabviews.dart';
import 'CustomAppBar.dart';

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
  var categories = <Category>[
    Category(title: 'WOMEN', imagePath: 'assets/images/womenfl.jpg'),
    Category(title: 'MEN', imagePath: 'assets/images/jodpuri.jpg'),
    Category(title: 'KIDS', imagePath: 'assets/images/kids.jpg'),
    Category(title: 'Accessories', imagePath: 'assets/images/acces.jpg'),
  ].obs;

  var bestSellerProducts = <Product>[
    Product(
      title: 'Aarha Norangi Lehenga',
      price: '₹2999',
      imagePath: 'assets/images/womenfl.jpg',
      isAccessory: true,
    ),
    Product(
      title: 'Banarasi Saree',
      price: '₹4999',
      imagePath: 'assets/images/womenfl.jpg',
      isAccessory: false,
    ),
    Product(
      title: 'Baby Sets',
      price: '₹1999',
      imagePath: 'assets/images/kids.jpg',
      isAccessory: true,
    ),
    Product(
      title: 'Men\'s Formal Tie',
      price: '₹250',
      imagePath: 'assets/images/acces.jpg',
      isAccessory: false,
    ),
  ].obs;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  DateTime? _lastPressedAt;

  @override
  void onInit() {
    super.onInit();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void onClose() {
    _animationController.dispose();
    super.onClose();
  }

  void onCategoryPressed(String category) {
    Get.find<TabControllerX>().onTabTapped(2, category: category);
  }

  void onProductPressed(Product product) {
    // Navigate to product details
  }

  void onFavoritePressed(Product product) {
    final favController = Get.put(FavoritesController());
    favController.toggleProductFavorite(product);
  }

  void onAddToCartPressed(Product product) {
    final cartController = Get.put(CartController());
    cartController.addProductToCart(product);
  }

  // Handle back button press
  bool handleBackPress() {
    final now = DateTime.now();
    final shouldExit = _lastPressedAt == null ||
        now.difference(_lastPressedAt!) > Duration(seconds: 2);

    if (shouldExit) {
      _lastPressedAt = now;
      Get.snackbar(
        'Press back again to exit',
        '',
        duration: Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        margin: EdgeInsets.all(10),
      );
      return false; // Don't exit yet
    } else {
      return true; // Exit app
    }
  }

  Animation<double> get fadeAnimation => _fadeAnimation;
}

class HomeScreen extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
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
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 690,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: AssetImage('assets/images/homePic.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: () {
                        // TODO: handle view button action
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 300,
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: handle button tap
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF3B778C),
                              padding: EdgeInsets.all(15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                              elevation: 4,
                            ),
                            child: Text(
                              "View",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.grey[400],
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Find Your Preference',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.grey[400],
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Obx(() => GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: controller.categories.length,
                  itemBuilder: (context, index) {
                    return _buildCategoryCard(controller.categories[index], controller);
                  },
                )),
              ),
              SizedBox(height: 32),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Best Seller',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Show all',
                        style: TextStyle(
                          color: Color(0xFF1976D2),
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Obx(() => GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.65,
                  ),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: controller.bestSellerProducts.length,
                  itemBuilder: (context, index) {
                    return _buildProductCard(controller.bestSellerProducts[index], controller);
                  },
                )),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

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
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(category.imagePath),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.3),
                      BlendMode.darken,
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product, HomeController controller) {
    return GestureDetector(
      onTap: () => controller.onProductPressed(product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                      image: DecorationImage(
                        image: AssetImage(product.imagePath),
                        fit: BoxFit.cover,
                        onError: (error, stackTrace) {},
                      ),
                    ),
                    child: product.imagePath.isEmpty
                        ? Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 40,
                          color: Colors.grey[400],
                        ),
                      ),
                    )
                        : null,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => controller.onFavoritePressed(product),
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Obx(() {
                          final favController = Get.put(FavoritesController());
                          final isFav = favController.isProductFavorited(product);
                          return Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.red : Colors.grey[600],
                            size: 18,
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (product.isAccessory) ...[
                          SizedBox(height: 2),
                          Text(
                            'Accessories',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product.price,
                          style: TextStyle(
                            color: Color(0xFF1976D2),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => controller.onAddToCartPressed(product),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Color(0xFF1976D2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.add_shopping_cart,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}