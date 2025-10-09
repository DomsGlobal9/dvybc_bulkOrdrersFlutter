import 'package:flutter/material.dart';
import 'package:flutter_dvybc/data/views/home/homeScreen.dart';
import 'package:get/get.dart';
import '../../views/Widgets/CustomDVYBAppBarWithBack.dart';
import '../../views/home/CustomAppBar.dart';
import 'CartController.dart';

class CartView extends StatelessWidget {
  final CartController controller = Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomDVYBAppBar(),
      body: Obx(() {
        if (controller.cartItems.isEmpty) {
          return _buildEmptyCart();
        }

        return Column(
          children: [
            // Header with back button and "Cart" title and "Edits" button
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Get.back(),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Cart',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Edits',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.edit_outlined, color: Colors.black87, size: 18),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Cart Items
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.all(16),
                      itemCount: controller.cartItems.length,
                      itemBuilder: (context, index) {
                        return _buildCartItemCard(controller.cartItems[index]);
                      },
                    ),

                    // Similar to Your Cart Section
                    if (controller.cartItems.isNotEmpty) _buildSimilarSection(),

                    SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(40),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                    ),
                    Column(
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 8),
                        Icon(
                          Icons.eco_outlined,
                          size: 30,
                          color: Colors.green[400],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "It Seems Like You Didn't Find Any Of Your Favourite Choice ?",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                height: 1.4,
                fontFamily: 'Outfit',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 16),
          Text(
            "Let's Find Your Vibe",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontFamily: 'Outfit',
            ),
          ),
          SizedBox(height: 32),
          Container(
            width: 160,
            height: 45,
            child: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF094D77),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Explore',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Outfit',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(CartItem item) {
    // Calculate total units dynamically
    int totalUnits = item.quantity.value;

    // Get dynamic image URL
    String imageUrl = item.womenProduct?.image ?? item.imagePath;

    return Container(
      width: 358,
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFEAF7FF),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image (leading) - Dynamic
          Container(
            width: 140,
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                imageUrl,
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
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              )
                  : Container(
                color: Colors.grey[200],
                child: Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 40,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ),
          ),

          SizedBox(width: 16),

          // Product Details (trailing)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Close button at top right
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          fontFamily: 'Outfit',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.dialog(
                          AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: Text(
                              'Do You Really Want to Remove',
                              style: TextStyle(fontFamily: 'Outfit'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(fontFamily: 'Outfit'),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  controller.removeFromCart(item.id);
                                  Get.back();
                                },
                                child: Text(
                                  'Sure',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontFamily: 'Outfit',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.black,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12),

                // Color with rounded badge - Dynamic
                if (item.selectedColor != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(45),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Color:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontFamily: 'Outfit',
                          ),
                        ),
                        SizedBox(width: 6),
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: item.selectedColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey[400]!),
                          ),
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: 12),

                // Size & Quantity label
                Text(
                  'Size & Quantity',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Outfit',
                  ),
                ),

                SizedBox(height: 8),

                // Size table with borders - Dynamic based on selected sizes
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    children: _buildSizeRows(item),
                  ),
                ),

                SizedBox(height: 12),

                // Total Units - Dynamic
                Text(
                  'Total Units: $totalUnits',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontFamily: 'Outfit',
                  ),
                ),

                SizedBox(height: 12),

                // Proceed to Pay button
                Container(
                  width: 160,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.toNamed('/checkout-review');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF094D77),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: Color(0xFF094D77),
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: Text(
                      'Proceed to Pay',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Outfit',
                      ),
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

  // Build dynamic size rows based on selected sizes
  List<Widget> _buildSizeRows(CartItem item) {
    List<Widget> rows = [];

    // Get sizes from WomenProduct if available
    List<String> sizes = item.womenProduct?.selectedSizes ?? ['S', 'M', 'L', 'XL'];

    for (int i = 0; i < sizes.length; i++) {
      String size = sizes[i];
      // Calculate dynamic quantity (you can customize this logic)
      int quantity = (item.quantity.value ~/ sizes.length) + (i < item.quantity.value % sizes.length ? 1 : 0);

      rows.add(
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: i < sizes.length - 1
                ? Border(bottom: BorderSide(color: Colors.grey[400]!))
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$size :',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  fontFamily: 'Outfit',
                ),
              ),
              Text(
                '$quantity',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                  fontFamily: 'Outfit',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return rows;
  }

  Widget _buildSimilarSection() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Similar to Your Cart:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              fontFamily: 'Outfit',
            ),
          ),
          SizedBox(height: 16),

          Row(
            children: [
              Expanded(child: _buildSimilarItem('Purple & Gold Saree', '₹2,600', 'https://example.com/image1.jpg')),
              SizedBox(width: 12),
              Expanded(child: _buildSimilarItem('Purple & Silver Saree', '₹3,600', 'https://example.com/image2.jpg')),
            ],
          ),

          SizedBox(height: 16),

          Container(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: () {
                // Proceed to pay for similar items
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF094D77),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Proceed to Pay',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Outfit',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarItem(String name, String price, String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 150,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Center(
                          child: Icon(Icons.image, color: Colors.grey[600], size: 40),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.favorite_border, size: 16, color: Colors.red),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Outfit',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF094D77),
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Outfit',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}