import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home/homeScreen.dart';

// Boys View with AppBar
class BoysView extends StatelessWidget {
  const BoysView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Container(
              height: 200,
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.blue[100],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/categories/boys_collection.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.blue[100],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.child_care,
                              size: 50,
                              color: Colors.blue[300],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Boys Collection',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Categories Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Boys Categories',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 16),

            // Boys Categories Grid
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildCategoryCard('T-Shirts', 'assets/images/categories/boys_tshirts.png'),
                  _buildCategoryCard('Shirts', 'assets/images/categories/boys_shirts.png'),
                  _buildCategoryCard('Pants', 'assets/images/categories/boys_pants.png'),
                  _buildCategoryCard('Shorts', 'assets/images/categories/boys_shorts.png'),
                  _buildCategoryCard('Jackets', 'assets/images/categories/boys_jackets.png'),
                  _buildCategoryCard('Ethnic Wear', 'assets/images/categories/boys_ethnic.png'),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Coming Soon Message
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.construction,
                    size: 40,
                    color: Colors.blue[600],
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Boys Collection Coming Soon!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'We are working hard to bring you the best boys collection.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, String imagePath) {
    return GestureDetector(
      onTap: () {
        Get.snackbar(
          'Coming Soon',
          '$title will be available soon!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.blue[100],
                        child: Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 30,
                            color: Colors.blue[300],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(12),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Girls View with AppBar
class GirlsView extends StatelessWidget {
  const GirlsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Container(
              height: 200,
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.pink[100],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/categories/girls_collection.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.pink[100],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.girl,
                              size: 50,
                              color: Colors.pink[300],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Girls Collection',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.pink[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Categories Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Girls Categories',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 16),

            // Girls Categories Grid
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildCategoryCard('Frocks', 'assets/images/categories/girls_frocks.png'),
                  _buildCategoryCard('Tops', 'assets/images/categories/girls_tops.png'),
                  _buildCategoryCard('Skirts', 'assets/images/categories/girls_skirts.png'),
                  _buildCategoryCard('Leggings', 'assets/images/categories/girls_leggings.png'),
                  _buildCategoryCard('Dresses', 'assets/images/categories/girls_dresses.png'),
                  _buildCategoryCard('Ethnic Wear', 'assets/images/categories/girls_ethnic.png'),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Coming Soon Message
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.pink[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.pink[200]!),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.construction,
                    size: 40,
                    color: Colors.pink[600],
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Girls Collection Coming Soon!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink[700],
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'We are working hard to bring you the best girls collection.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, String imagePath) {
    return GestureDetector(
      onTap: () {
        Get.snackbar(
          'Coming Soon',
          '$title will be available soon!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.pink[100],
                        child: Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 30,
                            color: Colors.pink[300],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(12),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Infants View with AppBar
class InfantsView extends StatelessWidget {
  const InfantsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Container(
              height: 200,
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.orange[100],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/categories/infants_collection.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.orange[100],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.baby_changing_station,
                              size: 50,
                              color: Colors.orange[300],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Infants Collection',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Categories Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Infants Categories',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 16),

            // Infants Categories Grid
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildCategoryCard('Onesies', 'assets/images/categories/infants_onesies.png'),
                  _buildCategoryCard('Rompers', 'assets/images/categories/infants_rompers.png'),
                  _buildCategoryCard('Sleep Suits', 'assets/images/categories/infants_sleepsuits.png'),
                  _buildCategoryCard('Bibs', 'assets/images/categories/infants_bibs.png'),
                  _buildCategoryCard('Caps & Mittens', 'assets/images/categories/infants_accessories.png'),
                  _buildCategoryCard('Baby Sets', 'assets/images/categories/infants_sets.png'),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Coming Soon Message
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.construction,
                    size: 40,
                    color: Colors.orange[600],
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Infants Collection Coming Soon!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700],
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'We are working hard to bring you the best infants collection.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, String imagePath) {
    return GestureDetector(
      onTap: () {
        Get.snackbar(
          'Coming Soon',
          '$title will be available soon!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.orange[100],
                        child: Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 30,
                            color: Colors.orange[300],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(12),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}