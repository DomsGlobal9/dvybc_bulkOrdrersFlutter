import 'package:flutter/material.dart';
import 'package:flutter_dvybc/data/views/Widgets/CustomDVYBAppBarWithBack.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ProfileSettingsView.dart';
import 'MyOrders/MyOrderView.dart';
import 'AboutView.dart';
import 'SupportView.dart';
import '../tabview/tabviews.dart';

// Profile Controller
class ProfileController extends GetxController {
  // Observable variables
  var userName = 'Loading...'.obs;
  var userEmail = ''.obs;
  var userProfileImage = ''.obs;
  var isLoading = true.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  // Load user data from Firebase - same logic as ProfileSettingsController
  void loadUserData() async {
    try {
      isLoading.value = true;

      String? uid = _auth.currentUser?.uid;
      if (uid == null) {
        print('No user logged in');
        userName.value = 'User';
        return;
      }

      userEmail.value = _auth.currentUser?.email ?? '';

      // First try the B2BBulkOrders_users collection
      DocumentSnapshot userDoc = await _firestore
          .collection('B2BBulkOrders_users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        userName.value = userData['name'] ?? 'User';
        userProfileImage.value = userData['profileImageUrl'] ?? '';
      } else {
        // Try alternative collection name
        userDoc = await _firestore
            .collection('Bulk')
            .doc(uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          userName.value = userData['name'] ?? 'User';
          userProfileImage.value = userData['profileImageUrl'] ?? '';
        } else {
          // Fallback to Firebase Auth data
          User? currentUser = _auth.currentUser;
          if (currentUser != null) {
            userName.value = currentUser.displayName ?? 'User';
            userProfileImage.value = currentUser.photoURL ?? '';
          } else {
            userName.value = 'User';
          }
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      userName.value = 'User';
    } finally {
      isLoading.value = false;
    }
  }

  // Navigate to profile settings
  void navigateToProfileSettings() {
    Get.to(() => ProfileSettingsView());
  }

  // Navigate to orders
  void navigateToOrders() {
    Get.to(() => MyOrderView());
  }

  // Navigate to about
  void navigateToAbout() {
    Get.to(() => AboutView());
  }

  // Navigate to support
  void navigateToSupport() {
    Get.to(() => SupportView());
  }

  // Show logout dialog with correct color
  void showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Do You Really Want to logout',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 0),
        actionsPadding: EdgeInsets.fromLTRB(24, 0, 24, 24),
        actions: [
          Row(
            children: [
              // Cancel button with the specified blue color
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF187DBD), // Your specified color
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              // Logout button with white background and red border
              Expanded(
                child: OutlinedButton(
                  onPressed: () => logout(),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Logout function
  void logout() async {
    try {
      Get.back(); // Close dialog
      isLoading.value = true;

      await _auth.signOut();

      // Clear user data
      userName.value = '';
      userEmail.value = '';
      userProfileImage.value = '';

      // Navigate to login
      Get.offAllNamed('/login');
    } catch (e) {
      print('Error during logout: $e');
      Get.snackbar('Error', 'Failed to logout. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }
}



class ProfileViewForTab extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:CustomDVYBAppBarWithBack(
          showBackButton: false,
        ),
      body: Stack(
        children: [
          // Background saree image positioned to the right
          Positioned(
            right: -45, // More to the right to match your reference
            top: 50,
            bottom: -530,
            child: Container(
              width: MediaQuery.of(context).size.width * 3.9,
              height: MediaQuery.of(context).size.height * 1.9,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/green.png'),
                  //fit: BoxFit.cover,
                  alignment: Alignment.centerRight,
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20), // Increased padding
                child: Column(
                  children: [
                    SizedBox(height: 30),

                    // Profile Card with Firebase data - bigger size
                    Obx(() => Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(24), // Increased padding
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Profile Image with rounded corners & shadow
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12), // Rounded rectangle
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(0, 3), // Shadow position
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias, // Important for rounded corners
                            child: controller.userProfileImage.value.isNotEmpty
                                ? Image.network(
                              controller.userProfileImage.value,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.person,
                                    size: 35,
                                    color: Colors.grey[600],
                                  ),
                                );
                              },
                            )
                                : Container(
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.person,
                                size: 35,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),

                          SizedBox(width: 16),

                          // Name
                          Expanded(
                            child: controller.isLoading.value
                                ? CircularProgressIndicator()
                                : Text(
                              controller.userName.value,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),

                    )),

                    SizedBox(height: 40), // Increased spacing

                    // Menu Items - removed individual cards, just text buttons
                    _buildMenuItem(
                      icon: Icons.person_outline,
                      title: 'My Profile',
                      onTap: () => controller.navigateToProfileSettings(),
                    ),
                    SizedBox(height: 20),

                    _buildMenuItem(
                      icon: Icons.shopping_bag_outlined,
                      title: 'My Order',
                      onTap: () => controller.navigateToOrders(),
                    ),
                    SizedBox(height: 20),

                    _buildMenuItem(
                      icon: Icons.info_outline,
                      title: 'About us',
                      onTap: () => controller.navigateToAbout(),
                    ),
                    SizedBox(height: 20),

                    _buildMenuItem(
                      icon: Icons.headset_mic_outlined,
                      title: 'Support',
                      onTap: () => controller.navigateToSupport(),
                    ),
                    SizedBox(height: 20),

                    _buildMenuItem(
                      icon: Icons.logout_outlined,
                      title: 'Logout',
                      onTap: () => controller.showLogoutDialog(),
                    ),

                    SizedBox(height: 320), // More space for tab bar
                  ]
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.grey.withOpacity(0.1),
      highlightColor: Colors.grey.withOpacity(0.05),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: Colors.grey[700],
            ),
            SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}

// Standalone Profile View (for direct navigation)
class ProfileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProfileViewForTab();
  }
}