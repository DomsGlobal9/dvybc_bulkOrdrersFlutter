import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Widgets/CustomDVYBAppBarWithBack.dart';
import 'MyOrderController.dart';

class MyOrderView extends StatefulWidget {
  const MyOrderView({Key? key}) : super(key: key);

  @override
  _MyOrderViewState createState() => _MyOrderViewState();
}

class _MyOrderViewState extends State<MyOrderView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MyOrderController controller = Get.put(MyOrderController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    controller.loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      appBar: CustomDVYBAppBar(),
      body: Column(
        children: [
          // Header with circular back button and centered "My Orders"
          SizedBox(height: 10,),
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Stack(
              children: [
                // Circular back button on the left
                Positioned(
                  left: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                       // color: Colors.grey[100],
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                // Centered "My Orders" title
                Center(
                  child: Text(
                    'My Orders',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30,),
          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: false,
              labelColor: Color(0xFF094D77),
              unselectedLabelColor: Color(0xFF114463),
              labelStyle: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              indicatorColor: Color(0xFF094D77),
              indicatorWeight: 2,
              dividerColor: Colors.transparent, // Remove cyan underline
              onTap: (index) {
                controller.currentTabIndex.value = index;
              },
              tabs: [
                Tab(text: 'RECENT'),
                Tab(text: 'DELIVERED'),
                Tab(text: 'CANCELLED'),
                Tab(text: 'RETURN'),
              ],
            ),
          ),

          // Total Items and Filter Row
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Items: ${controller.getTotalItemsForCurrentTab()}',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: () => _showFilterModal(),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.tune, size: 16, color: Colors.grey[600]),
                        SizedBox(width: 6),
                        Text(
                          'Filter', // Just "Filter" not "Filter By Order Date"
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )),
          ),

          // Tab Bar View
          Expanded(
            child: Container(
              color: Colors.grey[50], // Light grey background for content
              child: TabBarView(
                controller: _tabController,
                children: [
                  RecentOrdersView(),
                  DeliveredOrdersView(),
                  CancelledOrdersView(),
                  ReturnOrdersView(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterModal() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned(
                top: 200,
                right: 16,
                child: FilterModalWidget(),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Proper Material Filter Modal
class FilterModalWidget extends StatefulWidget {
  @override
  _FilterModalWidgetState createState() => _FilterModalWidgetState();
}

class _FilterModalWidgetState extends State<FilterModalWidget> {
  String selectedFilter = 'Last Week';

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Filter By Order Date',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),

            // Filter Options
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildFilterOption('Last Week'),
                  _buildFilterOption('Last Month'),
                  _buildFilterOption('Last 3 Month'),
                  _buildFilterOption('Last 6 Month'),
                  _buildFilterOption('2025'),
                  _buildFilterOption('2024'),
                ],
              ),
            ),

            // Apply Button
            Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Get.snackbar(
                      'Filter Applied',
                      'Filtering by $selectedFilter',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Color(0xFF094D77),
                      colorText: Colors.white,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF094D77),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Apply',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String title) {
    bool isSelected = selectedFilter == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = title;
        });
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Color(0xFF094D77) : Colors.grey[400]!,
                  width: 2,
                ),
                color: Colors.white,
              ),
              child: isSelected
                  ? Center(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Color(0xFF094D77),
                    shape: BoxShape.circle,
                  ),
                ),
              )
                  : null,
            ),
            SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Color(0xFF094D77) : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Updated Recent Orders View with side-by-side layout
class RecentOrdersView extends StatelessWidget {
  final MyOrderController controller = Get.find<MyOrderController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator(color: Color(0xFF094D77)));
      }

      if (controller.recentOrders.isEmpty) {
        return _buildEmptyState('RECENT');
      }

      return ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: controller.recentOrders.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(controller.recentOrders[index], 'RECENT');
        },
      );
    });
  }

  Widget _buildEmptyState(String status) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/noparcel.png',
            width: 120,
            height: 120,
            color: Colors.grey[400],
          ),
          SizedBox(height: 24),
          Text(
            status == 'RECENT' ? 'No recent orders yet' :
            status == 'DELIVERED' ? 'No delivered orders yet' :
            status == 'CANCELLED' ? 'No cancellations yet' :
            'No returns yet',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Your orders will appear here',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order, String status) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
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
          children: [
            // Main content row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image with quantity badge
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        order.imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.image, color: Colors.grey[400]),
                          );
                        },
                      ),
                    ),
                    // Quantity badge - positioned at bottom right
                    if (order.quantity > 1)
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              '+${order.quantity - 1}',
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                SizedBox(width: 16),

                // Order details column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Tracking Number
                      Text(
                        'Tracking No: ${order.trackingNo}',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 6),

                      // Quantity
                      Text(
                        'Quantity: ${order.quantity}',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 6),

                      // Subtotal
                      Text(
                        'Subtotal: ₹${order.subtotal.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),

                      // Order number - prominent
                      Text(
                        'Order #${order.orderNumber}',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            // Details button - full width at bottom
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => controller.viewOrderDetails(order),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF094D77),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  minimumSize: Size(80, 36),
                ),
                child: Text(
                  'Details',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        )
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'RECENT':
        return Colors.orange;
      case 'DELIVERED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      case 'RETURN':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

// Other view classes with same structure
class DeliveredOrdersView extends StatelessWidget {
  final MyOrderController controller = Get.find<MyOrderController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator(color: Color(0xFF094D77)));
      }

      if (controller.deliveredOrders.isEmpty) {
        return RecentOrdersView()._buildEmptyState('DELIVERED');
      }

      return ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: controller.deliveredOrders.length,
        itemBuilder: (context, index) {
          return RecentOrdersView()._buildOrderCard(controller.deliveredOrders[index], 'DELIVERED');
        },
      );
    });
  }
}

class CancelledOrdersView extends StatelessWidget {
  final MyOrderController controller = Get.find<MyOrderController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator(color: Color(0xFF094D77)));
      }

      if (controller.cancelledOrders.isEmpty) {
        return RecentOrdersView()._buildEmptyState('CANCELLED');
      }

      return ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: controller.cancelledOrders.length,
        itemBuilder: (context, index) {
          return RecentOrdersView()._buildOrderCard(controller.cancelledOrders[index], 'CANCELLED');
        },
      );
    });
  }
}

class ReturnOrdersView extends StatelessWidget {
  final MyOrderController controller = Get.find<MyOrderController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator(color: Color(0xFF094D77)));
      }

      if (controller.returnOrders.isEmpty) {
        return RecentOrdersView()._buildEmptyState('RETURN');
      }

      return ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: controller.returnOrders.length,
        itemBuilder: (context, index) {
          return RecentOrdersView()._buildOrderCard(controller.returnOrders[index], 'RETURN');
        },
      );
    });
  }
}