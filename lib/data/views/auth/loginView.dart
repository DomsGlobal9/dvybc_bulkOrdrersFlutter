import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Services/GoogleSignInService.dart';
import '../tabview/tabviews.dart';
import 'register.dart' hide Padding;

class LoginController extends GetxController {
  // Initialize controllers in onInit instead of at declaration
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  final RxBool rememberMe = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxnString emailError = RxnString();
  final RxnString passwordError = RxnString();
  final RxnString successMessage = RxnString();
  final RxBool isLoading = false.obs;

  // Add a flag to track disposal state
  bool _isDisposed = false;

  @override
  void onInit() {
    super.onInit();
    // Initialize controllers here to avoid disposal issues
    emailController = TextEditingController();
    passwordController = TextEditingController();
    _isDisposed = false;
  }

  void togglePasswordVisibility() {
    if (_isDisposed) return;
    obscurePassword.toggle();
  }

  void toggleRememberMe() {
    if (_isDisposed) return;
    rememberMe.toggle();
  }

  void clearMessages() {
    if (_isDisposed) return;
    emailError.value = null;
    passwordError.value = null;
    successMessage.value = null;
  }

  void validateAndLogin() {
    if (_isDisposed) return;
    clearMessages();

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    bool isValid = true;

    // Email validation
    if (email.isEmpty) {
      emailError.value = 'Email or Phone is required';
      isValid = false;
    } else if (GetUtils.isEmail(email)) {
      // Check if it's a valid email format
      if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
        emailError.value = 'Please enter a valid email address';
        isValid = false;
      }
    } else if (!GetUtils.isPhoneNumber(email)) {
      // If it's not an email, check if it's a valid phone number
      if (!RegExp(r'^[+]?[0-9]{10,15}$').hasMatch(email.replaceAll(' ', ''))) {
        emailError.value = 'Please enter a valid email or phone number';
        isValid = false;
      }
    }

    // Password validation
    if (password.isEmpty) {
      passwordError.value = 'Password is required';
      isValid = false;
    } else if (password.length < 6) {
      passwordError.value = 'Password must be at least 6 characters';
      isValid = false;
    }

    if (isValid) {
      _performLogin();
    }
  }

  // Safe Firebase Auth method that handles PigeonUserDetails error
  Future<UserCredential?> _safeFirebaseAuth(String email, String password) async {
    try {
      return await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      if (e.toString().contains('PigeonUserDetails') ||
          e.toString().contains('type cast') ||
          e.toString().contains('List<Object?>')) {
        print('PigeonUserDetails error detected, using workaround...');

        await Future.delayed(Duration(seconds: 1));

        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null && currentUser.email == email) {
          print('User authenticated successfully despite error');
          return _MockUserCredential(currentUser);
        }

        await Future.delayed(Duration(milliseconds: 500));
        try {
          return await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
        } catch (retryError) {
          print('Retry attempt failed: $retryError');
          User? retryUser = FirebaseAuth.instance.currentUser;
          if (retryUser != null && retryUser.email == email) {
            return _MockUserCredential(retryUser);
          }
        }
      }
      rethrow;
    }
  }

  Future<void> _performLogin() async {
    if (_isDisposed) return;

    isLoading.value = true;
    clearMessages();

    String input = emailController.text.trim();
    String password = passwordController.text.trim();

    try {
      UserCredential? cred;
      String emailToUse = input;

      if (GetUtils.isEmail(input)) {
        print('Logging in with email: $input');
        cred = await _safeFirebaseAuth(input, password);
      } else {
        print('Logging in with phone: $input');

        QuerySnapshot query = await FirebaseFirestore.instance
            .collection('B2BBulkOrders_users')
            .where('phone', isEqualTo: input)
            .limit(1)
            .get();

        if (query.docs.isEmpty) {
          String phoneWithPrefix = input.startsWith('+91') ? input : '+91$input';
          query = await FirebaseFirestore.instance
              .collection('B2BBulkOrders_users')
              .where('phone', isEqualTo: phoneWithPrefix)
              .limit(1)
              .get();
        }

        if (query.docs.isEmpty) {
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
          if (!_isDisposed) emailError.value = 'No account found with this phone number';
          return;
        }

        Map<String, dynamic> userData = query.docs.first.data() as Map<String, dynamic>;
        emailToUse = userData['email'] as String;
        print('Found email for phone: $emailToUse');

        cred = await _safeFirebaseAuth(emailToUse, password);
      }

      if (cred?.user != null) {
        print('Login successful: ${cred!.user!.uid}');

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        if (!_isDisposed) successMessage.value = 'Login successful! Redirecting...';

        // Wait a moment to show success message
        await Future.delayed(Duration(seconds: 1));

        if (!_isDisposed) {
          emailController.clear();
          passwordController.clear();
          clearMessages();
        }

        Get.offAll(() => CustomTabView());
      } else {
        if (!_isDisposed) passwordError.value = 'Login failed. Please try again.';
      }

    } catch (e) {
      print('Login error: $e');
      _handleLoginError(e);
    } finally {
      if (!_isDisposed) isLoading.value = false;
    }
  }

  void _handleLoginError(dynamic error) {
    if (_isDisposed) return;

    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          emailError.value = 'No account found with this email/phone';
          break;
        case 'wrong-password':
          passwordError.value = 'Incorrect password';
          break;
        case 'invalid-email':
          emailError.value = 'Invalid email address';
          break;
        case 'user-disabled':
          emailError.value = 'This account has been disabled';
          break;
        case 'too-many-requests':
          passwordError.value = 'Too many failed attempts. Try again later';
          break;
        case 'network-request-failed':
          emailError.value = 'Network error. Check your connection';
          break;
        case 'invalid-credential':
          passwordError.value = 'Invalid email/phone or password';
          break;
        default:
          passwordError.value = error.message ?? 'Login failed. Please try again';
      }
    } else if (error.toString().contains('PigeonUserDetails') ||
        error.toString().contains('type cast')) {
      passwordError.value = 'Authentication error. Please try again';
    } else {
      passwordError.value = 'An unexpected error occurred';
    }
  }

  void goToForgotPassword() {
    if (_isDisposed) return;
    Get.toNamed('/forgot-password');
  }

  // Fixed Google Login Method
  // Updated loginWithGoogle method for LoginController
