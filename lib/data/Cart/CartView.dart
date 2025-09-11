import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'CartController.dart';

class CartView extends StatelessWidget {
  final CartController controller = Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
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
          'Cart',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(() => controller.cartItems.isNotEmpty
              ? Row(
            children: [
              if (controller.cartItems.length > 1)
                TextButton(
                  onPressed: () {
                    // Edit functionality
                  },
                  child: Text(
                    'Edits',
                    style: TextStyle(
                      color: Color(0xFF094D77),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              TextButton(
                onPressed: () {
                  Get.dialog(
                    AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: Text('Remove All'),
                      content: Text('Do You Really Want to Remove All Items from Cart?'),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            controller.clearCart();
                            Get.back();
                          },
                          child: Text(
                            'Remove all',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: Text(
                  'Remove all',
                  style: TextStyle(
                    color: Color(0xFF094D77),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          )
              : SizedBox()),
          SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (controller.cartItems.isEmpty) {
          return _buildEmptyCart();
        }

        return Column(
          children: [
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

                    SizedBox(height: 100), // Space for bottom section
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
                // Cart icon with plant
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(CartItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
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
        children: [
          // Product Header with close button
          Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 12, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.dialog(
                      AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Text('Do You Really Want to Remove'),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              controller.removeFromCart(item.id);
                              Get.back();
                            },
                            child: Text(
                              'Sure',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Icon(
                    Icons.close,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Container(
                  width: 80,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: AssetImage(item.imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: item.imagePath.isEmpty
                      ? Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 40,
                        color: Colors.grey[400],
                      ),
                    ),
                  )
                      : null,
                ),

                SizedBox(width: 16),

                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Color
                      if (item.selectedColor != null)
                        Row(
                          children: [
                            Text(
                              'Color: ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: item.selectedColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                            ),
                          ],
                        ),

                      SizedBox(height: 12),

                      // Size & Quantity
                      Text(
                        'Size & Quantity',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8),

                      // Size list (simulating multiple sizes)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('S: ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                              Text('12', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                            ],
                          ),
                          SizedBox(height: 2),
                          Row(
                            children: [
                              Text('M: ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                              Text('22', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                            ],
                          ),
                          SizedBox(height: 2),
                          Row(
                            children: [
                              Text('XL: ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                              Text('32', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                            ],
                          ),
                          SizedBox(height: 2),
                          Row(
                            children: [
                              Text('2XL: ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                              Text('11', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 12),

                      // Total Units
                      Text(
                        'Total Units: 67',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.toNamed('/checkout-review');
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
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 40,
                    child: OutlinedButton(
                      onPressed: () {
                        // View & Edit functionality
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Color(0xFF094D77)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'View & Edit',
                        style: TextStyle(
                          color: Color(0xFF094D77),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
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
            ),
          ),
          SizedBox(height: 16),

          Row(
            children: [
              Expanded(child: _buildSimilarItem('Purple & Gold Saree', '₹2,600')),
              SizedBox(width: 12),
              Expanded(child: _buildSimilarItem('Purple & Silver Saree', '₹3,600')),
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarItem(String name, String price) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.image, color: Colors.grey[600]),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF094D77),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.favorite_border, size: 12, color: Colors.red),
          ),
        ],
      ),
    );
  }
}