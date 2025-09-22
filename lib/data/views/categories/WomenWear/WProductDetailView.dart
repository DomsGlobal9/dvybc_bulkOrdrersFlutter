// Updated ProductDetailView.dart with filter integration
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../model/Women/WomenModel.dart';
import '../../../viewModel/Women/ProductDetailViewModel.dart';

class ProductDetailView extends StatelessWidget {
  const ProductDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ProductDetailController controller = Get.put(ProductDetailController());
    final String productName = Get.arguments['productName'] ?? '';
    final String category = Get.arguments['category'] ?? '';

    // Load products when view is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadProductVariations(productName, category);
    });

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildCustomAppBar(productName),
      body: Obx(() => controller.isLoading.value
          ? Center(child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
      ))
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color(0xFF3B82F6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                      ),
                      // Active Filters Indicator
                      Obx(() => controller.activeFilterCount.value > 0
                          ? Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${controller.activeFilterCount.value} Filter${controller.activeFilterCount.value > 1 ? 's' : ''} Active',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      )
                          : SizedBox.shrink()),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    productName,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Explore ${controller.filteredProducts.length} beautiful variations',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Filter Section
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 45,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search variations...',
                          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onChanged: (value) => controller.searchProducts(value),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  // Enhanced Filter Button
                  Obx(() => GestureDetector(
                    onTap: () => controller.openFilterModal(),
                    child: Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                        color: controller.activeFilterCount.value > 0
                            ? Color(0xFF3B82F6)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: controller.activeFilterCount.value > 0
                              ? Color(0xFF3B82F6)
                              : Colors.grey[300]!,
                        ),
                        boxShadow: controller.activeFilterCount.value > 0
                            ? [
                          BoxShadow(
                            color: Color(0xFF3B82F6).withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ]
                            : null,
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Icon(
                              Icons.tune,
                              color: controller.activeFilterCount.value > 0
                                  ? Colors.white
                                  : Color(0xFF3B82F6),
                              size: 20,
                            ),
                          ),
                          if (controller.activeFilterCount.value > 0)
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    controller.activeFilterCount.value.toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            ),

            SizedBox(height: 12),

            // Clear Filters Button (shown when filters are active)
            Obx(() => controller.activeFilterCount.value > 0
                ? Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: () => controller.clearAllFilters(),
                    icon: Icon(Icons.clear, size: 16, color: Colors.red),
                    label: Text(
                      'Clear All Filters',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.1),
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  Spacer(),
                  Text(
                    'Showing ${controller.filteredProducts.length} products',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
                : SizedBox.shrink()),

            SizedBox(height: 20),

            // Products Grid
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: controller.filteredProducts.isEmpty
                  ? _buildEmptyState()
                  : GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemCount: controller.filteredProducts.length,
                itemBuilder: (context, index) {
                  return _buildProductCard(controller.filteredProducts[index]);
                },
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      )),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[300],
          ),
          SizedBox(height: 16),
          Text(
            'No products found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search terms',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Get.find<ProductDetailController>().clearAllFilters(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF3B82F6),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              'Clear Filters',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar(String productName) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.black87,
            size: 18,
          ),
        ),
        onPressed: () => Get.back(),
      ),
      title: Text(
        productName,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.favorite_border,
              color: Colors.black87,
              size: 20,
            ),
          ),
          onPressed: () {
            // Add to favorites
          },
        ),
        IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.share,
              color: Colors.black87,
              size: 20,
            ),
          ),
          onPressed: () {
            // Share functionality
          },
        ),
        SizedBox(width: 8),
      ],
    );
  }

  Widget _buildProductCard(WomenProduct product) {
    return GestureDetector(
      onTap: () {
        Get.toNamed('/product-single', arguments: {
          'product': product,
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              child: Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      // ==========================================================
                      // THE ONLY CHANGE IS HERE: Image.asset -> Image.network
                      // ==========================================================
                      child: product.image.isNotEmpty
                          ? Image.network(
                        product.image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: Icon(Icons.broken_image, size: 40, color: Colors.grey[400]),
                            ),
                          );
                        },
                      )
                          : Container( // Fallback for empty URL
                        color: Colors.grey[200],
                        child: Center(
                          child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey[400]),
                        ),
                      ),
                    ),
                    // Favorite Button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.favorite_border,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    // New/Trending Badge
                    if (product.id.hashCode % 3 == 0)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'NEW',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Product Details
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    product.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Free Size',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Color(0xFF3B82F6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
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