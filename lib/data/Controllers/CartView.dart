import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controllers/CartController.dart';

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
                    color: Color(0xFF1976D2),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Edit button (if needed)
              IconButton(
                icon: Icon(Icons.edit, color: Colors.grey[600]),
                onPressed: () {
                  // Edit functionality
                },
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

                    // Similar to your cart section (if needed)
                    if (controller.cartItems.isNotEmpty) _buildSimilarSection(),

                    SizedBox(height: 100), // Space for bottom section
                  ],
                ),
              ),
            ),

            // Bottom Price Section
            _buildBottomPriceSection(),
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
          // Cart illustration
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Column(
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16),
                Icon(
                  Icons.eco_outlined,
                  size: 40,
                  color: Colors.green[400],
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          Text(
            "It Seems Like You Didn't Find Any Of Your Favourite Choice ?",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            "Let's Find Your Vibe",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 32),
          Container(
            width: 200,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1976D2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                'Explore',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
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
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              width: 80,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage(item.imagePath),
                  fit: BoxFit.cover,
                ),
              ),
              child: item.imagePath.isEmpty
                  ? Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
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

                  SizedBox(height: 8),

                  // Color and Size
                  if (item.selectedColor != null || item.selectedSize != null)
                    Row(
                      children: [
                        if (item.selectedColor != null) ...[
                          Text('Color: ', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: item.selectedColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                          ),
                          SizedBox(width: 16),
                        ],
                        if (item.selectedSize != null) ...[
                          Text(
                            'Size & Quantity: ',
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                          Text(
                            '${item.selectedSize}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),

                  SizedBox(height: 12),

                  // Price and Quantity Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${item.price}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1976D2),
                        ),
                      ),

                      // Quantity Controls
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (item.quantity.value > 1) {
                                controller.updateQuantity(item.id, item.quantity.value - 1);
                              }
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.remove, size: 20),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 12),
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            child: Obx(() => Text(
                              '${item.quantity.value}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            )),
                          ),
                          GestureDetector(
                            onTap: () {
                              controller.updateQuantity(item.id, item.quantity.value + 1);
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Color(0xFF1976D2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.add, size: 20, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Total Units if needed
                  SizedBox(height: 8),
                  Obx(() => Text(
                    'Total Units: ${item.quantity.value}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimilarSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          SizedBox(height: 12),
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
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                // Proceed to pay for similar items
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1976D2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
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
                    color: Color(0xFF1976D2),
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

  Widget _buildBottomPriceSection() {
    return Container(
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
      child: Obx(() {
        if (controller.cartItems.isEmpty) return SizedBox.shrink();

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Price breakdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal:', style: TextStyle(fontSize: 16)),
                Text('₹${controller.subtotal.toStringAsFixed(0)}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Shipping:', style: TextStyle(fontSize: 16)),
                Text(
                  controller.shippingCost == 0 ? 'Free' : '₹${controller.shippingCost.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: controller.shippingCost == 0 ? Colors.green : Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tax (18%):', style: TextStyle(fontSize: 16)),
                Text('₹${controller.taxAmount.toStringAsFixed(0)}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
            Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '₹${controller.finalTotal.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Proceed to Pay button
            Container(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Proceed to checkout
                  Get.toNamed('/checkout');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1976D2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  'Proceed to Pay',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}