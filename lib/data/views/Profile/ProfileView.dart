import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ProfileSettingsView.dart';
import 'MyOrderView.dart';
import 'AboutView.dart';
import 'SupportView.dart';

class ProfileViewForTab extends StatelessWidget {
  ProfileViewForTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // Background with gradient and pattern
          Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF87CEEB), // Light sky blue
                  Color(0xFFF8F9FA), // Light gray
                ],
                stops: [0.0, 0.4],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Header
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'DVYB',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),

                // Profile Section with circular image and name
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Profile Image
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey[300]!, width: 2),
                        ),
                        child: ClipOval(
                          child: Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.person,
                              size: 30,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 15),

                      // Name
                      Text(
                        'Sandeep',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30),

                // Menu Items List
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          icon: Icons.person_outline,
                          title: 'My Profile',
                          onTap: () => Get.to(() => ProfileSettingsView()),
                        ),
                        SizedBox(height: 15),

                        _buildMenuItem(
                          icon: Icons.shopping_bag_outlined,
                          title: 'My Order',
                          onTap: () => Get.to(() => MyOrderView()),
                        ),
                        SizedBox(height: 15),

                        _buildMenuItem(
                          icon: Icons.info_outline,
                          title: 'About us',
                          onTap: () => Get.to(() => AboutView()),
                        ),
                        SizedBox(height: 15),

                        _buildMenuItem(
                          icon: Icons.headset_mic_outlined,
                          title: 'Support',
                          onTap: () => Get.to(() => SupportView()),
                        ),
                        SizedBox(height: 15),

                        _buildMenuItem(
                          icon: Icons.logout_outlined,
                          title: 'Logout',
                          onTap: () => _showLogoutDialog(),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom navigation space
                SizedBox(height: 100),
              ],
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
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
                fontSize: 16,
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

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.offAllNamed('/login');
            },
            child: Text('Logout'),
          ),
        ],
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