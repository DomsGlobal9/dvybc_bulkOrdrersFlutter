import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Widgets/CustomDVYBAppBarWithBack.dart';

class SupportView extends StatelessWidget {
  const SupportView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomDVYBAppBar(),
      body: Column(
        children: [
          // Content section
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button and title in white area
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.black87,
                            size: 20,
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      Text(
                        'Help & Support',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 30),

                  // Help & Support title
                  Text(
                    'Help & Support',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: 30),

                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search Help Topics',
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey[600],
                          size: 22,
                        ),
                        suffixIcon: Icon(
                          Icons.mic,
                          color: Colors.grey[600],
                          size: 22,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                  ),

                  SizedBox(height: 40),

                  // Popular Help Topics
                  Text(
                    'Popular Help Topics',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: 20),

                  // Help topic items
                  _buildHelpTopic(
                    'How to track my order?',
                    onTap: () => Get.to(() => HelpDetailView()),
                  ),
                  SizedBox(height: 16),

                  _buildHelpTopic(
                    'How to return or replace order?',
                    onTap: () {},
                  ),
                  SizedBox(height: 16),

                  _buildHelpTopic(
                    'How to cancel my order?',
                    onTap: () {},
                  ),
                  SizedBox(height: 16),

                  _buildHelpTopic(
                    'How to apply coupon?',
                    onTap: () {},
                  ),

                  SizedBox(height: 50),

                  // Need more help section
                  Text(
                    'Need more help?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: 30),

                  // Contact options
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        size: 22,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Call us on',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '+91 - XXXXXXXXXX',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF2196F3),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 30),

                  Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 22,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Send an email on',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'support@dvyb.com',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpTopic(String title, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.help_outline,
                size: 18,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Help Detail View (for "How to track my order?")
class HelpDetailView extends StatelessWidget {
  const HelpDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top header with gradient background and rounded bottom corners
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF87CEEB), // Light sky blue
                  Color(0xFFE6F3FF), // Very light blue
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              child: Center(
                child: Text(
                  'DVYB',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),

          // Content section
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button and title
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.black87,
                            size: 20,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Help & Support',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 30),

                  // Article title
                  Text(
                    'How to track my order?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: 30),

                  // Step 1
                  Text(
                    '1.) Go to "My Orders"',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: 12),

                  _buildBulletPoint('Tap on the Profile tab at the bottom.'),
                  SizedBox(height: 6),
                  _buildBulletPoint('Select "My Orders" from the menu.'),

                  SizedBox(height: 24),

                  // Step 2
                  Text(
                    '2.) Select Your Order',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: 12),

                  _buildBulletPoint('Tap on the order you want to track.'),

                  SizedBox(height: 24),

                  // Step 3
                  Text(
                    '3.) View Tracking Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: 12),

                  _buildBulletPoint('See current status: Order Placed → Packed → Shipped → Out for Delivery → Delivered'),
                  SizedBox(height: 6),
                  _buildBulletPoint('Tap "Track" to view real-time tracking updates and expected delivery date.'),

                  SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 4,
            margin: EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.black87,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}