import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../tabview/tabviews.dart';
import 'register.dart' hide Padding;

class LoginController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool rememberMe = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxnString emailError = RxnString();
  final RxnString passwordError = RxnString();
  final RxBool isLoading = false.obs;

  void togglePasswordVisibility() {
    obscurePassword.toggle();
  }

  void toggleRememberMe() {
    rememberMe.toggle();
  }

  void validateAndLogin() {
    emailError.value = null;
    passwordError.value = null;

    if (emailController.text.isEmpty) {
      emailError.value = 'Email or Phone is required';
    }

    if (passwordController.text.isEmpty) {
      passwordError.value = 'Password is required';
    } else if (passwordController.text.length < 6) {
      passwordError.value = 'Password must be at least 6 characters';
    }

    if (emailError.value == null && passwordError.value == null) {
      _performLogin();
    }
  }

  // Safe Firebase Auth method that handles PigeonUserDetails error
  Future<UserCredential?> _safeFirebaseAuth(String email, String password) async {
    try {
      // Try normal Firebase Auth
      return await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      // If PigeonUserDetails error occurs, try alternative approach
      if (e.toString().contains('PigeonUserDetails') ||
          e.toString().contains('type cast') ||
          e.toString().contains('List<Object?>')) {
        print('PigeonUserDetails error detected, using workaround...');

        // Wait a moment and check if user was actually authenticated
        await Future.delayed(Duration(seconds: 1));

        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null && currentUser.email == email) {
          print('User authenticated successfully despite error');
          // Create a simple wrapper since user is actually logged in
          return _MockUserCredential(currentUser);
        }

        // If workaround didn't work, try one more time with a delay
        await Future.delayed(Duration(milliseconds: 500));
        try {
          return await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
        } catch (retryError) {
          print('Retry attempt failed: $retryError');
          // Check again if user is authenticated
          User? retryUser = FirebaseAuth.instance.currentUser;
          if (retryUser != null && retryUser.email == email) {
            return _MockUserCredential(retryUser);
          }
        }
      }

      // Re-throw if it's a different error or workaround failed
      rethrow;
    }
  }

  Future<void> _performLogin() async {
    isLoading.value = true;
    String input = emailController.text.trim();
    String password = passwordController.text.trim();

    try {
      UserCredential? cred;
      String emailToUse = input;

      if (GetUtils.isEmail(input)) {
        // Login with email
        print('Logging in with email: $input');
        cred = await _safeFirebaseAuth(input, password);
      } else {
        // Login with phone - search in the correct collection
        print('Logging in with phone: $input');

        // Search in B2BBulkOrders_users collection (same as registration)
        QuerySnapshot query = await FirebaseFirestore.instance
            .collection('B2BBulkOrders_users')
            .where('phone', isEqualTo: input)
            .limit(1)
            .get();

        if (query.docs.isEmpty) {
          // Try with +91 prefix
          String phoneWithPrefix = input.startsWith('+91') ? input : '+91$input';
          query = await FirebaseFirestore.instance
              .collection('B2BBulkOrders_users')
              .where('phone', isEqualTo: phoneWithPrefix)
              .limit(1)
              .get();
        }

        if (query.docs.isEmpty) {
          // Try without any prefix if it had one
          if (input.startsWith('+91')) {
            String phoneWithoutPrefix = input.substring(3);
            query = await FirebaseFirestore.instance
                .collection('B2BBulkOrders_users')
                .where('phone', isEqualTo: phoneWithoutPrefix)
                .limit(1)
                .get();
          }
        }

        if (query.docs.isEmpty) {
          throw FirebaseAuthException(
              code: 'user-not-found',
              message: 'No user found with this phone number.'
          );
        }

        Map<String, dynamic> userData = query.docs.first.data() as Map<String, dynamic>;
        emailToUse = userData['email'] as String;
        print('Found email for phone: $emailToUse');

        cred = await _safeFirebaseAuth(emailToUse, password);
      }

      if (cred?.user != null) {
        print('Login successful: ${cred!.user!.uid}');

        // Save login state
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        // Show success message
        Get.snackbar(
          'Success',
          'Login successful!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );

        // Clear form
        emailController.clear();
        passwordController.clear();

        // Navigate to main app
        Get.offAll(() => CustomTabView());
      } else {
        throw Exception('Login failed - no user credential returned');
      }

    } catch (e) {
      print('Login error: $e');
      _handleLoginError(e);
    } finally {
      isLoading.value = false;
    }
  }

  void _handleLoginError(dynamic error) {
    String errorMessage = 'Login failed';

    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          errorMessage = 'No account found with this email/phone number.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed attempts. Please try again later.';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Please check your connection.';
          break;
        case 'invalid-credential':
          errorMessage = 'Invalid email/phone or password.';
          break;
        default:
          errorMessage = error.message ?? 'Login failed. Please try again.';
      }
    } else if (error.toString().contains('PigeonUserDetails') ||
        error.toString().contains('type cast')) {
      errorMessage = 'Authentication error. Please try again in a moment.';
    } else {
      errorMessage = 'An unexpected error occurred. Please try again.';
    }

    Get.snackbar(
      'Login Error',
      errorMessage,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );
  }

  void goToForgotPassword() {
    Get.toNamed('/forgot-password');
  }

  void loginWithGoogle() async {
    isLoading.value = true;
    try {
      Get.snackbar(
        'Info',
        'Google login coming soon!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      print('Google login error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void loginWithFacebook() {
    Get.snackbar(
      'Info',
      'Facebook login coming soon!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.withOpacity(0.8),
      colorText: Colors.white,
    );
  }

  void loginWithApple() {
    Get.snackbar(
      'Info',
      'Apple login coming soon!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.withOpacity(0.8),
      colorText: Colors.white,
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

// Mock UserCredential class for PigeonUserDetails workaround
class _MockUserCredential implements UserCredential {
  @override
  final User user;

  _MockUserCredential(this.user);

  @override
  AdditionalUserInfo? get additionalUserInfo => null;

  @override
  AuthCredential? get credential => null;
}

class LoginScreen extends StatelessWidget {
  final LoginController controller = Get.put(LoginController(), permanent: false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;
          final screenWidth = constraints.maxWidth;
          final isPortrait = screenHeight > screenWidth;
          final imageHeight = isPortrait ? screenHeight * 0.35 : screenHeight * 0.25;

          return Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: imageHeight,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      image: DecorationImage(
                        image: AssetImage('assets/images/authg.jpg'),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {
                          print('Image load error: $exception');
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: isPortrait ? 60 : 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: isPortrait
                      ? _buildFormContent(isPortrait)
                      : SingleChildScrollView(
                    child: _buildFormContent(isPortrait),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFormContent(bool isPortrait) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Welcome back',
          style: TextStyle(
            fontSize: isPortrait ? 28 : 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isPortrait ? 6 : 4),
        Text(
          'Login to your account',
          style: TextStyle(
            fontSize: isPortrait ? 14 : 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isPortrait ? 24 : 16),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(fontSize: isPortrait ? 14 : 12),
            decoration: InputDecoration(
              hintText: 'Enter email or phone',
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: isPortrait ? 14 : 12,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: isPortrait ? 16 : 12,
              ),
            ),
          ),
        ),
        Obx(() => controller.emailError.value != null
            ? Padding(
          padding: EdgeInsets.only(top: 4, left: 4),
          child: Text(
            controller.emailError.value!,
            style: TextStyle(
              color: Colors.red,
              fontSize: isPortrait ? 11 : 10,
            ),
          ),
        )
            : SizedBox.shrink()),
        SizedBox(height: isPortrait ? 12 : 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Obx(() => TextField(
            controller: controller.passwordController,
            obscureText: controller.obscurePassword.value,
            style: TextStyle(fontSize: isPortrait ? 14 : 12),
            decoration: InputDecoration(
              hintText: 'Password',
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: isPortrait ? 14 : 12,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: isPortrait ? 16 : 12,
              ),
              suffixIcon: IconButton(
                onPressed: controller.togglePasswordVisibility,
                icon: Icon(
                  controller.obscurePassword.value ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[600],
                  size: isPortrait ? 20 : 18,
                ),
              ),
            ),
          )),
        ),
        Obx(() => controller.passwordError.value != null
            ? Padding(
          padding: EdgeInsets.only(top: 4, left: 4),
          child: Text(
            controller.passwordError.value!,
            style: TextStyle(
              color: Colors.red,
              fontSize: isPortrait ? 11 : 10,
            ),
          ),
        )
            : SizedBox.shrink()),
        SizedBox(height: isPortrait ? 12 : 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Transform.scale(
                  scale: isPortrait ? 0.9 : 0.8,
                  child: Obx(() => Checkbox(
                    value: controller.rememberMe.value,
                    onChanged: (value) => controller.toggleRememberMe(),
                    activeColor: Color(0xFF1E5A96),
                    checkColor: Colors.white,
                  )),
                ),
                Text(
                  'Remember me',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: isPortrait ? 13 : 11,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: controller.goToForgotPassword,
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  color: Color(0xFF1E5A96),
                  fontSize: isPortrait ? 13 : 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: isPortrait ? 16 : 12),
        Container(
          width: double.infinity,
          height: isPortrait ? 48 : 42,
          child: Obx(() => ElevatedButton(
            onPressed: controller.isLoading.value ? null : controller.validateAndLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1E5A96),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
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
              'Login',
              style: TextStyle(
                fontSize: isPortrait ? 15 : 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          )),
        ),
        SizedBox(height: isPortrait ? 20 : 16),
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: isPortrait ? 12 : 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
          ],
        ),
        SizedBox(height: isPortrait ? 20 : 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(
              isPortrait: isPortrait,
              icon: Container(
                width: isPortrait ? 20 : 18,
                height: isPortrait ? 20 : 18,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage('https://developers.google.com/identity/images/g-logo.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              onPressed: controller.loginWithGoogle,
            ),
            SizedBox(width: isPortrait ? 16 : 12),
            _buildSocialButton(
              isPortrait: isPortrait,
              icon: Icon(
                Icons.facebook,
                size: isPortrait ? 26 : 22,
                color: Color(0xFF1877F2),
              ),
              onPressed: controller.loginWithFacebook,
            ),
            SizedBox(width: isPortrait ? 16 : 12),
            _buildSocialButton(
              isPortrait: isPortrait,
              icon: Icon(
                Icons.apple,
                size: isPortrait ? 26 : 22,
                color: Colors.black,
              ),
              onPressed: controller.loginWithApple,
            ),
          ],
        ),
        SizedBox(height: isPortrait ? 20 : 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an Account? ",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: isPortrait ? 13 : 11,
              ),
            ),
            TextButton(
              onPressed: () => Get.to(() => RegisterScreen()),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Register',
                style: TextStyle(
                  color: Color(0xFF1E5A96),
                  fontSize: isPortrait ? 13 : 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          ],
        ),
        SizedBox(height: isPortrait ? 20 : 16),
      ],
    );
  }

  Widget _buildSocialButton({
    required Widget icon,
    required VoidCallback onPressed,
    required bool isPortrait,
  }) {
    return Container(
      width: isPortrait ? 50 : 45,
      height: isPortrait ? 50 : 45,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
      ),
    );
  }
}