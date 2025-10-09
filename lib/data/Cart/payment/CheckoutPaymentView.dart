import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'CheckoutPaymentController.dart'; // Import the new controller
import '../../views/Widgets/CustomDVYBAppBarWithBack.dart'; // Your custom app bar

class CheckoutPaymentView extends GetView<CheckoutPaymentController> {
  const CheckoutPaymentView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize the controller when the view is built
    final controller = Get.put(CheckoutPaymentController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomDVYBAppBar(),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTotalAmountSection(),
                  SizedBox(height: 24),
                  _buildBankOffersSection(),
                  SizedBox(height: 24),
                  _buildCouponsSection(),
                  SizedBox(height: 24),
                  _buildPaymentMethodsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomPayButton(),
    );
  }

  // --- WIDGETS ---
  // These are pure UI components, no logic inside

  Widget _buildTotalAmountSection() {
    return Obx(() => Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total Amount:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          Text('₹${controller.cartController.finalTotal.toStringAsFixed(0)}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF187DBD))),
        ],
      ),
    ));
  }

  Widget _buildPaymentMethodsSection() {
    return Obx(() => Column(children: [ // Wrap in Obx to rebuild on change
      _buildPaymentMethod(0, Icons.account_balance_wallet, 'Online (UPI, Card, Wallet)'),
      SizedBox(height: 16),
      _buildPaymentMethod(2, Icons.money, 'COD Available (Cash On Delivery)'),
    ]));
  }

  Widget _buildPaymentMethod(int index, IconData icon, String title) {
    bool isSelected = controller.selectedPaymentMethod.value == index;
    return GestureDetector(
      onTap: () => controller.changePaymentMethod(index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? Color(0xFF187DBD) : Color(0xFFE0E0E0), width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Radio<int>(
              value: index,
              groupValue: controller.selectedPaymentMethod.value,
              onChanged: controller.changePaymentMethod,
              activeColor: Color(0xFF187DBD)),
          Icon(icon, color: Colors.grey[700], size: 24),
          SizedBox(width: 16),
          Expanded(child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
        ]),
      ),
    );
  }

  Widget _buildBottomPayButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 10, offset: Offset(0, -5))],
      ),
      child: Obx(() => SizedBox(
        width: 333,
        height: 44,
        child: ElevatedButton(
          onPressed: controller.cartController.finalTotal > 0 ? controller.processPayment : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF187DBD),
            disabledBackgroundColor: Colors.grey[400],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          child: Text(
            controller.selectedPaymentMethod.value == 2
                ? 'Place Order (COD)'
                : 'Pay ₹${controller.cartController.finalTotal.toStringAsFixed(0)}',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      )),
    );
  }

  // --- Other Static Widgets ---

  Widget _buildProgressIndicator() {
    // ... (This widget has no state, so it can remain as is)
    return Container( /* ... */ );
  }

  Widget _buildBankOffersSection() {
    // ... (This widget has no state, so it can remain as is)
    return Container( /* ... */ );
  }

  Widget _buildCouponsSection() {
    // ... (This widget has no state, so it can remain as is)
    return Container( /* ... */ );
  }
}

// You can keep this screen here or move it to its own file
class OrderSuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center( /* ... Your existing success screen UI ... */ ),
    );
  }
}