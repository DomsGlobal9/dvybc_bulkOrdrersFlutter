import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../views/Widgets/CustomDVYBAppBarWithBack.dart';
import '../Cart/CartController.dart';


class CheckoutReviewView extends StatelessWidget {
  final CartController cartController = Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomDVYBAppBar(
      ),
      body: Column(
        children: [
          // STICKY Progress Indicator
          _buildProgressIndicator(),

          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 100), // Padding for bottom button
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSavingsBadge(),
                  SizedBox(height: 20),
                  Obx(() => Column(
                    children: cartController.cartItems
                        .map((item) => _buildProductCard(item))
                        .toList(),
                  )),
                  SizedBox(height: 20),
                  _buildPriceDetails(),
                ],
              ),
            ),
          ),
        ],
      ),
      // Bottom Continue Button (Fixed)
      bottomSheet: _buildBottomContinueButton(),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      color: Colors.white,
      child: Row(
        children: [
          _buildProgressStep('Review', true, false),
          _buildDashedLine(false),
          _buildProgressStep('Address', false, false),
          _buildDashedLine(false),
          _buildProgressStep('Payment', false, false),
        ],
      ),
    );
  }

  Widget _buildSavingsBadge() {
    return Obx(() {
      double mrp = 0;
      cartController.cartItems.forEach((item) {
        double price = double.tryParse(item.price.replaceAll('₹', '').replaceAll(',', '')) ?? 0.0;
        mrp += price * item.quantity.value * 1.5; // Assuming MRP is 1.5x the price
      });
      double savings = mrp - cartController.subtotal;

      return Container(
        width: 358,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Color(0xFFD5EFFF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Color(0xFF187DBD), size: 20),
            SizedBox(width: 12),
            Text(
              'You Have Saved ₹${savings.toStringAsFixed(0)} on this Order',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF187DBD),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildProductCard(CartItem item) {
    String imageUrl = item.womenProduct?.imageUrls?.first ?? item.imagePath;
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 100,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : Center(child: CircularProgressIndicator(color: Color(0xFF187DBD))),
                errorBuilder: (context, error, stack) => Container(
                  color: Colors.grey[200],
                  child: Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                Text(item.category, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                SizedBox(height: 8),
                Row(children: [
                  Text(
                    '₹${((double.tryParse(item.price.replaceAll('₹', '')) ?? 0) * 1.5).toStringAsFixed(0)}',
                    style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey[500]),
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                        color: Color(0xFF187DBD), borderRadius: BorderRadius.circular(4)),
                    child: Text('33% off',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                  ),
                ]),
                SizedBox(height: 8),
                Text('₹${item.price}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                Row(children: [
                  // Size Container
                  Container(
                    width: 106.15,
                    height: 32.46,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0x66D9D9D9)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(children: [
                      Text('Size: ${item.selectedSize ?? 'Free'}', style: TextStyle(fontSize: 14)),
                      Spacer(),
                      Icon(Icons.arrow_drop_down, size: 16),
                    ]),
                  ),
                  SizedBox(width: 17),
                  // Qty Container
                  Container(
                    width: 45,
                    height: 21,
                    child: Row(children: [
                      Text('Qty:', style: TextStyle(fontFamily: 'Outfit', color: Colors.grey[600])),
                      SizedBox(width: 4),
                      Obx(() => Text('${item.quantity.value}',
                          style: TextStyle(fontWeight: FontWeight.w600))),
                    ]),
                  )
                ])
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceDetails() {
    return Container(
      width: 333,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_offer_outlined, size: 20),
              SizedBox(width: 8),
              Text('Price Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
          SizedBox(height: 20),
          Container(
            width: 311.97,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(0xFFE0E0E0), width: 0.88),
            ),
            child: Obx(() {
              double mrp = 0;
              cartController.cartItems.forEach((item) {
                double price = double.tryParse(item.price.replaceAll('₹', '').replaceAll(',', '')) ?? 0.0;
                mrp += price * item.quantity.value * 1.5;
              });
              double discount = mrp - cartController.subtotal;
              return Column(
                children: [
                  _priceDetailRow('Total Amount:', '₹${cartController.finalTotal.toStringAsFixed(0)}', isTotal: true),
                  SizedBox(height: 16),
                  _priceDetailRow('Total MRP', '₹${mrp.toStringAsFixed(0)}'),
                  SizedBox(height: 8),
                  _priceDetailRow('Discount on MRP', '-₹${discount.toStringAsFixed(0)}', isDiscount: true),
                  SizedBox(height: 8),
                  _priceDetailRow('Shipping Fee', 'FREE', isDiscount: true),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _priceDetailRow(String label, String value, {bool isTotal = false, bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: isTotal ? 18 : 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(fontSize: isTotal ? 18 : 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: isDiscount || isTotal ? Color(0xFF187DBD) : Colors.black87)),
      ],
    );
  }

  Widget _buildBottomContinueButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 10, offset: Offset(0, -5))
        ],
      ),
      child: Container(
        width: 333,
        height: 44,
        child: ElevatedButton(
          onPressed: () => Get.toNamed('/checkout-address'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF187DBD),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          child: Text('Continue', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _buildProgressStep(String label, bool isActive, bool isCompleted) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? Color(0xFF187DBD) : Color(0xFFD9D9D9),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted ? Icons.check : Icons.receipt_long,
            color: Colors.white,
            size: 20,
          ),
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 14, fontWeight: isActive ? FontWeight.w600 : FontWeight.normal, color: isActive ? Color(0xFF187DBD) : Color(0xFF666666))),
      ],
    );
  }

  Widget _buildDashedLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: EdgeInsets.only(bottom: 30, left: 4, right: 4),
        color: isActive ? Color(0xFF187DBD) : Color(0xFFD9D9D9),
      ),
    );
  }
}