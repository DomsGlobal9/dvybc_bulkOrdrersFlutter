import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AboutView extends StatelessWidget {
  const AboutView({Key? key}) : super(key: key);

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
              child:  Center(
                child: Image.asset(
                  'assets/images/DVYBL.png', height: 90, width: 90,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback if image is not found
                    return Text(
                      'DVYB',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  },
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
                  // Back button in white area
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
                      Row(

                        children: [
                          SizedBox(width: 100,),
                          Text(
                            'About Us',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(width: 100,),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 30),

                  // Main heading
                  Text(
                    'Fashion in Bulk, Made Simple.',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: 16),

                  // Description
                  Text(
                    'At DVYB, we make bulk fashion shopping simple and affordable — without compromising on style, quality, or variety. From weddings to family functions, our curated collections for men, women, and kids are designed for group looks at unbeatable prices.',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: 40),

                  // Why Dvyb section
                  Text(
                    'Why Dvyb?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: 16),

                  // Bullet points
                  _buildBulletPoint('Bulk Made Easy'),
                  SizedBox(height: 8),
                  _buildBulletPoint('More You Buy, More You Save'),
                  SizedBox(height: 8),
                  _buildBulletPoint('Quick Delivery & Easy Returns'),

                  SizedBox(height: 40),

                  // App version section
                  Text(
                    'App version',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: 12),

                  Text(
                    'v1.0.0 - July 2025',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),

                  SizedBox(height: 40),

                  // Get in Touch section
                  Text(
                    'Get in Touch',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: 20),

                  // Phone number
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        size: 20,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 12),
                      Text(
                        '+91 - XXXXXXXXXX',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Email
                  Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 20,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 12),
                      Text(
                        'support@dvyb.com',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 40),

                  // Developed by section
                  Text(
                    'Developed by',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: 12),

                  Text(
                    'DOMS Global LLP',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF2196F3),
                      fontWeight: FontWeight.w500,
                    ),
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

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
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
    );
  }
}