import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../views/home/homeScreen.dart';
import '../model/Women/WomenModel.dart';

// Cart Item interface
class CartItem {
  final String id;
  final String title;
  final String price;
  final String imagePath;
  final String? selectedSize;
  final Color? selectedColor;
  final String category;
  RxInt quantity;
  final WomenProduct? womenProduct;
  final Product? product;

  CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.imagePath,
    this.selectedSize,
    this.selectedColor,
    required this.category,
    int initialQuantity = 1,
    this.womenProduct,
    this.product,
  }) : quantity = initialQuantity.obs;

  double get totalPrice {
    double unitPrice = double.parse(price.replaceAll('₹', '').replaceAll(',', ''));
    return unitPrice * quantity.value;
  }
}

class CartController extends GetxController {
  var cartItems = <CartItem>[].obs;

  // Add WomenProduct to cart
  void addWomenProductToCart(WomenProduct product, String price, String size, Color color) {
    String itemId = '${product.id}_${size}_${color.value}';

    // Check if item already exists
    int existingIndex = cartItems.indexWhere((item) => item.id == itemId);

    if (existingIndex >= 0) {
      // Update quantity if item exists
      cartItems[existingIndex].quantity.value++;
      Get.snackbar(
        'Updated Cart',
        'Quantity updated for ${product.name}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Color(0xFF10B981),
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    } else {
      // Add new item
      CartItem newItem = CartItem(
        id: itemId,
        title: product.name,
        price: price,
        imagePath: product.image,
        selectedSize: size,
        selectedColor: color,
        category: product.category,
        womenProduct: product,
      );

      cartItems.add(newItem);
      Get.snackbar(
        'Added to Cart',
        '${product.name} added to your cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Color(0xFF10B981),
        colorText: Colors.white,
        duration: Duration(seconds: 2),
        mainButton: TextButton(
          onPressed: () => Get.toNamed('/cart'),
          child: Text(
            'View Cart',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }
  }

  // Add regular Product to cart
  void addProductToCart(Product product) {
    String itemId = product.title;

    // Check if item already exists
    int existingIndex = cartItems.indexWhere((item) => item.id == itemId);

    if (existingIndex >= 0) {
      // Update quantity if item exists
      cartItems[existingIndex].quantity.value++;
      Get.snackbar(
        'Updated Cart',
        'Quantity updated for ${product.title}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Color(0xFF10B981),
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    } else {
      // Add new item
      CartItem newItem = CartItem(
        id: itemId,
        title: product.title,
        price: product.price,
        imagePath: product.imagePath,
        category: 'general',
        product: product,
      );

      cartItems.add(newItem);
      Get.snackbar(
        'Added to Cart',
        '${product.title} added to your cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Color(0xFF10B981),
        colorText: Colors.white,
        duration: Duration(seconds: 2),
        mainButton: TextButton(
          onPressed: () => Get.toNamed('/cart'),
          child: Text(
            'View Cart',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }
  }

  // Remove item from cart
  void removeFromCart(String itemId) {
    cartItems.removeWhere((item) => item.id == itemId);
    Get.snackbar(
      'Removed from Cart',
      'Item removed from your cart',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red[400],
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

  // Update item quantity
  void updateQuantity(String itemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(itemId);
      return;
    }

    int index = cartItems.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      cartItems[index].quantity.value = newQuantity;
    }
  }

  // Clear all items
  void clearCart() {
    cartItems.clear();
    Get.snackbar(
      'Cart Cleared',
      'All items removed from cart',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange[400],
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

  // Get total items count
  int get totalItems {
    return cartItems.fold(0, (sum, item) => sum + item.quantity.value);
  }

  // Get total price
  double get totalPrice {
    return cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // Get subtotal (before taxes/shipping)
  double get subtotal => totalPrice;

  // Get shipping cost
  double get shippingCost => totalPrice > 999 ? 0 : 50;

  // Get tax amount (assuming 18% GST)
  double get taxAmount => subtotal * 0.18;

  // Get final total
  double get finalTotal => subtotal + shippingCost + taxAmount;
}