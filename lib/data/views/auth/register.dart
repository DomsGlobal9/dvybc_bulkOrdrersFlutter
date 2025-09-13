import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool obscurePassword = true.obs;
  final RxBool isLoading = false.obs;
  final RxnString nameError = RxnString();
  final RxnString emailError = RxnString();
  final RxnString phoneError = RxnString();
  final RxnString passwordError = RxnString();

  void togglePasswordVisibility() {
    obscurePassword.toggle();
  }

  void clearErrors() {
    nameError.value = null;
    emailError.value = null;
    phoneError.value = null;
    passwordError.value = null;
  }

  bool _validateInputs() {
    clearErrors();
    bool isValid = true;

    if (nameController.text.trim().isEmpty) {
      nameError.value = 'Please enter your name';
      isValid = false;
    }

    String email = emailController.text.trim();
    if (email.isEmpty) {
      emailError.value = 'Please enter your email';
      isValid = false;
    } else if (!GetUtils.isEmail(email)) {
      emailError.value = 'Please enter a valid email address';
      isValid = false;
    }

    if (phoneController.text.trim().isEmpty) {
      phoneError.value = 'Please enter your phone number';
      isValid = false;
    } else if (!RegExp(r'^[0-9]{10}$').hasMatch(phoneController.text.trim())) {
      phoneError.value = 'Please enter a valid 10-digit phone number';
      isValid = false;
    }

    if (passwordController.text.trim().length < 6) {
      passwordError.value = 'Password must be at least 6 characters';
      isValid = false;
    }

    return isValid;
  }

  Future<UserCredential?> _safeFirebaseRegistration(String email, String password) async {
    try {
      return await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      if (e.toString().contains('PigeonUserDetails') ||
          e.toString().contains('type cast') ||
          e.toString().contains('List<Object?>')) {
        print('PigeonUserDetails error detected during registration, using workaround...');

        await Future.delayed(Duration(seconds: 1));

        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null && currentUser.email == email) {
          print('User created successfully despite error');
          return _MockUserCredential(currentUser);
        }

        await Future.delayed(Duration(milliseconds: 500));
        try {
          return await FirebaseAuth.instance.createUserWithEmailAndPassword(
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

  Future<void> register() async {
    if (!_validateInputs()) return;

    isLoading.value = true;

    try {
      print('Starting registration process...');

      final credential = await _safeFirebaseRegistration(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (credential?.user != null) {
        print('User created successfully: ${credential!.user!.uid}');

        await _storeUserData(credential.user!);
        await FirebaseAuth.instance.signOut();
        print('User signed out after registration');

        _clearForm();

        // Navigate to success screen
        Get.to(() => SuccessScreen());
      } else {
        throw Exception('Registration failed - no user credential returned');
      }

    } catch (e) {
      print('Registration error: $e');
      _handleRegistrationError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _storeUserData(User user) async {
    const String collectionName = 'B2BBulkOrders_users';

    final userData = {
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'phone': phoneController.text.trim(),
      'gender': '',
      'dob': '',
      'profileImageUrl': '',
      'uid': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(user.uid)
          .set(userData);

      final doc = await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        throw Exception('Failed to store user data in Firestore');
      }
    } catch (e) {
      print('Firestore error: $e');
      throw Exception('Failed to save user data: $e');
    }
  }

  void _clearForm() {
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    passwordController.clear();
    clearErrors();
  }

  void _handleRegistrationError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'weak-password':
          passwordError.value = 'The password provided is too weak';
          break;
        case 'email-already-in-use':
          emailError.value = 'Account already exists for this email';
          break;
        case 'invalid-email':
          emailError.value = 'The email address is not valid';
          break;
        case 'network-request-failed':
          emailError.value = 'Network error. Check your connection';
          break;
        default:
          passwordError.value = error.message ?? 'Registration failed';
      }
    } else if (error.toString().contains('PigeonUserDetails') ||
        error.toString().contains('type cast')) {
      passwordError.value = 'Registration error. Please try again';
    } else {
      passwordError.value = 'An unexpected error occurred';
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

class _MockUserCredential implements UserCredential {
  @override
  final User user;

  _MockUserCredential(this.user);

  @override
  AdditionalUserInfo? get additionalUserInfo => null;

  @override
  AuthCredential? get credential => null;
}

class RegisterScreen extends StatelessWidget {
  final RegisterController controller = Get.put(RegisterController(), permanent: false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // Header Image Section
            _buildHeaderImage(context),
            // Scrollable Content Section
            Expanded(
              child: _buildScrollableContent(context),
            ),
          ],
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
          ClipPath(
            clipper: CurvedClipper(),
            child: Container(
              height: imageHeight,
              width: double.infinity,
              child: Image.asset(
                'assets/images/girllss.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Color(0xFF1E5A96),
                    child: Center(
                      child: Icon(Icons.image, size: 50, color: Colors.white),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableContent(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        padding: EdgeInsets.only(
          left: 30,
          right: 30,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: _buildFormContent(),
      ),
    );
  }

  Widget _buildFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 30),

        // Title
        Text(
          'Register',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: 'Outfit',
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 8),

        // Subtitle
        Text(
          'Create your new account',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
            fontFamily: 'Outfit',
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 30),

        // Name Field
        _buildTextField(
          hintText: 'Name',
          controller: controller.nameController,
          errorObservable: controller.nameError,
          keyboardType: TextInputType.text,
        ),

        // Email Field
        _buildTextField(
          hintText: 'E-mail',
          controller: controller.emailController,
          errorObservable: controller.emailError,
          keyboardType: TextInputType.emailAddress,
        ),

        // Phone Field
        _buildTextField(
          hintText: 'Phone',
          controller: controller.phoneController,
          errorObservable: controller.phoneError,
          keyboardType: TextInputType.phone,
        ),

        // Password Field
        Obx(() => _buildTextField(
          hintText: 'Password',
          controller: controller.passwordController,
          errorObservable: controller.passwordError,
          keyboardType: TextInputType.text,
          obscureText: controller.obscurePassword.value,
          suffixIcon: IconButton(
            icon: Icon(
              controller.obscurePassword.value
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: Colors.grey[600],
              size: 20,
            ),
            onPressed: controller.togglePasswordVisibility,
          ),
        )),

        SizedBox(height: 12),

        // Terms and Privacy Text
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: 'By signing up you agree to our ',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontFamily: 'Outfit',
            ),
            children: [
              TextSpan(
                text: 'Terms & Conditions',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                  fontFamily: 'Outfit',
                  decoration: TextDecoration.underline,
                ),
              ),
              TextSpan(
                text: ' and ',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontFamily: 'Outfit',
                ),
              ),
              TextSpan(
                text: 'Privacy Policy',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                  fontFamily: 'Outfit',
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 30),

        // Sign Up Button
        Container(
          width: double.infinity,
          height: 50,
          child: Obx(() => ElevatedButton(
            onPressed: controller.isLoading.value ? null : controller.register,
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
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            )
                : Text(
              'Sign Up',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Outfit',
              ),
            ),
          )),
        ),

        SizedBox(height: 25),

        // OR Divider
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: Colors.grey[300],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'OR',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Outfit',
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: Colors.grey[300],
              ),
            ),
          ],
        ),

        SizedBox(height: 25),

        // Social Login Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage('https://developers.google.com/identity/images/g-logo.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              onTap: () {
                // Google registration logic
              },
            ),
            SizedBox(width: 25),
            _buildSocialButton(
              child: Icon(
                Icons.facebook,
                color: Color(0xFF1877F2),
                size: 28,
              ),
              onTap: () {
                // Facebook registration logic
              },
            ),
            SizedBox(width: 25),
            _buildSocialButton(
              child: Icon(
                Icons.apple,
                color: Colors.black,
                size: 28,
              ),
              onTap: () {
                // Apple registration logic
              },
            ),
          ],
        ),

        SizedBox(height: 25),

        // Already have account text
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already have an Account? ',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontFamily: 'Outfit',
              ),
            ),
            GestureDetector(
              onTap: () => Get.offNamed('/login'),
              child: Text(
                'Login',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Outfit',
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 30),
      ],
    );
  }

  Widget _buildTextField({
    required String hintText,
    required TextEditingController controller,
    required RxnString errorObservable,
    required TextInputType keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: errorObservable.value != null
                  ? Colors.red
                  : Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            onChanged: (value) {
              if (errorObservable.value != null) {
                errorObservable.value = null;
              }
            },
            style: TextStyle(
              fontSize: 15,
              fontFamily: 'Outfit',
              color: Colors.black,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: 15,
                fontWeight: FontWeight.w300,
                fontFamily: 'Outfit',
              ),
              filled: true,
              fillColor: Colors.white,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              suffixIcon: suffixIcon,
            ),
          ),
        ),
        Obx(() => errorObservable.value != null
            ? Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(Icons.error, color: Colors.red, size: 14),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  errorObservable.value!,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontFamily: 'Outfit',
                  ),
                ),
              ),
            ],
          ),
        )
            : SizedBox(height: 8)),
      ],
    );
  }

  Widget _buildSocialButton({
    required Widget child,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}

class SuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header Image Section
            Container(
              height: MediaQuery.of(context).size.height * 0.35,
              width: double.infinity,
              child: ClipPath(
                clipper: CurvedClipper(),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: double.infinity,
                  child: Image.asset(
                    'assets/images/girllss.jpg',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Color(0xFF1E5A96),
                        child: Center(
                          child: Icon(Icons.image, size: 50, color: Colors.white),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Success Content
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Spacer(flex: 2),

                    // Success Text
                    Text(
                      'Your Account is Created\nSuccessfully !',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'Outfit',
                        height: 1.3,
                      ),
                    ),

                    SizedBox(height: 40),

                    // Login Button
                    Container(
                      width: 180,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => Get.offNamed('/login'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1E5A96),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ),
                    ),

                    Spacer(flex: 3),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 60,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(oldClipper) => false;
}