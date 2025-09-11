import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Cart/CartController.dart';

class CheckoutPaymentView extends StatefulWidget {
  @override
  _CheckoutPaymentViewState createState() => _CheckoutPaymentViewState();
}

class _CheckoutPaymentViewState extends State<CheckoutPaymentView> {
  int selectedPaymentMethod = 0; // UPI is pre-selected
  final CartController cartController = Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black87,
            size: 24,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Checkout',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress Indicator with dashed lines
          _buildProgressIndicator(),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total Amount
                  _buildTotalAmountSection(),

                  SizedBox(height: 24),

                  // Bank Offers
                  _buildBankOffersSection(),

                  SizedBox(height: 24),

                  // Coupons & Rewards
                  _buildCouponsSection(),

                  SizedBox(height: 24),

                  // Payment Methods
                  _buildPaymentMethodsSection(),

                  SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),

          // Bottom Pay Button
          _buildBottomPayButton(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        children: [
          _buildProgressStep(Icons.receipt_long, 'Review', false, true),
          _buildDashedLine(true),
          _buildProgressStep(Icons.location_on, 'Address', false, true),
          _buildDashedLine(true),
          _buildProgressStep(Icons.payment, 'Payment', true, false),
        ],
      ),
    );
  }

  Widget _buildProgressStep(IconData icon, String label, bool isActive, bool isCompleted) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? Color(0xFF094D77) : (isCompleted ? Color(0xFF094D77) : Colors.grey[300]),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: (isActive || isCompleted) ? Colors.white : Colors.grey[600],
            size: 20,
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? Color(0xFF094D77) : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDashedLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: EdgeInsets.only(bottom: 30),
        child: CustomPaint(
          painter: DashedLinePainter(
            color: isActive ? Color(0xFF094D77) : Colors.grey[300]!,
          ),
        ),
      ),
    );
  }

  Widget _buildTotalAmountSection() {
    return Container(
      child: Obx(() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Amount:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            '₹${cartController.finalTotal.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
        ],
      )),
    );
  }

  Widget _buildBankOffersSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.account_balance,
            color: Color(0xFF094D77),
            size: 24,
          ),
          SizedBox(width: 12),
          Text(
            'Bank Offers',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                // Bank logos (mock icons)
                _buildBankIcon(Colors.red),
                SizedBox(width: 4),
                _buildBankIcon(Color(0xFF094D77)),
                SizedBox(width: 4),
                _buildBankIcon(Colors.purple),
                SizedBox(width: 12),
                Text(
                  '+12 offers Available',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF094D77),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankIcon(Color color) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildCouponsSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child:
          Row(
            children: [
              Text(
                'View coupons available',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  // Show all coupons
                },
                child: Text(
                  'All Coupons',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF094D77),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF094D77),
                size: 16,
              ),
            ],
          ),

    );
  }

  Widget _buildPaymentMethodsSection() {
    return Column(
      children: [
        _buildPaymentMethod(
          0,
          Icons.account_balance_wallet,
          'UPI (Pay via any App)',
          true,
        ),
        SizedBox(height: 16),
        _buildPaymentMethod(
          1,
          Icons.credit_card,
          'Credit/Debit Card',
          false,
        ),
        SizedBox(height: 16),
        _buildPaymentMethod(
          2,
          Icons.money,
          'COD Available\n(Cash On Delivery)',
          false,
        ),
      ],
    );
  }

  Widget _buildPaymentMethod(int index, IconData icon, String title, bool showUPILogo) {
    bool isSelected = selectedPaymentMethod == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = index;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Color(0xFF094D77) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio Button
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Color(0xFF094D77) : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Color(0xFF094D77),
                    shape: BoxShape.circle,
                  ),
                ),
              )
                  : null,
            ),

            SizedBox(width: 16),

            // Payment Icon
            if (showUPILogo)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'UPI',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              )
            else
              Icon(
                icon,
                color: Colors.grey[700],
                size: 24,
              ),

            SizedBox(width: 16),

            // Payment Method Title
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPayButton() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Obx(() => Container(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            // Process payment
            _processPayment();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF094D77),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            'Pay ₹${cartController.finalTotal.toStringAsFixed(0)}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      )),
    );
  }

  void _processPayment() {
    // Show payment processing dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Color(0xFF094D77),
            ),
            SizedBox(height: 16),
            Text(
              'Processing Payment...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );

    // Simulate payment processing
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Close processing dialog

      // Show success dialog
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
              SizedBox(height: 16),
              Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Your order has been placed successfully.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Clear cart after successful payment
                  cartController.clearCart();
                  Get.back(); // Close dialog
                  // Navigate to home with proper functioning
                  Get.offAllNamed('/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF094D77),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Continue Shopping',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    });
  }
}

// Custom painter for dashed lines
class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;

    const dashWidth = 5;
    const dashSpace = 3;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}