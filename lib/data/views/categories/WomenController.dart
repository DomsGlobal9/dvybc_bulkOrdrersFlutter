import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home/homeScreen.dart';

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

class WomenScreen extends StatelessWidget {
  final WomenController controller = Get.put(WomenController());

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

            // Categories Grid
            Padding(
              padding: EdgeInsets.all(16),
              child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
                childAspectRatio: 0.55,
                children: [
                  _buildCategoryCard('Ethnic wear', 'assets/images/categories/ethnic.png'),
                  _buildCategoryCard('Top wear', 'assets/images/categories/topwear.png'),
                  _buildCategoryCard('Bottom wear', 'assets/images/categories/bottom.png'),
                  _buildCategoryCard('Jumpsuits', 'assets/images/categories/jumpsuit.png'),
                  _buildCategoryCard('Maternity', 'assets/images/categories/maternity.jpg'),
                  _buildCategoryCard('Sleep wear', 'assets/images/categories/sleepwear.png'),
                  _buildCategoryCard('Winter wear', 'assets/images/categories/winterwear.png'),
                  _buildCategoryCard('Active wear', 'assets/images/categories/active.png'),
                  _buildCategoryCard('Inner wear', 'assets/images/categories/inner.png'),
                ],
              ),
            ),
            SizedBox(height: 20), // Bottom padding
          ],
        ),
      )),
    );
  }

  Widget _buildCategoryCard(String title, String imagePath) {
    return GestureDetector(
      onTap: () {
        // Navigate to respective category screen
        _navigateToCategory(title);
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
                  imagePath,
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
                    title,
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

  void _navigateToCategory(String categoryTitle) {
    // Navigate based on category using route constants
    switch (categoryTitle.toLowerCase()) {
      case 'ethnic wear':
        Get.toNamed('/ethnic-wear');
        break;
      case 'top wear':
        Get.toNamed('/top-wear');
        break;
      case 'bottom wear':
        Get.toNamed('/bottom-wear');
        break;
      case 'jumpsuits':
        Get.toNamed('/jumpsuits');
        break;
      case 'maternity':
        Get.toNamed('/maternity');
        break;
      case 'sleep wear':
        Get.toNamed('/sleep-wear');
        break;
      case 'winter wear':
        Get.toNamed('/winter-wear');
        break;
      case 'active wear':
        Get.toNamed('/active-wear');
        break;
      case 'inner wear':
        Get.toNamed('/inner-wear');
        break;
      default:
        Get.snackbar(
          'Coming Soon',
          '$categoryTitle section will be available soon!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
        );
    }
  }
}