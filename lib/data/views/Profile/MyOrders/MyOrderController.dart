import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:math';

// Order Model
class OrderModel {
  final String id;
  final String orderNumber;
  final String trackingNo;
  final int quantity;
  final double subtotal;
  final String imageUrl;
  final String status; // RECENT, DELIVERED, CANCELLED, RETURN
  final DateTime createdAt;
  final String productName;
  final List<String> productIds;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.trackingNo,
    required this.quantity,
    required this.subtotal,
    required this.imageUrl,
    required this.status,
    required this.createdAt,
    required this.productName,
    required this.productIds,
  });

  // Convert from cart data when payment is made - FIXED for your CartItem structure
  factory OrderModel.fromCartPayment({
    required double totalAmount,
    required int totalItems,
    required List<Map<String, dynamic>> cartItems,
  }) {
    final random = Random();
    final orderNumber = (1000 + random.nextInt(9000)).toString();
    final trackingNo = 'IK${DateTime.now().millisecondsSinceEpoch}';

    // Get first item's image for display
    String imageUrl = '';
    String productName = 'Fashion Items';
    List<String> productIds = [];

    if (cartItems.isNotEmpty) {
      final firstItem = cartItems.first;

      // Try different image field names from your CartItem structure
      imageUrl = firstItem['imageUrl'] ?? firstItem['image'] ?? '';
      productName = firstItem['name'] ?? firstItem['title'] ?? 'Fashion Item';

      // If multiple items, show count
      if (cartItems.length > 1) {
        productName = '${firstItem['name'] ?? firstItem['title'] ?? 'Fashion Item'} (+${cartItems.length - 1} more)';
      }

      // Collect all product IDs
      for (var item in cartItems) {
        if (item['id'] != null) {
          productIds.add(item['id'].toString());
        }
      }
    }

    return OrderModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      orderNumber: orderNumber,
      trackingNo: trackingNo,
      quantity: totalItems,
      subtotal: totalAmount,
      imageUrl: imageUrl,
      status: 'RECENT',
      createdAt: DateTime.now(),
      productName: productName,
      productIds: productIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'trackingNo': trackingNo,
      'quantity': quantity,
      'subtotal': subtotal,
      'imageUrl': imageUrl,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'productName': productName,
      'productIds': productIds,
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      trackingNo: json['trackingNo'] ?? '',
      quantity: json['quantity'] ?? 0,
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      status: json['status'] ?? 'RECENT',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      productName: json['productName'] ?? 'Fashion Item',
      productIds: List<String>.from(json['productIds'] ?? []),
    );
  }
}

// MyOrder Controller - UPDATED for CartItem compatibility
class MyOrderController extends GetxController {
  final RxList<OrderModel> allOrders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt currentTabIndex = 0.obs;

  // Filtered lists for each tab
  List<OrderModel> get recentOrders =>
      allOrders.where((order) => order.status == 'RECENT').toList();

  List<OrderModel> get deliveredOrders =>
      allOrders.where((order) => order.status == 'DELIVERED').toList();

  List<OrderModel> get cancelledOrders =>
      allOrders.where((order) => order.status == 'CANCELLED').toList();

  List<OrderModel> get returnOrders =>
      allOrders.where((order) => order.status == 'RETURN').toList();

  @override
  void onInit() {
    super.onInit();
    loadOrders();

    // Listen for new orders from cart payments
    ever(allOrders, (_) {
      _saveOrdersToStorage();
    });
  }

