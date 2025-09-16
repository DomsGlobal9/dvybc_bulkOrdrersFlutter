import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../model/Women/WomenModel.dart';

// Fixed Product Card Widget with proper Firebase integration
Widget buildWomenProductCard(WomenProduct womenProduct) {
  return GestureDetector(
    onTap: () {
      // Navigate to product detail view showing variations of this product
      Get.toNamed('/product-detail', arguments: {
        'productName': womenProduct.name,
        'category': womenProduct.subcategory,
        'gender': womenProduct.gender,
      });
    },
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildProductImage(womenProduct),
                  ),
                  // Availability indicator
                  if (!womenProduct.isAvailable)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'OUT OF STOCK',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Add a "View More" badge
                  if (womenProduct.isAvailable)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(0xFF3B82F6).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'View More',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  // Gender badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getGenderColor(womenProduct.gender),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        womenProduct.gender.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  womenProduct.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  womenProduct.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        womenProduct.isAvailable ? 'Explore Styles' : 'Unavailable',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: womenProduct.isAvailable
                              ? Color(0xFF3B82F6)
                              : Colors.grey[500],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: womenProduct.isAvailable
                            ? Color(0xFF3B82F6)
                            : Colors.grey[400],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// FIXED: Helper function to build product image with proper Firebase URL handling
Widget _buildProductImage(WomenProduct womenProduct) {
  String imageUrl = _getValidImageUrl(womenProduct);

  // Debug: Print the image URL being used
  print('Loading image for ${womenProduct.name}: $imageUrl');

  return Image.network(
    imageUrl,
    fit: BoxFit.cover,
    width: double.infinity,
    height: double.infinity,
    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null) return child;
      return Container(
        color: Colors.grey[200],
        child: Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!
                : null,
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
          ),
        ),
      );
    },
    errorBuilder: (context, error, stackTrace) {
      print('Image loading error for ${womenProduct.name}: $error');
      print('Failed URL: $imageUrl');
      return Container(
        color: Colors.grey[200],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_outlined,
                size: 40,
                color: Colors.grey[400],
              ),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  womenProduct.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// FIXED: Helper function to get valid image URL
String _getValidImageUrl(WomenProduct womenProduct) {
  // Debug: Print available image sources
  print('Getting image URL for ${womenProduct.name}:');
  print('- imageUrls: ${womenProduct.imageUrls}');
  print('- image: ${womenProduct.image}');

  // First try to get from imageUrls array
  if (womenProduct.imageUrls != null && womenProduct.imageUrls!.isNotEmpty) {
    for (String url in womenProduct.imageUrls!) {
      if (url.isNotEmpty &&
          (url.startsWith('http://') || url.startsWith('https://'))) {
        print('Using imageUrls[0]: $url');
        return url;
      }
    }
  }

  // Fallback to the main image property
  if (womenProduct.image.isNotEmpty &&
      (womenProduct.image.startsWith('http://') ||
          womenProduct.image.startsWith('https://'))) {
    print('Using main image: ${womenProduct.image}');
    return womenProduct.image;
  }

  // If no valid URL found, return a placeholder
  String placeholder = 'https://via.placeholder.com/300x400/f0f0f0/cccccc?text=${Uri.encodeComponent(womenProduct.name)}';
  print('Using placeholder: $placeholder');
  return placeholder;
}

// Helper function to get gender-based color
Color _getGenderColor(String gender) {
  switch (gender.toLowerCase()) {
    case 'women':
      return Colors.pink.withOpacity(0.9);
    case 'men':
      return Colors.blue.withOpacity(0.9);
    case 'kids':
      return Colors.orange.withOpacity(0.9);
    default:
      return Colors.purple.withOpacity(0.9);
  }
}

// Reusable Error Widget
Widget buildErrorWidget(String error, VoidCallback onRetry) {
  return Center(
    child: Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Try Again'),
          ),
        ],
      ),
    ),
  );
}

// Reusable Empty Widget
Widget buildEmptyWidget() {
  return Center(
    child: Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 60,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No Products Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'We\'ll add new products soon!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    ),
  );
}