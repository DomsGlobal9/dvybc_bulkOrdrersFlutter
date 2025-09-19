import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home/homeScreen.dart';
import '../tabview/tabviews.dart';

class WomenController extends GetxController {
  final RxInt currentPage = 0.obs;
  final List<String> bannerImages = [
    'assets/images/categories/catog.png',
    'assets/images/categories/catog.png',
    'assets/images/categories/catog.png',
  ];

  @override
  void onInit() {
    super.onInit();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(Duration.zero, () {
      ever(currentPage, (_) {
        Future.delayed(Duration(seconds: 3), () {
          int nextPage = (currentPage.value + 1) % bannerImages.length;
          currentPage.value = nextPage;
        });
      });
    });
  }

  @override
  void onClose() {
    super.onClose();
  }
}

// Static Category Data Model
class CategoryData {
  final String name;
  final String assetImage;
  final String productType;

  CategoryData({
    required this.name,
    required this.assetImage,
    required this.productType,
  });
}

class WomenScreen extends StatelessWidget {
  final WomenController controller = Get.put(WomenController());

  // Static category data based on your requirements
  final List<CategoryData> categories = [
    CategoryData(
      name: 'Ethnic wear',
      assetImage: 'assets/images/categories/ethnic.png',
      productType: 'kurta',
    ),
    CategoryData(
      name: 'Top wear',
      assetImage: 'assets/images/categories/topwear.png',
      productType: 'top wear',
    ),
    CategoryData(
      name: 'Bottom wear',
      assetImage: 'assets/images/categories/bottom.png',
      productType: 'bottom wear',
    ),
    CategoryData(
      name: 'Jumpsuits',
      assetImage: 'assets/images/categories/jumpsuit.png',
      productType: 'jumpsuit',
    ),
    CategoryData(
      name: 'Maternity',
      assetImage: 'assets/images/categories/maternity.jpg',
      productType: 'maternity',
    ),
    CategoryData(
      name: 'Sleep wear',
      assetImage: 'assets/images/categories/sleepwear.png',
      productType: 'sleepwear',
    ),
    CategoryData(
      name: 'Winter wear',
      assetImage: 'assets/images/categories/winterwear.png',
      productType: 'winterwear',
    ),
    CategoryData(
      name: 'Active wear',
      assetImage: 'assets/images/categories/active.png',
      productType: 'activewear',
    ),
    CategoryData(
      name: 'Inner wear',
      assetImage: 'assets/images/categories/inner.png',
      productType: 'innerwear',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(),
      body: Obx(() => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Section
            Container(
              height: 200,
              margin: EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: PageView.builder(
                  itemCount: controller.bannerImages.length,
                  controller: PageController(initialPage: controller.currentPage.value),
                  onPageChanged: (index) {
                    controller.currentPage.value = index;
                  },
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.grey[200],
                      ),
                      child: Image.asset(
                        controller.bannerImages[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: Icon(
                                Icons.image_outlined,
                                size: 60,
                                color: Colors.grey[400],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),

            // Categories Section Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Show all',
                      style: TextStyle(
                        color: Color(0xFF3B82F6),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Categories Grid - STATIC with asset images
            Padding(
              padding: EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.55,
                ),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return _buildCategoryCard(categories[index]);
                },
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      )),
    );
  }

  Widget _buildCategoryCard(CategoryData category) {
    return GestureDetector(
      onTap: () {
        // Use the tab controller to navigate instead of Get.toNamed
        final tabController = Get.find<TabControllerX>();
        tabController.navigateToSubcategory(category.name);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Full image background
              Positioned.fill(
                child: Image.asset(
                  category.assetImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 40,
                          color: Colors.grey[400],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Text overlay at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Text(
                    category.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 2,
                          color: Colors.black.withOpacity(0.8),
                        ),
                      ],
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
}