import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

// ================= ENHANCED AUTH VIEW MODEL =================
class AuthViewModel extends GetxController {
  // Published properties equivalent
  final Rx<User?> userSession = Rx<User?>(null);
  final Rx<AppUser?> currentUser = Rx<AppUser?>(null);
  final RxBool isError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isLoading = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    loadCurrentUser();
    _testFirebaseConfiguration();
  }

  // Test Firebase configuration on startup
  Future<void> _testFirebaseConfiguration() async {
    try {
      print('🔥 Firebase Project ID: ${Firebase.app().options.projectId}');
      print('📱 App ID: ${Firebase.app().options.appId}');
      print('🌐 API Key exists: ${Firebase.app().options.apiKey.isNotEmpty}');
    } catch (e) {
      print('❌ Firebase config test failed: $e');
    }
  }

  Future<void> loadCurrentUser() async {
    if (_auth.currentUser != null) {
      userSession.value = _auth.currentUser;
      await fetchUser(by: _auth.currentUser!.uid);
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isError.value = false;
      isLoading.value = true;

      UserCredential authResult = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password
      );
      userSession.value = authResult.user;
      await fetchUser(by: authResult.user!.uid);

      isLoading.value = false;
    } catch (error) {
      isError.value = true;
      isLoading.value = false;
      errorMessage.value = error.toString();
    }
  }

  Future<void> createUser(String email, String fullName, String password) async {
    try {
      isError.value = false;
      isLoading.value = true;

      // Create user in Firebase Auth
      UserCredential authResult = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );
      // Store additional user details in Firestore
      await storeUserInFirestore(
          uid: authResult.user!.uid,
          email: email,
          fullName: fullName
      );

      isLoading.value = false;
    } catch (error) {
      isError.value = true;
      isLoading.value = false;
      errorMessage.value = error.toString();
    }
  }

  Future<void> storeUserInFirestore({
    required String uid,
    required String email,
    required String fullName
  }) async {
    final user = AppUser(uid: uid, email: email, fullName: fullName);
    try {
      await _firestore.collection("users").doc(uid).set(user.toMap());
    } catch (error) {
      isError.value = true;
      errorMessage.value = error.toString();
    }
  }

  Future<void> fetchUser({required String by}) async {
    try {
      isError.value = false;
      DocumentSnapshot document = await _firestore.collection("users").doc(by).get();
      if (document.exists) {
        currentUser.value = AppUser.fromMap(document.data() as Map<String, dynamic>);
      }
    } catch (error) {
      isError.value = true;
      errorMessage.value = error.toString();
    }
  }

  void signOut() {
    try {
      userSession.value = null;
      currentUser.value = null;
      _auth.signOut();
    } catch (error) {
      isError.value = true;
      errorMessage.value = error.toString();
    }
  }

  Future<void> deleteAccount() async {
    try {
      userSession.value = null;
      currentUser.value = null;
      await deleteUser(by: _auth.currentUser?.uid ?? "");
      await _auth.currentUser?.delete(); // Remove from Firebase Auth
    } catch (error) {
      isError.value = true;
      errorMessage.value = error.toString();
    }
  }

  Future<void> deleteUser({required String by}) async {
    await _firestore.collection("users").doc(by).delete();
  }

  // ENHANCED RESET PASSWORD FUNCTION - This should fix the email delivery issue
  Future<bool> resetPassword({required String by}) async {
    try {
      isError.value = false;
      errorMessage.value = '';
      isLoading.value = true;

      print('🚀 Starting enhanced password reset process...');
      print('📧 Email: $by');
      print('🔥 Project ID: ${Firebase.app().options.projectId}');

      // Step 1: Validate email format
      if (!GetUtils.isEmail(by)) {
        throw Exception('Invalid email format');
      }

      // Step 2: Check if user exists (this is crucial!)
      List<String> methods = await _auth.fetchSignInMethodsForEmail(by);
      print('🔍 Sign-in methods found: $methods');

      if (methods.isEmpty) {
        isError.value = true;
        errorMessage.value = 'No account found with this email address';
        isLoading.value = false;
        return false;
      }

      print('✅ User exists, proceeding with reset email...');

      // Step 3: Send password reset email with enhanced configuration
      await _auth.sendPasswordResetEmail(
        email: by,
        actionCodeSettings: ActionCodeSettings(
          // Use your Firebase project's default URL
          url: 'https://${Firebase.app().options.projectId}.firebaseapp.com/__/auth/action',
          handleCodeInApp: false,
          // Add your package names (replace with your actual package names)
          androidPackageName: 'com.example.flutter_dvybc',
          iOSBundleId: 'com.example.flutter-dvybc',
          // Allow app installation if not installed
          androidInstallApp: false,
          androidMinimumVersion: '1.0',
        ),
      );

      print('✅ SUCCESS: Password reset email sent!');
      print('📬 Email should arrive from: noreply@${Firebase.app().options.projectId}.firebaseapp.com');
      print('⏰ Expected delivery: 1-5 minutes');
      print('📂 Check these locations:');
      print('   - Gmail Primary inbox');
      print('   - Gmail Spam/Junk folder');
      print('   - Gmail Promotions tab');
      print('   - Search for "firebase" or "password"');

      isLoading.value = false;
      return true;

    } on FirebaseAuthException catch (e) {
      isError.value = true;
      isLoading.value = false;

      print('🔥 FirebaseAuthException: ${e.code}');
      print('💬 Message: ${e.message}');

      switch (e.code) {
        case 'user-not-found':
          errorMessage.value = 'No account found with this email address. Please sign up first.';
          break;
        case 'invalid-email':
          errorMessage.value = 'Invalid email address format.';
          break;
        case 'too-many-requests':
          errorMessage.value = 'Too many reset attempts. Please wait 10 minutes and try again.';
          break;
        case 'network-request-failed':
          errorMessage.value = 'Network error. Please check your internet connection.';
          break;
        case 'app-not-authorized':
          errorMessage.value = 'App not authorized. Please contact support.';
          print('🚫 Check Firebase Console > Authentication > Settings > Authorized domains');
          break;
        default:
          errorMessage.value = e.message ?? 'Failed to send reset email. Please try again.';
          break;
      }

      return false;

    } catch (error) {
      isError.value = true;
      isLoading.value = false;
      errorMessage.value = 'Unexpected error: ${error.toString()}';
      print('❌ Unexpected error: $error');
      return false;
    }
  }

  // Additional method to test email sending with a known test address
  Future<void> testEmailWithFirebaseAccount() async {
    try {
      print('🧪 Testing with Firebase test account...');

      // This is a test to see if Firebase email service is working
      await _auth.sendPasswordResetEmail(email: 'test@example.com');
      print('✅ Firebase email service is working (even though user doesn\'t exist)');

    } catch (e) {
      print('🔍 Firebase test result: $e');
      if (e.toString().contains('user-not-found')) {
        print('✅ This is expected - Firebase email service is working');
      } else {
        print('❌ Firebase email service may have issues: $e');
      }
    }
  }

  // Method to check Firebase configuration
  void checkFirebaseConfiguration() {
    try {
      print('🔧 Firebase Configuration Check:');
      print('   Project ID: ${Firebase.app().options.projectId}');
      print('   App ID: ${Firebase.app().options.appId}');
      print('   API Key exists: ${Firebase.app().options.apiKey.isNotEmpty}');
      print('   Auth domain: ${Firebase.app().options.authDomain}');

      if (Firebase.app().options.projectId.isEmpty) {
        print('❌ Project ID is empty - check google-services.json');
      }

      if (Firebase.app().options.apiKey.isEmpty) {
        print('❌ API Key is empty - check google-services.json');
      }

    } catch (e) {
      print('❌ Firebase config check failed: $e');
    }
  }
}

