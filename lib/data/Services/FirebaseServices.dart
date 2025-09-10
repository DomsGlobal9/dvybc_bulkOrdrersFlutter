import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/Women/WomenModel.dart';

class FirebaseProductService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String productsCollection = 'products';

  // Get all products - NO FILTERS
  static Stream<List<WomenProduct>> getAllProducts() {
    print('FirebaseProductService: Getting all products...');

    return _firestore
        .collection(productsCollection)
        .snapshots()
        .map((snapshot) {
      print('FirebaseProductService: Received ${snapshot.docs.length} documents');

      List<WomenProduct> products = [];

      for (var doc in snapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          print('Processing doc ${doc.id}: ${data['productName']} - ${data['productType']}');

          WomenProduct? product = _mapDocumentToWomenProduct(doc);
          if (product != null) {
            products.add(product);
          }
        } catch (e) {
          print('Error processing doc ${doc.id}: $e');
        }
      }

      print('Total products created: ${products.length}');
      return products;
    });
  }

  // Get products by specific type (like 'kurta', 'top wear', etc.)
  static Stream<List<WomenProduct>> getProductsByType(String productType) {
    print('Getting products by type: $productType');

    return _firestore
        .collection(productsCollection)
        .where('productType', isEqualTo: productType)
        .snapshots()
        .map((snapshot) {
      print('Type query for "$productType": ${snapshot.docs.length} documents');

      List<WomenProduct> products = [];

      for (var doc in snapshot.docs) {
        try {
          WomenProduct? product = _mapDocumentToWomenProduct(doc);
          if (product != null) {
            products.add(product);
          }
        } catch (e) {
          print('Error processing doc ${doc.id}: $e');
        }
      }

      return products;
    });
  }

  // Get product variations by product name (for compatibility with old code)
  static Stream<List<WomenProduct>> getProductVariations({
    required String productName,
    required String gender,
    required String category,
  }) {
    print('Getting product variations for: $productName');

    return _firestore
        .collection(productsCollection)
        .where('productName', isEqualTo: productName)
        .snapshots()
        .map((snapshot) {
      List<WomenProduct> products = [];

      for (var doc in snapshot.docs) {
        try {
          WomenProduct? product = _mapDocumentToWomenProduct(doc);
          if (product != null) {
            products.add(product);
          }
        } catch (e) {
          print('Error processing doc ${doc.id}: $e');
        }
      }

      return products;
    });
  }

  // Get products by category (for backward compatibility)
  static Stream<List<WomenProduct>> getProductsByCategory({
    required String gender,
    required String subcategory,
    int limit = 20,
  }) {
    print('Getting products by category - Gender: $gender, Subcategory: $subcategory');

    // Map old subcategory names to new productType values
    String productType = _mapSubcategoryToProductType(subcategory);

    return _firestore
        .collection(productsCollection)
        .where('productType', isEqualTo: productType)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      print('Category query result: ${snapshot.docs.length} documents');

      List<WomenProduct> products = [];

      for (var doc in snapshot.docs) {
        try {
          WomenProduct? product = _mapDocumentToWomenProduct(doc);
          if (product != null) {
            products.add(product);
          }
        } catch (e) {
          print('Error processing doc ${doc.id}: $e');
        }
      }

      return products;
    });
  }

  // Get similar products
  static Stream<List<WomenProduct>> getSimilarProducts({
    required String gender,
    required String productType,
    required String excludeProductId,
    int limit = 8,
  }) {
    return _firestore
        .collection(productsCollection)
        .where('productType', isEqualTo: productType)
        .limit(limit + 5)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .where((doc) => doc.id != excludeProductId)
          .map((doc) => _mapDocumentToWomenProduct(doc))
          .where((product) => product != null)
          .cast<WomenProduct>()
          .take(limit)
          .toList();
    });
  }

  // Map old subcategory names to Firebase productType values
  static String _mapSubcategoryToProductType(String subcategory) {
    switch (subcategory.toLowerCase()) {
      case 'ethnic':
        return 'kurta'; // Your Firebase has kurta products
      case 'topwear':
      case 'top wear':
        return 'top wear';
      case 'bottomwear':
      case 'bottom wear':
        return 'bottom wear';
      case 'kurta':
        return 'kurta';
      default:
        return subcategory; // Use as-is if no mapping needed
    }
  }

  // Map Firestore document to WomenProduct
  static WomenProduct? _mapDocumentToWomenProduct(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) {
        print('Document ${doc.id} has no data');
        return null;
      }

      // Extract image URLs
      List<String> imageUrls = [];
      if (data['imageUrls'] is List) {
        imageUrls = List<String>.from(data['imageUrls']);
      }

      return WomenProduct(
        id: doc.id,
        name: data['productName'] ?? 'Unknown Product',
        image: imageUrls.isNotEmpty ? imageUrls.first : '',
        category: data['productType'] ?? 'unknown',
        description: _generateDescription(data['productName'], data['productType']),
        gender: data['gender'] ?? 'Women',
        subcategory: data['productType'] ?? 'unknown',
        imageUrls: imageUrls,
        productId: data['productId'],
        productSize: data['productSize'],
        totalImages: data['totalImages'] ?? imageUrls.length,
        userId: data['userId'],
        userName: data['userName'],
        isActive: data['isActive'] ?? true,
        createdAt: data['createdAt'],
      );
    } catch (e) {
      print('Error mapping document ${doc.id}: $e');
      return null;
    }
  }

  // Generate description based on product name and type
  static String _generateDescription(String? productName, String? productType) {
    if (productName == null || productType == null) {
      return 'Beautiful fashion item for women';
    }

    switch (productType.toLowerCase()) {
      case 'kurta':
        return 'Elegant $productName perfect for traditional occasions. Comfortable fit with beautiful design details.';
      case 'saree':
        return 'Stunning $productName that drapes beautifully. Perfect for special occasions and celebrations.';
      case 'lehenga':
        return 'Gorgeous $productName with intricate work. Ideal for weddings and festive occasions.';
      case 'top wear':
      case 'topwear':
        return 'Stylish $productName that combines comfort with fashion. Perfect for daily wear.';
      case 'bottom wear':
      case 'bottomwear':
        return 'Comfortable $productName with great fit and style. Essential for your wardrobe.';
      default:
        return 'Beautiful $productName that combines style and comfort. A perfect addition to your wardrobe.';
    }
  }
}