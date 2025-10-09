import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../Cart/CartController.dart'; // Your CartController import
import 'CheckoutPaymentView.dart'; // Import success screen from your view file

class CheckoutPaymentController extends GetxController {
  // --- STATE VARIABLES ---
  var selectedPaymentMethod = 0.obs; // 0 for Online, 2 for COD

  // --- DEPENDENCIES ---
  final CartController cartController = Get.find<CartController>();
  late Razorpay _razorpay;

  // --- RAZORPAY KEYS ---
  final String _keyId = 'rzp_test_RNuK1I8Q4fQ94x';

  // --- LIFECYCLE METHODS ---
  @override
  void onInit() {
    super.onInit();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }

  // --- UI LOGIC ---
  void changePaymentMethod(int? value) {
    selectedPaymentMethod.value = value ?? 0;
  }

  // --- BUSINESS LOGIC ---
  void processPayment() {
    if (selectedPaymentMethod.value == 2) { // COD
      _placeCODOrder();
    } else { // Online Payment
      _openRazorpayCheckout();
    }
  }

  void _placeCODOrder() {
    Get.dialog(
      AlertDialog(
        content: Row(children: [
          CircularProgressIndicator(color: Color(0xFF187DBD)),
          SizedBox(width: 20),
          Text("Placing Order..."),
        ]),
      ),
      barrierDismissible: false,
    );

    Future.delayed(Duration(seconds: 2), () {
      Get.back(); // Close dialog
      _onOrderSuccess();
    });
  }

  void _openRazorpayCheckout() {
    // Amount must be in the smallest currency unit (paise for INR)
    var amountInPaise = (cartController.finalTotal * 100).toInt();

    var options = {
      'key': _keyId,
      'amount': amountInPaise,
      'name': 'Your E-commerce App',
      'description': 'Order Payment',
      'prefill': {
        'contact': '9876543210',
        'email': 'customer@example.com'
      },
      'notes': {
        'order_id': 'ORDER_${DateTime.now().millisecondsSinceEpoch}',
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint("Razorpay Error: ${e.toString()}");
    }
  }

  // --- RAZORPAY EVENT HANDLERS ---
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint("✅ PAYMENT SUCCESSFUL: ${response.paymentId}");
    Get.snackbar(
      "Payment Successful",
      "Payment ID: ${response.paymentId}",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
    _onOrderSuccess();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint("❌ PAYMENT ERROR: ${response.code} - ${response.message}");
    Get.snackbar(
      "Payment Failed",
      "Error: ${response.message}",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint("➡️ EXTERNAL WALLET: ${response.walletName}");
    Get.snackbar(
      "External Wallet",
      "Selected: ${response.walletName}",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  // --- COMMON SUCCESS ACTION ---
  void _onOrderSuccess() {
    cartController.clearCart();
    Get.offAll(() => OrderSuccessScreen());
  }
}