// Replace the existing method with this one

  void loginWithGoogle() async {
    if (_isDisposed) return;

    isLoading.value = true;
    clearMessages();

    try {
      print('Starting Google login...');

      final UserCredential? credential = await GoogleSignInService.signInWithGoogle();

      if (credential?.user != null) {
        print('Google login successful: ${credential!.user!.uid}');

        // Check if user exists in our B2BBulkOrders_users collection
        const String collectionName = 'B2BBulkOrders_users';
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection(collectionName)
            .doc(credential.user!.uid)
            .get();

        if (!userDoc.exists) {
          // User doesn't exist in our database - they need to register first
          print('User not found in database - redirecting to register');

          // Sign out the user since they're not registered
          await GoogleSignInService.signOut();

          if (!_isDisposed) {
            emailError.value = 'Account not found. Please register first with Google.';
          }
          return;
        }

        // User exists - update their login info
        await _updateGoogleUserData(credential.user!);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        if (!_isDisposed) {
          successMessage.value = 'Google login successful! Redirecting...';

          await Future.delayed(Duration(seconds: 1));

          emailController.clear();
          passwordController.clear();
          clearMessages();

          Get.offAll(() => CustomTabView());
        }
      }
    } catch (e) {
      print('Google login error: $e');
      _handleGoogleLoginError(e);
    } finally {
      if (!_isDisposed) isLoading.value = false;
    }
  }

