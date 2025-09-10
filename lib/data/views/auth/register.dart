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

  void togglePasswordVisibility() {
    obscurePassword.toggle();
  }

  bool _validateInputs() {
    if (nameController.text.trim().isEmpty) {
      _showError('Please enter your name');
      return false;
    }

    if (emailController.text.trim().isEmpty || !GetUtils.isEmail(emailController.text.trim())) {
      _showError('Please enter a valid email');
      return false;
    }

    if (phoneController.text.trim().isEmpty) {
      _showError('Please enter your phone number');
      return false;
    }

    if (passwordController.text.trim().length < 6) {
      _showError('Password must be at least 6 characters');
      return false;
    }

    return true;
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );
  }

  // Safe Firebase Auth registration method that handles PigeonUserDetails error
  Future<UserCredential?> _safeFirebaseRegistration(String email, String password) async {
    try {
      // Try normal Firebase Auth registration
      return await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      // If PigeonUserDetails error occurs, try alternative approach
      if (e.toString().contains('PigeonUserDetails') ||
          e.toString().contains('type cast') ||
          e.toString().contains('List<Object?>')) {
        print('PigeonUserDetails error detected during registration, using workaround...');

        // Wait a moment and check if user was actually created
        await Future.delayed(Duration(seconds: 1));

        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null && currentUser.email == email) {
          print('User created successfully despite error');
          // Create a simple wrapper since user is actually created
          return _MockUserCredential(currentUser);
        }

        // If workaround didn't work, try one more time with a delay
        await Future.delayed(Duration(milliseconds: 500));
        try {
          return await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
        } catch (retryError) {
          print('Retry attempt failed: $retryError');
          // Check again if user is created
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

  Future<void> register() async {
    if (!_validateInputs()) return;

    isLoading.value = true;

    try {
      print('Starting registration process...');

      // Create user with Firebase Auth using safe method
      print('Creating user with email and password...');
      final credential = await _safeFirebaseRegistration(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (credential?.user != null) {
        print('User created successfully: ${credential!.user!.uid}');

        // Store user data in Firestore
        await _storeUserData(credential.user!);

        // Sign out the user after registration
        await FirebaseAuth.instance.signOut();
        print('User signed out after registration');

        // Clear form
        _clearForm();

        // Show success message and navigate to login
        _showSuccess('Account created successfully! Please login to continue.');

        // Navigate to login page
        await Future.delayed(Duration(milliseconds: 1500));
        Get.offAllNamed('/login');
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

    print('Storing user data in Firestore...');

    try {
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(user.uid)
          .set(userData);

      // Verify the document was created
      final doc = await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(user.uid)
          .get();

      if (doc.exists) {
        print('Document verified in Firestore');
      } else {
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
  }

  void _handleRegistrationError(dynamic error) {
    String errorMessage = 'An unexpected error occurred';

    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          errorMessage = 'The account already exists for that email.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Please check your connection.';
          break;
        default:
          errorMessage = error.message ?? 'Registration failed';
      }
    } else if (error.toString().contains('PigeonUserDetails') ||
        error.toString().contains('type cast')) {
      errorMessage = 'Registration error. Please try again in a moment.';
    } else {
      errorMessage = 'Error: ${error.toString()}';
    }

    _showError(errorMessage);
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

class RegisterScreen extends StatelessWidget {
  final RegisterController controller = Get.put(RegisterController(), permanent: false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ClipPath(
            clipper: CurvedClipper(),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.3,
              width: double.infinity,
              child: Image.asset(
                'assets/images/girllss.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Color(0xFF204664),
                    child: Center(
                      child: Icon(Icons.image, size: 50, color: Colors.white),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.3),
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  children: [
                    Text(
                      "Register",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Create your new account",
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 16,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    SizedBox(height: 20),
                    buildTextField("Name", false, controller.nameController),
                    buildTextField("E-mail", false, controller.emailController),
                    buildTextField("Phone", false, controller.phoneController),
                    Obx(() => buildTextField("Password", controller.obscurePassword.value, controller.passwordController)),
                    SizedBox(height: 28),
                    Obx(() => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF204664),
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                        onPressed: controller.isLoading.value ? null : controller.register,
                        child: controller.isLoading.value
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text("Sign Up", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, fontFamily: 'Outfit', color: Colors.white)),
                      ),
                    )),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text("OR", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        socialButton(Icons.g_translate, () {
                          Get.snackbar('Info', 'Google registration coming soon!',
                              backgroundColor: Colors.blue.withOpacity(0.8),
                              colorText: Colors.white);
                        }),
                        SizedBox(width: 18),
                        socialButton(Icons.facebook, () {
                          Get.snackbar('Info', 'Facebook registration coming soon!',
                              backgroundColor: Colors.blue.withOpacity(0.8),
                              colorText: Colors.white);
                        }),
                        SizedBox(width: 18),
                        socialButton(Icons.apple, () {
                          Get.snackbar('Info', 'Apple registration coming soon!',
                              backgroundColor: Colors.blue.withOpacity(0.8),
                              colorText: Colors.white);
                        }),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an Account? ", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
                        GestureDetector(
                          onTap: () => Get.offNamed('/login'),
                          child: Text("Login", style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField(String hint, bool obscure, TextEditingController textController) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7),
      child: TextField(
        controller: textController,
        obscureText: obscure,
        keyboardType: hint == "E-mail" ? TextInputType.emailAddress :
        hint == "Phone" ? TextInputType.phone :
        TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 15),
          hintStyle: TextStyle(fontFamily: 'Outfit', fontSize: 15, fontWeight: FontWeight.w300),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(6),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(6),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.circular(6),
          ),
          suffixIcon: hint == "Password"
              ? IconButton(
            icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
            onPressed: controller.togglePasswordVisibility,
          )
              : null,
        ),
      ),
    );
  }

  Widget socialButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(icon, color: Colors.black),
        radius: 18,
      ),
    );
  }
}

class SuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ClipPath(
            clipper: CurvedClipper(),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.3,
              width: double.infinity,
              child: Image.asset(
                'assets/images/girllss.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Color(0xFF204664),
                    child: Center(
                      child: Icon(Icons.image, size: 50, color: Colors.white),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.2),
            child: Column(
              children: [
                Spacer(),
                Text(
                  "Your Account is Created\nSuccessfully !",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: 180,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF204664),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                    onPressed: () => Get.offNamed('/login'),
                    child: Text("Login", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, fontFamily: 'Outfit', color: Colors.white)),
                  ),
                ),
                Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 60);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(oldClipper) => false;
}