import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ================= CONTROLLER =================
class ForgotPasswordController extends GetxController {
  var emailController = TextEditingController();
  var emailError = RxnString();
  var isLoading = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  void goBack() {
    Get.back();
  }

  bool isValidEmail(String email) {
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  void sendResetLink() async {
    if (emailController.text.isEmpty || !isValidEmail(emailController.text)) {
      emailError.value = "Please enter a valid email";
      return;
    }
    emailError.value = null;

    isLoading.value = true;
    await Future.delayed(Duration(seconds: 2)); // Simulate API
    isLoading.value = false;

    Get.to(() => ResetLinkSentScreen());
  }

  void changePassword() {
    Get.to(() => PasswordChangedScreen());
  }
}

// ================= SCREEN 1 (Forgot Password) =================
class ForgotPasswordScreen extends StatelessWidget {
  final ForgotPasswordController controller = Get.put(ForgotPasswordController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: controller.goBack,
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
        ),
        title: Text(
          'Back to Login',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),

            // Title
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Forgot Password',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),

            SizedBox(height: 40),

            Column(
              children: [
                SizedBox(height: 40),
                // Illustration
                Image.asset(
                  "assets/images/otpSent.png",
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Text(
                      'Failed to load image',
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    );
                  },
                ),
                SizedBox(height: 30),
              ],
            ),

            SizedBox(height: 30),

            Text(
              'Don\'t worry! It happens. Please enter email\nassociated with your account',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 32),

            // Email Input Label
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Enter your e-mail address',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            SizedBox(height: 8),

            // Email Input
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
                color: Colors.grey[50],
              ),
              child: TextField(
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'example@gmail.com',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  suffixIcon: Container(
                    margin: EdgeInsets.all(12),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),
            ),

            Obx(() => controller.emailError.value != null
                ? Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                controller.emailError.value!,
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            )
                : SizedBox.shrink()),

            SizedBox(height: 32),

            // Reset Link Button
            Obx(() => Container(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.sendResetLink,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1E5A96),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  disabledBackgroundColor: Color(0xFF1E5A96).withOpacity(0.5),
                ),
                child: controller.isLoading.value
                    ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Text(
                  "Get Reset Link",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ================= SCREEN 2 (Reset Link Sent) =================
class ResetLinkSentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ForgotPasswordController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: controller.goBack,
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
        ),
        title: Text(
          'Back to Login',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            Container(
              height: 200,
              width: 280,
              child: Stack(
                children: [
                  // Background elements
                  Positioned(
                    top: 10,
                    left: 20,
                    child: Container(
                      width: 25,
                      height: 25,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade200,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  Positioned(
                    top: 50,
                    left: 10,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.orange.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),

                  // Main screen/tablet
                  Center(
                    child: Container(
                      width: 180,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          // Screen content
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Shield icon
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade600,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.security,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  // Chart bars
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(5, (index) {
                                      return Container(
                                        margin: EdgeInsets.symmetric(horizontal: 2),
                                        width: 8,
                                        height: 20 + (index * 5).toDouble(),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade400,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Floating elements (gears, etc.)
                  Positioned(
                    top: 20,
                    right: 30,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.settings,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 20,
                    left: 15,
                    child: Container(
                      width: 25,
                      height: 25,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade400,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.settings,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 30,
                    right: 20,
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade500,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.bar_chart,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            // Success message
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Password Reset Link Sent !",
                    style: TextStyle(
                      fontSize: 16,
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
    );
  }
}

// ================= SCREEN 3 (Password Changed) =================
class PasswordChangedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ForgotPasswordController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: controller.goBack,
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
        ),
        title: Text(
          'Back to Login',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            Container(
              height: 220,
              width: 300,
              child: Stack(
                children: [
                  // Background decorative elements
                  Positioned(
                    top: 20,
                    left: 30,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.pink.shade200,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  Positioned(
                    top: 40,
                    right: 40,
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        color: Colors.green.shade300,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 40,
                    left: 20,
                    child: Container(
                      width: 25,
                      height: 25,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade200,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),

                  // Main characters
                  Center(
                    child: Container(
                      width: 200,
                      height: 160,
                      child: Stack(
                        children: [
                          // Person 1 (left)
                          Positioned(
                            left: 0,
                            bottom: 20,
                            child: Container(
                              width: 70,
                              height: 120,
                              child: Column(
                                children: [
                                  // Head
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFFFDBB5),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  // Body
                                  Container(
                                    width: 35,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  // Legs
                                  Container(
                                    width: 40,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade700,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Person 2 (right)
                          Positioned(
                            right: 0,
                            bottom: 20,
                            child: Container(
                              width: 70,
                              height: 120,
                              child: Column(
                                children: [
                                  // Head
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFFFDBB5),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  // Body
                                  Container(
                                    width: 35,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade600,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  // Legs
                                  Container(
                                    width: 40,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade700,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Central lock/security element
                          Center(
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade700,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 30,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white, width: 3),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(15),
                                        topRight: Radius.circular(15),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 40,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade700,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Key (top right of lock)
                          Positioned(
                            top: 30,
                            right: 65,
                            child: Transform.rotate(
                              angle: 0.5,
                              child: Container(
                                width: 30,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade600,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade600,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Success message
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Password Changed Successfully !",
                    style: TextStyle(
                      fontSize: 16,
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
    );
  }
}