// ================= USER MODEL =================
class AppUser {
  final String uid;
  final String email;
  final String fullName;

  AppUser({
    required this.uid,
    required this.email,
    required this.fullName,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
    );
  }
}

// ================= ENHANCED FORGOT PASSWORD VIEW =================
class ForgotPasswordView extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();

  // Get the AuthViewModel instance
  AuthViewModel get authViewModel => Get.find<AuthViewModel>();

  ForgotPasswordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        actions: [
          // Debug button
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.grey),
            onPressed: () {
              authViewModel.checkFirebaseConfiguration();
              authViewModel.testEmailWithFirebaseAccount();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and description
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reset Password',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Enter the email associated with your account and we\'ll send an email with instructions to reset your password',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF666666),
                    fontFamily: 'Outfit',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Email input
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8E8E8)),
                color: const Color(0xFFF9F9F9),
              ),
              child: TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Outfit',
                ),
                decoration: const InputDecoration(
                  hintText: 'Enter your email',
                  hintStyle: TextStyle(
                    color: Color(0xFF999999),
                    fontFamily: 'Outfit',
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),

            // Error message
            Obx(() => authViewModel.isError.value
                ? Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                authViewModel.errorMessage.value,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontFamily: 'Outfit',
                ),
              ),
            )
                : const SizedBox.shrink()),

            const SizedBox(height: 16),

            // Send Instructions button with loading state
            Obx(() => SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: authViewModel.isLoading.value
                    ? null
                    : () async {
                  String email = _emailController.text.trim();

                  if (email.isEmpty) {
                    Get.snackbar(
                      'Error',
                      'Please enter your email address',
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                    return;
                  }

                  // Enhanced reset password call
                  bool success = await authViewModel.resetPassword(by: email);

                  if (success) {
                    // Navigate to success screen
                    Get.to(() => const EmailSentView(), arguments: email);
                  } else {
                    // Error message already set in AuthViewModel
                    Get.snackbar(
                      'Error',
                      authViewModel.errorMessage.value,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 5),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E96),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: authViewModel.isLoading.value
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Send Instructions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Outfit',
                  ),
                ),
              ),
            )),

            const Spacer(),

            // Debug info (remove in production)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Troubleshooting Tips:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '• Make sure the email exists in Firebase Auth\n'
                        '• Check Gmail spam/junk folder\n'
                        '• Wait 5-10 minutes for delivery\n'
                        '• Try the settings button (top right) for diagnostics',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Outfit',
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

// ================= EMAIL SENT VIEW =================
class EmailSentView extends StatelessWidget {
  const EmailSentView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String email = Get.arguments ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Spacer(),

            // Email icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.email,
                size: 50,
                color: Colors.teal,
              ),
            ),

            const SizedBox(height: 24),

            // Title and description
            const Column(
              children: [
                Text(
                  'Check your email',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'We have sent a password recover instructions to your email.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF666666),
                    fontFamily: 'Outfit',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Skip button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Get.until((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E96),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Skip, I\'ll confirm later',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Outfit',
                  ),
                ),
              ),
            ),

            const Spacer(),

            // Resend/try again text
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(fontSize: 14, fontFamily: 'Outfit'),
                  children: [
                    TextSpan(
                      text: 'Did not receive the email? Check your spam filter, or ',
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextSpan(
                      text: 'try another email address',
                      style: TextStyle(color: Colors.teal),
                    ),
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