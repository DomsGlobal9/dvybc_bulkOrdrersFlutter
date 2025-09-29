import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Favorites/FavoritesController.dart';
import '../../Cart/CartController.dart';
import '../tabview/tabviews.dart';




class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TabControllerX>();
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1976D2), Colors.white],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/DVYBL.png",
                    width: 120,
                    height: 35,
                    errorBuilder: (context, error, stackTrace) {
                      return Text(
                        'DVYB',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 1),
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search for "Shirts"',
                    hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 20),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.favorite_border, color: Colors.grey[600], size: 20),
                          onPressed: () {
                            Get.put(FavoritesController());
                            // Navigate to favorites within tab structure
                            final tabController = Get.find<TabControllerX>();
                            tabController.navigateToFavorites(); // This keeps the tab bar visible
                          },
                          constraints: BoxConstraints(minWidth: 32),
                          padding: EdgeInsets.zero,
                        ),
                        // Updated Cart Icon with badge
                        Stack(
                          children: [
                            IconButton(
                              icon: Icon(Icons.shopping_bag_outlined, color: Colors.grey[600], size: 20),
                              onPressed: () {
                                // Initialize CartController if not already initialized
                                Get.put(CartController());
                                // Navigate to cart screen
                                Get.toNamed('/cart');
                              },
                              constraints: BoxConstraints(minWidth: 32),
                              padding: EdgeInsets.zero,
                            ),
                            // Cart badge showing item count
                            Obx(() {
                              final cartController = Get.put(CartController());
                              return cartController.totalItems > 0
                                  ? Positioned(
                                right: 6,
                                top: 6,
                                child: Container(
                                  padding: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    '${cartController.totalItems}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                                  : SizedBox.shrink();
                            }),
                          ],
                        ),
                      ],
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavButton('WOMEN', controller),
                  _buildNavButton('MEN', controller),
                  _buildNavButton('KIDS', controller),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(String title, TabControllerX controller) {
    bool isSelected = controller.selectedIndex.value == 2 &&
        controller.selectedCategory.value == title;

    return GestureDetector(
      onTap: () {
        controller.onTabTapped(2, category: title); // Navigate to Categories tab
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: isSelected ? Color(0xFF1976D2) : Colors.black54,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          SizedBox(height: 6),
          Container(
            height: 2,
            width: 42,
            color: isSelected ? Color(0xFF1976D2) : Colors.transparent,
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(140);
}