// Add this new method to LoginController
  Future<void> _updateGoogleUserData(User user) async {
    try {
      const String collectionName = 'B2BBulkOrders_users';

      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(user.uid)
          .update({
        'updatedAt': FieldValue.serverTimestamp(),
        'signInMethod': 'google',
      });

      print('Google user login info updated');
    } catch (e) {
      print('Error updating user data: $e');
      // Don't throw error for update failures - login should still work
    }
  }

  void _handleGoogleLoginError(dynamic error) {
    if (_isDisposed) return;

    if (error.toString().contains('account-exists-with-different-credential')) {
      emailError.value = 'This email is registered with a different sign-in method. Try email/password login.';
    } else if (error.toString().contains('network-request-failed')) {
      emailError.value = 'Network error. Check your connection';
    } else if (error.toString().contains('sign_in_canceled')) {
      return; // User canceled - no error needed
    } else {
      passwordError.value = 'Google login failed. Please try again';
    }
  }

  void loginWithFacebook() {
    if (_isDisposed) return;
    successMessage.value = 'Facebook login coming soon!';
    Future.delayed(Duration(seconds: 2), () {
      if (!_isDisposed) successMessage.value = null;
    });
  }

  void loginWithApple() {
    if (_isDisposed) return;
    successMessage.value = 'Apple login coming soon!';
    Future.delayed(Duration(seconds: 2), () {
      if (!_isDisposed) successMessage.value = null;
    });
  }

  @override
  void onClose() {
    _isDisposed = true;

    // Only dispose if controllers are initialized and not already disposed
    try {
      if (emailController.hasListeners || emailController.text.isNotEmpty) {
        emailController.dispose();
      }
    } catch (e) {
      print('Email controller already disposed: $e');
    }

    try {
      if (passwordController.hasListeners || passwordController.text.isNotEmpty) {
        passwordController.dispose();
      }
    } catch (e) {
      print('Password controller already disposed: $e');
    }

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
  // Create a fresh controller instance each time
  @override
  Widget build(BuildContext context) {
    // Use Get.put with tag to ensure fresh instance
    final LoginController controller = Get.put(
        LoginController(),
        tag: DateTime.now().millisecondsSinceEpoch.toString(),
        permanent: false
    );

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                _buildHeaderImage(context),
                Expanded(
                  child: _buildScrollableContent(context, controller),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderImage(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = keyboardHeight > 0;

    final imageHeight = isKeyboardOpen
        ? screenHeight * 0.15
        : screenHeight * 0.35;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: imageHeight,
      width: double.infinity,
      child: Stack(
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
              height: 40,
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
    );
  }

  Widget _buildScrollableContent(BuildContext context, LoginController controller) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: _buildFormContent(controller),
      ),
    );
  }

  Widget _buildFormContent(LoginController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 10),
        Text(
          'Welcome back',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 6),
        Text(
          'Login to your account',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 24),

        // Success Message
        Obx(() => controller.successMessage.value != null
            ? Container(
          margin: EdgeInsets.only(bottom: 16),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            border: Border.all(color: Colors.green[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  controller.successMessage.value!,
                  style: TextStyle(color: Colors.green[800], fontSize: 13),
                ),
              ),
            ],
          ),
        )
            : SizedBox.shrink()),

        // Email/Phone Field
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: controller.emailError.value != null
                  ? Colors.red
                  : Colors.grey[300]!,
            ),
          ),
          child: TextField(
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) {
              if (controller.emailError.value != null) {
                controller.clearMessages();
              }
            },
            style: TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Enter email or phone',
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              suffixIcon: controller.emailError.value != null
                  ? Icon(Icons.error, color: Colors.red, size: 20)
                  : null,
            ),
          ),
        ),
        Obx(() => controller.emailError.value != null
            ? Container(
          margin: EdgeInsets.only(top: 6, left: 4),
          child: Row(
            children: [
              Icon(Icons.info, color: Colors.red, size: 14),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  controller.emailError.value!,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        )
            : SizedBox.shrink()),

        SizedBox(height: 16),

        // Password Field
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: controller.passwordError.value != null
                  ? Colors.red
                  : Colors.grey[300]!,
            ),
          ),
          child: Obx(() => TextField(
            controller: controller.passwordController,
            obscureText: controller.obscurePassword.value,
            onChanged: (value) {
              if (controller.passwordError.value != null) {
                controller.clearMessages();
              }
            },
            style: TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Password',
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (controller.passwordError.value != null)
                    Icon(Icons.error, color: Colors.red, size: 20),
                  IconButton(
                    onPressed: controller.togglePasswordVisibility,
                    icon: Icon(
                      controller.obscurePassword.value
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          )),
        ),
        Obx(() => controller.passwordError.value != null
            ? Container(
          margin: EdgeInsets.only(top: 6, left: 4),
          child: Row(
            children: [
              Icon(Icons.info, color: Colors.red, size: 14),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  controller.passwordError.value!,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        )
            : SizedBox.shrink()),

        SizedBox(height: 16),

        // Remember me and Forgot password row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Transform.scale(
                  scale: 0.9,
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
                    fontSize: 13,
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
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 20),

        // Login Button
        Container(
          width: double.infinity,
          height: 48,
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
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          )),
        ),

        SizedBox(height: 24),

        // OR divider
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
          ],
        ),

        SizedBox(height: 24),

        // Social login buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(
              icon: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage('https://developers.google.com/identity/images/g-logo.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              onPressed: controller.loginWithGoogle,
            ),
            SizedBox(width: 16),
            _buildSocialButton(
              icon: Icon(
                Icons.facebook,
                size: 26,
                color: Color(0xFF1877F2),
              ),
              onPressed: controller.loginWithFacebook,
            ),
            SizedBox(width: 16),
            _buildSocialButton(
              icon: Icon(
                Icons.apple,
                size: 26,
                color: Colors.black,
              ),
              onPressed: controller.loginWithApple,
            ),
          ],
        ),

        SizedBox(height: 24),

        // Register link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an Account? ",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
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
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          ],
        ),

        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSocialButton({
    required Widget icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 50,
      height: 50,
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