import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/Women/WomenModel.dart';

class RealFirebaseProductService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String productsCollection = 'products';

  // Get products by type (like "kurta", "top wear", etc.)
  static Stream<List<WomenProduct>> getProductsByType({
    required String productType,
    String gender = 'Women',
    int limit = 50,
  }) {
    try {
      return _firestore
          .collection(productsCollection)
          .where('gender', isEqualTo: gender)
          .where('productType', isEqualTo: productType)
          .limit(limit)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return _createProductFromDoc(doc);
        }).where((product) => product != null).cast<WomenProduct>().toList();
      });
    } catch (e) {
      print('Error getting products by type: $e');
      return Stream.value([]);
    }
  }

  // Get all products for a gender
  static Stream<List<WomenProduct>> getAllProducts({
    String gender = 'Women',
    int limit = 100,
  }) {
    try {
      return _firestore
          .collection(productsCollection)
          .where('gender', isEqualTo: gender)
          .limit(limit)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return _createProductFromDoc(doc);
        }).where((product) => product != null).cast<WomenProduct>().toList();
      });
    } catch (e) {
      print('Error getting all products: $e');
      return Stream.value([]);
    }
  }

  // Get products with similar names (for product variations)
  static Stream<List<WomenProduct>> getProductVariations({
    required String productName,
    String gender = 'Women',
    int limit = 20,
  }) {
    try {
      return _firestore
          .collection(productsCollection)
          .where('gender', isEqualTo: gender)
          .where('productName', isEqualTo: productName)
          .limit(limit)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return _createProductFromDoc(doc);
        }).where((product) => product != null).cast<WomenProduct>().toList();
      });
    } catch (e) {
      print('Error getting product variations: $e');
      return Stream.value([]);
    }
  }

  // Create WomenProduct from Firestore document
  static WomenProduct? _createProductFromDoc(QueryDocumentSnapshot doc) {
    try {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // Extract image URLs from Firebase
      List<String> imageUrls = [];
      if (data['imageUrls'] is List) {
        imageUrls = List<String>.from(data['imageUrls']);
      }

      return WomenProduct(
        id: doc.id,
        name: data['productName'] ?? 'Unknown Product',
        image: imageUrls.isNotEmpty ? imageUrls.first : '',
        category: data['productType'] ?? 'unknown',
        description: _createDescription(data['productName'], data['productType']),
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
      print('Error creating product from doc ${doc.id}: $e');
      return null;
    }
  }

  // Create meaningful description
  static String _createDescription(String? productName, String? productType) {
    if (productName == null || productType == null) {
      return 'Beautiful fashion item from our collection';
    }

    switch (productType.toLowerCase()) {
      case 'kurta':
        return 'Elegant $productName perfect for traditional and contemporary styling. Comfortable and stylish.';
      case 'top wear':
        return 'Trendy $productName that combines comfort with style. Perfect for casual and formal occasions.';
      case 'bottom wear':
        return 'Comfortable and stylish $productName that complements any outfit. Essential wardrobe piece.';
      case 'dress':
        return 'Beautiful $productName that flatters every figure. Perfect for any special occasion.';
      case 'jumpsuit':
        return 'Chic $productName that offers effortless style in one piece. Modern and comfortable.';
      default:
        return 'Stylish $productName from our premium $productType collection. Quality and comfort guaranteed.';
    }
  }
}