import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../model/Women/WomenModel.dart';
import '../../../viewModel/Women/SingleProductViewModel.dart';

class SingleProductView extends StatelessWidget {
  const SingleProductView({Key? key}) : super(key: key);

  void _showSizeGuideModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizeGuideModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final SingleProductController controller = Get.put(SingleProductController());
    final RxBool isDescriptionExpanded = false.obs;
    final RxBool isReviewsExpanded = false.obs;
    final RxInt currentImageIndex = 0.obs; // Track current image index
    final PageController pageController = PageController(); // For image swiping

    // Add null safety check
    final arguments = Get.arguments;
    if (arguments == null || arguments['product'] == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Product data not found'),
              ElevatedButton(
                onPressed: () => Get.back(),
                child: Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final WomenProduct product = arguments['product'];

    // Initialize the controller with the product
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initializeProduct(product);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Enhanced product image section with swipe functionality
              SliverToBoxAdapter(
                child: Container(
                  height: 500,
                  child: Row(
                    children: [
                      // Main product image with swipe functionality
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(top: 40, left: 16, bottom: 20),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              children: [
                                // Swipeable images
                                PageView.builder(
                                  controller: pageController,
                                  onPageChanged: (index) {
                                    currentImageIndex.value = index;
                                  },
                                  itemCount: product.imageUrls?.isNotEmpty == true
                                      ? product.imageUrls!.length
                                      : 1,
                                  itemBuilder: (context, index) {
                                    String imageUrl = product.imageUrls?.isNotEmpty == true
                                        ? product.imageUrls![index]
                                        : product.image;

                                    return Hero(
                                      tag: 'product-${product.id}-$index',
                                      child: Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey[800],
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.image_outlined,
                                                      size: 80,
                                                      color: Colors.grey[600]),
                                                  SizedBox(height: 16),
                                                  Text(
                                                    product.name,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.grey[400],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),

                                // Image indicator dots
                                if (product.imageUrls?.isNotEmpty == true && product.imageUrls!.length > 1)
                                  Positioned(
                                    bottom: 16,
                                    left: 0,
                                    right: 0,
                                    child: Obx(() => Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(
                                        product.imageUrls!.length,
                                            (index) => Container(
                                          margin: EdgeInsets.symmetric(horizontal: 4),
                                          width: currentImageIndex.value == index ? 12 : 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: currentImageIndex.value == index
                                                ? Colors.white
                                                : Colors.white.withOpacity(0.5),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                      ),
                                    )),
                                  ),

                                // Image counter
                                if (product.imageUrls?.isNotEmpty == true && product.imageUrls!.length > 1)
                                  Positioned(
                                    top: 16,
                                    right: 16,
                                    child: Obx(() => Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${currentImageIndex.value + 1}/${product.imageUrls!.length}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    )),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Enhanced side thumbnail images
                      Container(
                        width: 60,
                        child: Column(
                          children: [
                            SizedBox(height: 60),
                            if (product.imageUrls?.isNotEmpty == true)
                              ...List.generate(
                                product.imageUrls!.length > 6 ? 6 : product.imageUrls!.length,
                                    (index) => GestureDetector(
                                  onTap: () {
                                    currentImageIndex.value = index;
                                    pageController.animateToPage(
                                      index,
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  child: Obx(() => Container(
                                    margin: EdgeInsets.only(bottom: 8, right: 8),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        width: 50,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          border: currentImageIndex.value == index
                                              ? Border.all(color: Color(0xFF187DBD), width: 2)
                                              : Border.all(color: Colors.grey[300]!, width: 1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Image.network(
                                          product.imageUrls![index],
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[200],
                                              child: Icon(Icons.image,
                                                  color: Colors.grey[400],
                                                  size: 20),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  )),
                                ),
                              )
                            else
                            // Show single placeholder if no multiple images
                              Container(
                                margin: EdgeInsets.only(bottom: 8, right: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    width: 50,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Color(0xFF187DBD), width: 2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Image.network(
                                      product.image,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[200],
                                          child: Icon(Icons.image,
                                              color: Colors.grey[400],
                                              size: 20),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Product Details in white container
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product info with share button and virtual try-on
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    product.name,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    icon: Icon(Icons.share, color: Colors.black),
                                    onPressed: () {
                                      // Your existing share functionality
                                      Get.snackbar(
                                        'Share',
                                        'Share functionality to be implemented',
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),

                            // Virtual Try-On Button - positioned right below share button area
                            Container(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  String imageUrl = '';
                                  if (product.imageUrls?.isNotEmpty == true) {
                                    imageUrl = product.imageUrls!.first;
                                  } else if (product.image.isNotEmpty) {
                                    imageUrl = product.image;
                                  }

                                  if (imageUrl.isNotEmpty) {
                                    Get.toNamed('/virtual-tryon', arguments: {
                                      'garmentImageUrl': imageUrl,
                                      'productName': product.name,
                                    });
                                  } else {
                                    Get.snackbar(
                                      'Image Not Available',
                                      'No product image available for virtual try-on',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.orange,
                                      colorText: Colors.white,
                                    );
                                  }
                                },
                                icon: Icon(Icons.auto_fix_high, size: 20),
                                label: Text('Virtual Try-On'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Color(0xFF187DBD),
                                  side: BorderSide(color: Color(0xFF187DBD), width: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 8),

                            // Show total images info
                            if (product.imageUrls?.isNotEmpty == true && product.imageUrls!.length > 1)
                              Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text(
                                  '${product.imageUrls!.length} images available',
                                  style: TextStyle(
                                    color: Color(0xFF187DBD),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),

                            Row(
                              children: [
                                Text(
                                  '₹${product.price ?? "2,250"}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF187DBD),
                                  ),
                                ),
                                Text('/Piece', style: TextStyle(color: Colors.grey[600])),
                                SizedBox(width: 16),
                                Text(
                                  '(55% OFF)',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  'M.R.P ₹5,000',
                                  style: TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tax included. Shipping calculated at checkout.',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Colors Available - Square shapes
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Colors Available',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 12),
                            Obx(() => Row(
                              children: [
                                _buildColorOption(Colors.black, controller.selectedColor.value == Colors.black, controller),
                                SizedBox(width: 12),
                                _buildColorOption(Color(0xFFFFC0CB), controller.selectedColor.value == Color(0xFFFFC0CB), controller),
                                SizedBox(width: 12),
                                _buildColorOption(Color(0xFF8B0000), controller.selectedColor.value == Color(0xFF8B0000), controller),
                                SizedBox(width: 12),
                                _buildColorOption(Color(0xFF0D5D2E), controller.selectedColor.value == Color(0xFF0D5D2E), controller),
                              ],
                            )),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),

                      // Size Selection with Size Guide button
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Selected Size',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                GestureDetector(
                                    onTap: () => _showSizeGuideModal(context),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Size Guide',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF187DBD),
                                            decoration: TextDecoration.none, // remove default underline
                                          ),
                                        ),
                                        SizedBox(height: 2), // gap between text and underline
                                        Container(
                                          height: 1,
                                          width: 65, // match text width or use double.infinity
                                          color: Color(0xFF187DBD),
                                        ),
                                      ],
                                    )
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Obx(() => Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: controller.availableSizes.map((size) {
                                bool isSelected = controller.selectedSizes.contains(size);
                                int? quantity = controller.selectedSizeQuantities[size];

                                return _buildSizeOption(size, isSelected, controller, quantity);
                              }).toList(),
                            )),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),

                      // Action Buttons
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 48,
                                child: OutlinedButton.icon(
                                  onPressed: () => controller.addToCart(),
                                  icon: Icon(Icons.shopping_cart_outlined, size: 20),
                                  label: Text('Add to cart'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Color(0xFF187DBD),
                                    side: BorderSide(color: Color(0xFF187DBD)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () => controller.buyNow(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF187DBD),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'BUY NOW',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),

                      // Description with simple dropdown
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () => isDescriptionExpanded.toggle(),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Description',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Obx(() => Icon(
                                    isDescriptionExpanded.value
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                  )),
                                ],
                              ),
                            ),
                            Obx(() => isDescriptionExpanded.value
                                ? Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                product.description.isNotEmpty
                                    ? product.description
                                    : 'A beautiful ${product.name} featuring elegant design and premium quality. Perfect for special occasions and everyday wear.',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            )
                                : SizedBox()),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),

                      // Features with icons
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(child: _buildFeatureIcon(Icons.verified_user, '100% Secure\nPayment')),
                            Expanded(child: _buildFeatureIcon(Icons.autorenew, 'Easy Return & Quick\nRefund')),
                            Expanded(child: _buildFeatureIcon(Icons.headset_mic, 'Dedicated\nSupport')),
                          ],
                        ),
                      ),
                      SizedBox(height: 32),

                      // Similar Products (using controller's similar products)
                      Obx(() => controller.similarProducts.isNotEmpty
                          ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Similar Products',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 16),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 0.8,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                              ),
                              itemCount: controller.similarProducts.length > 6
                                  ? 6
                                  : controller.similarProducts.length,
                              itemBuilder: (context, index) {
                                final similarProduct = controller.similarProducts[index];
                                return _buildSimilarProductNew(similarProduct);
                              },
                            ),
                          ],
                        ),
                      )
                          : SizedBox.shrink()),

                      SizedBox(height: 32),

                      // Reviews Section with simple dropdown
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () => isReviewsExpanded.toggle(),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Reviews',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Obx(() => Icon(
                                    isReviewsExpanded.value
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                  )),
                                ],
                              ),
                            ),
                            Obx(() => isReviewsExpanded.value
                                ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 16),
                                Row(
                                  children: [
                                    Text(
                                      '4.9',
                                      style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('OUT OF 5', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                        Row(
                                          children: List.generate(5, (index) => Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                            size: 16,
                                          )),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),

                                // Rating bars with dark green color
                                ...List.generate(5, (index) {
                                  List<String> percentages = ['80%', '15%', '3%', '1%', '0%'];
                                  List<double> widthFactors = [0.8, 0.15, 0.03, 0.01, 0.0];
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        Text('${5-index}'),
                                        SizedBox(width: 8),
                                        Icon(Icons.star, size: 16, color: Colors.grey[400]),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Container(
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius: BorderRadius.circular(3),
                                            ),
                                            child: FractionallySizedBox(
                                              alignment: Alignment.centerLeft,
                                              widthFactor: widthFactors[index],
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF10B981),
                                                  borderRadius: BorderRadius.circular(3),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text(percentages[index], style: TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                  );
                                }),
                                SizedBox(height: 16),

                                Text(
                                  '47 Reviews',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 16),
                                _buildReview('Jennifer Rose', 5, 'Stunning colors and high-quality fabric.'),
                                SizedBox(height: 12),
                                _buildReview('Kelly Rihanna', 5, 'Chic design with lavish texture.'),
                              ],
                            )
                                : SizedBox()),
                            SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Top navigation - only back button
          Positioned(
            top: 40,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () => Get.back(),
              ),
            ),
          ),

          // Heart icon - positioned on main image
          Positioned(
            top: 60,
            left: 30,
            child: Obx(() => Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  controller.isFavorite.value ? Icons.favorite : Icons.favorite_border,
                  color: controller.isFavorite.value ? Colors.red : Colors.grey[600],
                  size: 18,
                ),
                onPressed: () => controller.toggleFavorite(),
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildColorOption(Color color, bool isSelected, SingleProductController controller) {
    return GestureDetector(
      onTap: () => controller.selectColor(color),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          border: isSelected ? Border.all(color: Color(0xFF187DBD), width: 2) : Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: isSelected ? Center(
          child: Icon(
            Icons.check,
            color: color == Colors.black || color == Color(0xFF0D5D2E) ? Colors.white : Colors.black,
            size: 16,
          ),
        ) : null,
      ),
    );
  }

  Widget _buildSizeOption(String size, bool isSelected, SingleProductController controller, int? quantity) {
    return GestureDetector(
      onTap: () => controller.selectSize(size),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF187DBD) : Colors.grey[100],
          borderRadius: BorderRadius.circular(6),
          border: isSelected ? Border.all(color: Color(0xFF187DBD), width: 2) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              size,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isSelected && quantity != null && quantity > 0) ...[
              SizedBox(width: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  quantity.toString(),
                  style: TextStyle(
                    color: Color(0xFF187DBD),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureIcon(IconData icon, String text) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Color(0xFF187DBD).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Color(0xFF187DBD), size: 24),
        ),
        SizedBox(height: 8),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildSimilarProductNew(WomenProduct product) {
    return GestureDetector(
      onTap: () {
        Get.toNamed('/product-single', arguments: {
          'product': product,
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              child: Container(
                margin: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.imageUrls?.isNotEmpty == true
                            ? product.imageUrls!.first
                            : product.image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image_outlined,
                                      size: 30,
                                      color: Colors.grey[400]),
                                  SizedBox(height: 4),
                                  Text(
                                    product.name,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Multi-image indicator
                    if (product.imageUrls?.isNotEmpty == true && product.imageUrls!.length > 1)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.collections,
                                size: 8,
                                color: Colors.white,
                              ),
                              SizedBox(width: 2),
                              Text(
                                '${product.imageUrls!.length}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Product Details
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '₹${product.price ?? ((product.id.hashCode % 3000) + 500)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF187DBD),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReview(String name, int rating, String review) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: Text(name[0], style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Row(
                    children: List.generate(5, (index) => Icon(
                      Icons.star,
                      size: 14,
                      color: index < rating ? Colors.amber : Colors.grey[300],
                    )),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 6),
        Text(
          review,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

// Size Guide Modal remains the same as in your original code
class SizeGuideModal extends StatefulWidget {
  @override
  _SizeGuideModalState createState() => _SizeGuideModalState();
}

class _SizeGuideModalState extends State<SizeGuideModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isInches = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.close, color: Colors.black87),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    'Size Guide',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(width: 48),
              ],
            ),
          ),
          // Tabs
          TabBar(
            controller: _tabController,
            indicatorColor: Color(0xFF187DBD),
            indicatorWeight: 2.0,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Color(0xFF187DBD),
            unselectedLabelColor: Colors.grey[600],
            labelStyle: TextStyle(fontWeight: FontWeight.w600),
            tabs: [
              Tab(text: 'How to Measure'),
              Tab(text: 'Size Chart'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildHowToMeasureTab(),
                _buildSizeChartTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowToMeasureTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.straighten, size: 60, color: Colors.grey[400]),
                  SizedBox(height: 8),
                  Text(
                    'Measurement Guide',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF187DBD).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF187DBD)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'These measurements represent your body\'s unique dimensions. Use them with our size chart to find your perfect fit.',
                    style: TextStyle(
                      color: Color(0xFF187DBD),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeChartTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Size Chart',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Find your perfect fit using the measurements below.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 20),

          // Unit toggle
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => setState(() => isInches = true),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isInches ? Color(0xFF187DBD) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'inches',
                      style: TextStyle(
                        color: isInches ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => isInches = false),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: !isInches ? Color(0xFF187DBD) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'centimeters',
                      style: TextStyle(
                        color: !isInches ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Size chart table
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Header row
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text('Size', style: TextStyle(fontWeight: FontWeight.w600))),
                      Expanded(child: Text('Bust', style: TextStyle(fontWeight: FontWeight.w600))),
                      Expanded(child: Text('Waist', style: TextStyle(fontWeight: FontWeight.w600))),
                      Expanded(child: Text('Hips', style: TextStyle(fontWeight: FontWeight.w600))),
                      Expanded(child: Text('Shoulders', style: TextStyle(fontWeight: FontWeight.w600))),
                    ],
                  ),
                ),
                // Data rows
                if (isInches) ...[
                  _buildSizeRow('XS', '31.9', '25.2', '35.0', '14.0'),
                  _buildSizeRow('S', '33.9', '27.2', '37.0', '14.5'),
                  _buildSizeRow('M', '35.8', '29.1', '39.0', '15.0'),
                  _buildSizeRow('L', '38.2', '31.1', '40.9', '15.4'),
                  _buildSizeRow('XL', '40.2', '33.1', '42.9', '16.0'),
                  _buildSizeRow('2XL', '42.1', '35.0', '44.9', '16.5'),
                ] else ...[
                  _buildSizeRow('XS', '81', '64', '89', '35.6'),
                  _buildSizeRow('S', '86', '69', '94', '36.8'),
                  _buildSizeRow('M', '91', '74', '99', '38.1'),
                  _buildSizeRow('L', '97', '79', '104', '39.4'),
                  _buildSizeRow('XL', '102', '84', '109', '40.6'),
                  _buildSizeRow('2XL', '107', '89', '114', '41.9'),
                ],
              ],
            ),
          ),
          SizedBox(height: 20),

          // How to use chart
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How to use this chart',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Take your body measurements and compare them to the chart above. If your measurements fall between sizes, we recommend choosing the larger size for a more comfortable fit.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeRow(String size, String bust, String waist, String hips, String shoulders) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: Text(size, style: TextStyle(fontWeight: FontWeight.w500))),
          Expanded(child: Text(bust)),
          Expanded(child: Text(waist)),
          Expanded(child: Text(hips)),
          Expanded(child: Text(shoulders)),
        ],
      ),
    );
  }
}