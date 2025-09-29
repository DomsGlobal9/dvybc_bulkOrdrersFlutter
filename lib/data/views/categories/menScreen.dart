import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home/CustomAppBar.dart';
import '../home/homeScreen.dart';

// Controller for managing state
class MenController extends GetxController {
  final RxInt currentPage = 0.obs;
  final List<String> bannerImages = [
    'assets/images/categories/cate.png',
    'assets/images/categories/cate.png',
    'assets/images/categories/cate.png',
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

// Banner Widget
class BannerSection extends StatelessWidget {
  final MenController controller = Get.find<MenController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
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
    ));
  }
}

// Categories Header Widget
class CategoriesHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}

// Category Card Widget
class CategoryCard extends StatelessWidget {
  final String title;
  final String imagePath;

  CategoryCard({required this.title, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _navigateToCategory(context, title);
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

  void _navigateToCategory(BuildContext context, String categoryTitle) {
    // Navigate based on category using route constants
    switch (categoryTitle.toLowerCase()) {
      case 'ethnic wear':
        Get.toNamed('/men-ethnic-wear');
        break;
      case 'top wear':
        Get.toNamed('/men-top-wear');
        break;
      case 'bottom wear':
        Get.toNamed('/men-bottom-wear');
        break;
      case 'jumpsuits':
        Get.toNamed('/men-jumpsuits');
        break;
      case 'formal wear':
        Get.toNamed('/men-formal-wear');
        break;
      case 'sleep wear':
        Get.toNamed('/men-sleep-wear');
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

// Men Screen
class MenScreen extends StatelessWidget {
  final MenController controller = Get.put(MenController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Section
            BannerSection(),
            // Categories Section Header
            CategoriesHeader(),
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
                  CategoryCard(title: 'Ethnic wear', imagePath: 'assets/images/categories/menethinic.png'),
                  CategoryCard(title: 'Top wear', imagePath: 'assets/images/categories/mentop.png'),
                  CategoryCard(title: 'Bottom wear', imagePath: 'assets/images/categories/menbottom.png'),
                  CategoryCard(title: 'Jumpsuits', imagePath: 'assets/images/categories/menwinter.png'),
                  CategoryCard(title: 'Formal wear', imagePath: 'assets/images/categories/mensport.png'),
                  CategoryCard(title: 'Sleep wear', imagePath: 'assets/images/categories/meninner.png'),
                ],
              ),
            ),
            SizedBox(height: 20), // Bottom padding
          ],
        ),
      ),
    );
  }
}