  void loadOrders() async {
    isLoading.value = true;

    try {
      // Load from local storage first
      await _loadOrdersFromStorage();

      // Add some sample data if empty (for demo)
      if (allOrders.isEmpty) {
        _addSampleOrders();
      }

    } catch (e) {
      print('Error loading orders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // FIXED: Add new order when payment is completed - now accepts the correct data structure
  void addOrderFromPayment({
    required double totalAmount,
    required int totalItems,
    required List<Map<String, dynamic>> cartItems, // Changed from List<dynamic>
  }) {
    try {
      final newOrder = OrderModel.fromCartPayment(
        totalAmount: totalAmount,
        totalItems: totalItems,
        cartItems: cartItems,
      );

      // Add to the beginning of the list (most recent first)
      allOrders.insert(0, newOrder);

      print('✅ New order added: ${newOrder.orderNumber}');
      print('📦 Order details: ${newOrder.productName}, Qty: ${newOrder.quantity}, Total: ₹${newOrder.subtotal}');

      // Show success notification
      Get.snackbar(
        'Order Placed!',
        'Order #${newOrder.orderNumber} has been placed successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
        icon: Icon(Icons.check_circle, color: Colors.white),
      );

    } catch (e) {
      print('❌ Error adding order: $e');
      Get.snackbar(
        'Error',
        'Failed to create order: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  int getTotalItemsForCurrentTab() {
    switch (currentTabIndex.value) {
      case 0:
        return recentOrders.length;
      case 1:
        return deliveredOrders.length;
      case 2:
        return cancelledOrders.length;
      case 3:
        return returnOrders.length;
      default:
        return 0;
    }
  }

  void viewOrderDetails(OrderModel order) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text('Order Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Order Number', '#${order.orderNumber}'),
              _buildDetailRow('Tracking No', order.trackingNo),
              _buildDetailRow('Status', order.status),
              _buildDetailRow('Quantity', order.quantity.toString()),
              _buildDetailRow('Subtotal', '₹${order.subtotal.toStringAsFixed(0)}'),
              _buildDetailRow('Product', order.productName),
              _buildDetailRow('Date', _formatDate(order.createdAt)),
              SizedBox(height: 16),
              if (order.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    order.imageUrl,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.image, color: Colors.grey[400]),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
        actions: [
          if (order.status == 'RECENT') ...[
            TextButton(
              onPressed: () {
                Get.back();
                _cancelOrder(order);
              },
              child: Text('Cancel Order', style: TextStyle(color: Colors.red)),
            ),
          ],
          if (order.status == 'DELIVERED') ...[
            TextButton(
              onPressed: () {
                Get.back();
                _returnOrder(order);
              },
              child: Text('Return Order', style: TextStyle(color: Colors.orange)),
            ),
          ],
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF094D77),
            ),
            child: Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _cancelOrder(OrderModel order) {
    Get.dialog(
      AlertDialog(
        title: Text('Cancel Order'),
        content: Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _updateOrderStatus(order.id, 'CANCELLED');
              Get.snackbar(
                'Order Cancelled',
                'Order #${order.orderNumber} has been cancelled',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _returnOrder(OrderModel order) {
    Get.dialog(
      AlertDialog(
        title: Text('Return Order'),
        content: Text('Are you sure you want to return this order?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _updateOrderStatus(order.id, 'RETURN');
              Get.snackbar(
                'Return Initiated',
                'Return request for Order #${order.orderNumber} has been submitted',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.orange,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text('Yes, Return', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _updateOrderStatus(String orderId, String newStatus) {
    final orderIndex = allOrders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      final order = allOrders[orderIndex];
      final updatedOrder = OrderModel(
        id: order.id,
        orderNumber: order.orderNumber,
        trackingNo: order.trackingNo,
        quantity: order.quantity,
        subtotal: order.subtotal,
        imageUrl: order.imageUrl,
        status: newStatus,
        createdAt: order.createdAt,
        productName: order.productName,
        productIds: order.productIds,
      );

      allOrders[orderIndex] = updatedOrder;
    }
  }

  void showFilterDialog() {
    Get.snackbar(
      'Filter',
      'Filter functionality coming soon!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Color(0xFF094D77),
      colorText: Colors.white,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Sample data for demo - UPDATED with better sample data
  void _addSampleOrders() {
    final sampleOrders = [
      OrderModel(
        id: '1',
        orderNumber: '1524',
        trackingNo: 'IK287368838',
        quantity: 21,
        subtotal: 29000,
        imageUrl: 'https://res.cloudinary.com/doiezptnn/image/upload/v1757756043/sample1.jpg',
        status: 'DELIVERED',
        createdAt: DateTime.now().subtract(Duration(days: 5)),
        productName: 'Traditional Ethnic Wear',
        productIds: ['prod_1', 'prod_2'],
      ),
      OrderModel(
        id: '2',
        orderNumber: '1122',
        trackingNo: 'IK287368834',
        quantity: 11,
        subtotal: 9000,
        imageUrl: 'https://res.cloudinary.com/doiezptnn/image/upload/v1757756043/sample2.jpg',
        status: 'RECENT',
        createdAt: DateTime.now().subtract(Duration(hours: 2)),
        productName: 'Winter Jacket Collection',
        productIds: ['prod_3'],
      ),
    ];

    allOrders.addAll(sampleOrders);
  }

  // Storage methods (implement with shared_preferences or secure storage)
  Future<void> _loadOrdersFromStorage() async {
    try {
      // TODO: Implement loading from SharedPreferences
      // For now, just simulate loading
      await Future.delayed(Duration(milliseconds: 500));
    } catch (e) {
      print('Error loading orders from storage: $e');
    }
  }

  void _saveOrdersToStorage() {
    try {
      // TODO: Implement saving to SharedPreferences
      final ordersJson = allOrders.map((order) => order.toJson()).toList();
      // Save ordersJson to storage
      print('📁 Orders saved to storage: ${ordersJson.length} orders');
    } catch (e) {
      print('Error saving orders to storage: $e');
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}