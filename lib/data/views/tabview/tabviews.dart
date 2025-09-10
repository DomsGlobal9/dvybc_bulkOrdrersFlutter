import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Offers/OffersView.dart';
import '../Profile/ProfileView.dart';
import '../home/homeScreen.dart';
import '../categories/WomenController.dart';
import '../categories/menScreen.dart';
import '../categories/kidsScreen.dart';
import '../../routes/routes.dart';

class TabControllerX extends GetxController with GetTickerProviderStateMixin {
  var selectedIndex = 0.obs;
  var selectedCategory = ''.obs; // Track selected category

  late List<AnimationController> tabControllers;
  late AnimationController scaleController;

  final List<String> tabRoutes = [
    AppRoutes.home,
    AppRoutes.offers,
    AppRoutes.categories,
    AppRoutes.profile,
  ];

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
        duration: Duration(milliseconds: 400),
      ),
    );
    tabControllers[0].forward();
  }

  void onTabTapped(int index, {String? category}) {
    if (index == selectedIndex.value && category == null) return;

    scaleController.forward().then((_) => scaleController.reverse());
    tabControllers[selectedIndex.value].reverse();
    selectedIndex.value = index;
    tabControllers[index].forward();

    if (category != null) {
      selectedCategory.value = category;
    }
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
          HomeScreen(),
          Offersview(),
          Obx(() {
            switch (controller.selectedCategory.value) {
              case 'WOMEN':
                return WomenScreen();
              case 'MEN':
                return MenScreen();
              case 'KIDS':
                return KidsScreen();
              default:
                return Scaffold(
                  appBar: CustomAppBar(),
                  body: SafeArea(
                    child: Center(
                      child: Text(
                        'Categories View',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                );
            }
          }),
          ProfileViewForTab(),
        ],
      ),
      bottomNavigationBar: Container(
        height: 70,
        margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
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
              unselectedImage: 'assets/tabview/homel.png',
              selectedImage: 'assets/tabview/homesel.png',
              label: 'Home',
              fallbackUnselected: Icons.home_outlined,
              fallbackSelected: Icons.home,
            ),
            _buildTabItem(
              index: 1,
              unselectedImage: 'assets/tabview/offerr.png',
              selectedImage: 'assets/tabview/offerl.png',
              label: 'Offers',
              fallbackUnselected: Icons.local_offer_outlined,
              fallbackSelected: Icons.local_offer,
            ),
            _buildTabItem(
              index: 2,
              unselectedImage: 'assets/tabview/categories.png',
              selectedImage: 'assets/tabview/categoriesl.png',
              label: 'Categories',
              fallbackUnselected: Icons.apps_outlined,
              fallbackSelected: Icons.apps,
            ),
            _buildTabItem(
              index: 3,
              unselectedImage: 'assets/tabview/profilee.png',
              selectedImage: 'assets/tabview/profilesl.png',
              label: 'Profile',
              fallbackUnselected: Icons.person_outline,
              fallbackSelected: Icons.person,
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildTabItem({
    required int index,
    required String unselectedImage,
    required String selectedImage,
    required String label,
    required IconData fallbackUnselected,
    required IconData fallbackSelected,
  }) {
    return GestureDetector(
      onTap: () => controller.onTabTapped(index),
      child: AnimatedBuilder(
        animation: Listenable.merge([
          controller.tabControllers[index],
          controller.scaleController,
        ]),
        builder: (context, child) {
          final isSelected = controller.selectedIndex.value == index;
          final scaleValue = isSelected ? 1.0 - (controller.scaleController.value * 0.05) : 1.0;

          return Transform.scale(
            scale: scaleValue,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              height: 45,
              padding: EdgeInsets.symmetric(horizontal: isSelected ? 16 : 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isSelected ? Color(0xFF2196F3) : Colors.transparent,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    child: isSelected
                        ? Image.asset(
                      selectedImage,
                      width: 22,
                      height: 22,
                      color: Colors.white,
                      errorBuilder: (_, __, ___) => Icon(
                        fallbackSelected,
                        size: 22,
                        color: Colors.white,
                      ),
                    )
                        : Image.asset(
                      unselectedImage,
                      width: 22,
                      height: 22,
                      color: Colors.grey[600],
                      errorBuilder: (_, __, ___) => Icon(
                        fallbackUnselected,
                        size: 22,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    width: isSelected ? 8 : 0,
                  ),
                  AnimatedSize(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOutCubic,
                    child: isSelected
                        ? FadeTransition(
                      opacity: controller.tabControllers[index],
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(0.3, 0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: controller.tabControllers[index],
                          curve: Curves.easeOutCubic,
                        )),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                        : SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}