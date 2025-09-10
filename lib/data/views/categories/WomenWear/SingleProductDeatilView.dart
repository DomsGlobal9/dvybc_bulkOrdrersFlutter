import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Controllers/FavoritesController.dart';
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
    final WomenProduct product = Get.arguments['product'];

    // Initialize the controller with the product
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initializeProduct(product);
    });

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Obx(() => CustomScrollView(
        slivers: [
          // Custom App Bar
          SliverAppBar(
            expandedHeight: 400,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.black87, size: 18),
                onPressed: () => Get.back(),
              ),
            ),
            actions: [
              Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                      controller.isFavorite.value ? Icons.favorite : Icons.favorite_border,
                      color: controller.isFavorite.value ? Colors.red : Colors.black87,
                      size: 20
                  ),
                  onPressed: () {
                    controller.toggleFavorite();
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(Icons.share, color: Colors.black87, size: 20),
                  onPressed: () {
                    // Share functionality
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product-${product.id}',
                child: Container(
                  child: Image.asset(
                    product.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_outlined, size: 80, color: Colors.grey[400]),
                              SizedBox(height: 16),
                              Text(
                                product.name,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
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
              ),
            ),
          ),

          // Product Details
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
                  // Product Name and Category
                  Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Color(0xFF10B981).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                product.category.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ),
                            Spacer(),
                            Row(
                              children: List.generate(5, (index) => Icon(
                                Icons.star,
                                size: 16,
                                color: index < 4 ? Colors.amber : Colors.grey[300],
                              )),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '4.5 (129)',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text(
                          product.name,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          product.description,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              '₹${controller.getRandomPrice()}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF10B981),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              '₹${controller.getRandomOriginalPrice()}',
                              style: TextStyle(
                                fontSize: 18,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey[500],
                              ),
                            ),
                            SizedBox(width: 12),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Color(0xFFEF4444).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${controller.getDiscount()}% OFF',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFEF4444),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Color Options
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Colors Available',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: controller.availableColors.map((color) {
                            bool isSelected = controller.selectedColor.value == color;
                            return Container(
                              margin: EdgeInsets.only(right: 12),
                              child: GestureDetector(
                                onTap: () => controller.selectColor(color),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected ? Colors.black87 : Colors.grey[300]!,
                                      width: isSelected ? 3 : 1,
                                    ),
                                  ),
                                  child: isSelected
                                      ? Icon(Icons.check, color: Colors.white, size: 20)
                                      : null,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 32),
                      ],
                    ),
                  ),

                  // Size Selection with Size Guide
                  _buildSizeSelectionWithGuide(context, controller, product),

                  // Features
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Features',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildFeatureItem(Icons.local_shipping, 'Free Delivery', 'On orders above ₹999'),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _buildFeatureItem(Icons.autorenew, 'Easy Returns', '7-day return policy'),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildFeatureItem(Icons.support_agent, '24/7 Support', 'Customer support'),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _buildFeatureItem(Icons.verified, 'Authentic', '100% genuine products'),
                            ),
                          ],
                        ),
                        SizedBox(height: 32),
                      ],
                    ),
                  ),

                  // Similar Products
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Similar Products',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 16),
                        Container(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: controller.similarProducts.length,
                            itemBuilder: (context, index) {
                              return Container(
                                width: 140,
                                margin: EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                        child: Image.asset(
                                          controller.similarProducts[index].image,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[200],
                                              child: Center(
                                                child: Icon(Icons.image_outlined,
                                                    size: 30, color: Colors.grey[400]),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            controller.similarProducts[index].name,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            '₹${(index + 1) * 299}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF10B981),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 100), // Space for bottom buttons
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      )),

      // Bottom Action Bar
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Add to Cart Button
            Expanded(
              child: Container(
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    controller.addToCart();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Color(0xFF187DBD),
                    side: BorderSide(color: Color(0xFF187DBD)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Add to Cart',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.shopping_cart, size: 20),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            // Buy Now Button
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    controller.buyNow();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF187DBD),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'BUY NOW',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeSelectionWithGuide(BuildContext context, SingleProductController controller, WomenProduct product) {
    if (product.name.toLowerCase().contains('saree')) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF10B981).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF10B981)),
              SizedBox(width: 12),
              Text(
                'Free Size - One size fits all',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Size Available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () => _showSizeGuideModal(context),
                child: Text(
                  'Size Guide',
                  style: TextStyle(
                    color: Color(0xFF187DBD),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: controller.availableSizes.map((size) {
              bool isSelected = controller.selectedSize.value == size;
              return GestureDetector(
                onTap: () => controller.selectSize(size),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Color(0xFF187DBD) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Color(0xFF3B82F6) : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    size,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: Color(0xFF3B82F6)),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

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
                SizedBox(width: 48), // Balance the close button
              ],
            ),
          ),
          // Product info
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/measure.png',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[200],
                        child: Icon(Icons.image_outlined, color: Colors.grey[400]),
                      );
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Yellow Kurti',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Brand Name • Everyday Comfort',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          // Tabs
          TabBar(
            controller: _tabController,
            indicatorColor: Color(0xFF187DBD),   // Color of the underline
            indicatorWeight: 2.0,                 // Thickness of the underline
            indicatorSize: TabBarIndicatorSize.tab,  // Make underline full tab width
            labelColor: Color(0xFF187DBD),        // Selected label text color
            unselectedLabelColor: Colors.grey[600],  // Unselected text color
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
          // Measurement diagram
          Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              'assets/images/measure.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Center(
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
                );
              },
            ),
          ),
          SizedBox(height: 20),

          // Measurement instructions
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
          SizedBox(height: 20),

          // Measurement details
          _buildMeasurementItem('Shoulders', 'Measure horizontally across the back from the tip of one shoulder to the other.'),
          _buildMeasurementItem('Bust/Chest', 'Measure around the fullest part of your chest, keeping the tape measure parallel to the floor.'),
          _buildMeasurementItem('Waist', 'Measure around your natural waistline, keeping the tape comfortably loose.'),
          _buildMeasurementItem('Hips', 'With feet together, measure around the fullest part of your hips.'),
          _buildMeasurementItem('Sleeve Length', 'Measure from the shoulder seam to the end of the wrist bone.'),
        ],
      ),
    );
  }

  Widget _buildMeasurementItem(String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
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
            'Find your perfect fit using the measurements below. All measurements are in ${isInches ? 'inches' : 'centimeters'}.',
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