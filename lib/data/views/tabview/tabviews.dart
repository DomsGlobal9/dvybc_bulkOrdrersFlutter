import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Favorites/FavoritesView.dart';
import '../Offers/OffersView.dart';
import '../Profile/ProfileView.dart';
import '../categories/WomenWear/WomenSubcategoryView.dart';
import '../home/homeScreen.dart';
import '../categories/WomenController.dart';
import '../categories/menScreen.dart';
import '../categories/kidsScreen.dart';
import '../../routes/routes.dart';

// CONTROLLER (No changes here)
class TabControllerX extends GetxController with GetTickerProviderStateMixin {
  var selectedIndex = 0.obs;
  var selectedCategory = ''.obs;

  var showSubcategory = false.obs;
  var selectedMainCategory = ''.obs;
  var showFavorites = false.obs;

  late List<AnimationController> tabControllers;
  late AnimationController scaleController;

  @override
  void onInit() {
    super.onInit();
    scaleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 150),
    );
    tabControllers = List.generate(
      4,
          (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 300), // Adjusted duration
      ),
    );
    tabControllers[0].forward();
  }

  void onTabTapped(int index, {String? category}) {
    if (index == selectedIndex.value && category == null) return;

    // Animate the text out on the old tab
    tabControllers[selectedIndex.value].reverse();
    selectedIndex.value = index;
    // Animate the text in on the new tab
    tabControllers[index].forward();

    if (category != null) {
      selectedCategory.value = category;
    }

    if (index != 2) {
      showSubcategory.value = false;
      selectedMainCategory.value = '';
    }
    showFavorites.value = false;
  }

  // Other controller methods...
  void navigateToSubcategory(String mainCategory) {
    selectedMainCategory.value = mainCategory;
    showSubcategory.value = true;
    showFavorites.value = false;
  }

  void backToMainCategories() {
    showSubcategory.value = false;
    selectedMainCategory.value = '';
    showFavorites.value = false;
  }

  void navigateToFavorites() {
    showFavorites.value = true;
    showSubcategory.value = false;
  }

  void backFromFavorites() {
    showFavorites.value = false;
  }

  @override
  void onClose() {
    scaleController.dispose();
    for (var controller in tabControllers) {
      controller.dispose();
    }
    super.onClose();
  }
}


// UI VIEW (Rebuilt to match your picture)
class CustomTabView extends StatelessWidget {
  final int initialTab;
  final controller = Get.put(TabControllerX());

  CustomTabView({this.initialTab = 0}) {
    controller.selectedIndex.value = initialTab;
    controller.tabControllers[initialTab].forward();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      backgroundColor: Colors.grey[50],
      body: IndexedStack(
        index: controller.selectedIndex.value,
        children: [
          // Screen views...
          Obx(() {
            if (controller.selectedIndex.value == 0 && controller.showFavorites.value) {
              return FavoritesView(onBackPressed: () => controller.backFromFavorites());
            }
            return HomeScreen();
          }),
          Obx(() {
            if (controller.selectedIndex.value == 1 && controller.showFavorites.value) {
              return FavoritesView(onBackPressed: () => controller.backFromFavorites());
            }
            return Offersview();
          }),
          Obx(() {
            if (controller.showFavorites.value) {
              return FavoritesView(onBackPressed: () => controller.backFromFavorites());
            }
            if (controller.showSubcategory.value && controller.selectedMainCategory.value.isNotEmpty) {
              return WomenSubcategoryView(mainCategory: controller.selectedMainCategory.value, onBackPressed: () => controller.backToMainCategories());
            }
            switch (controller.selectedCategory.value) {
              case 'WOMEN': return WomenScreen();
              case 'MEN': return MenScreen();
              case 'KIDS': return KidsScreen();
              default: return WomenScreen();
            }
          }),
          Obx(() {
            if (controller.selectedIndex.value == 3 && controller.showFavorites.value) {
              return FavoritesView(onBackPressed: () => controller.backFromFavorites());
            }
            return ProfileViewForTab();
          }),
        ],
      ),
      bottomNavigationBar: Container(
        height: 70,
        margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              spreadRadius: 0,
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTabItem(
              index: 0,
              iconAsset: 'assets/tabview/homel.png',
              label: 'Home',
            ),
            _buildTabItem(
              index: 1,
              iconAsset: 'assets/tabview/offers.png',
              label: 'Offers',
            ),
            _buildTabItem(
              index: 2,
              iconAsset: 'assets/tabview/categories.png',
              label: 'Categories',
            ),
            _buildTabItem(
              index: 3,
              iconAsset: 'assets/tabview/profile.png',
              label: 'Profile',
            ),
          ],
        ),
      ),
    ));
  }

  // ## THIS WIDGET CREATES THE DESIGN FROM YOUR PICTURE ##
  Widget _buildTabItem({
    required int index,
    required String iconAsset,
    required String label,
  }) {
    return GestureDetector(
      onTap: () => controller.onTabTapped(index),
      child: Obx(() {
        final isSelected = controller.selectedIndex.value == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: isSelected ? 18.0 : 12.0),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF2196F3) : Colors.transparent,
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                iconAsset,
                width: 28, // Good, visible icon size
                height: 28,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
              // Use AnimatedSize to smoothly show/hide the text
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: Row(
                  children: [
                    if (isSelected)
                      SizedBox(width: 8.0),
                    if (isSelected)
                      Text(
                        label,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15, // Good, readable font size
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}