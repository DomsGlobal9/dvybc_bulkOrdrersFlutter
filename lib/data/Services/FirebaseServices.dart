import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/Women/WomenModel.dart';

class FirebaseProductService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all products from all users using collectionGroup (like React implementation)
  static Stream<List<WomenProduct>> getAllProducts() {
    print('🚀 Starting to fetch all products from all users...');

    return _firestore
        .collectionGroup('products') // This queries all 'products' subcollections
        .snapshots()
        .map((snapshot) {
      print('📊 Collection group query returned ${snapshot.docs.length} products');

      if (snapshot.docs.isEmpty) {
        print('⚠️ No products found in any user collection');
        return <WomenProduct>[];
      }

      List<WomenProduct> products = [];

      for (var doc in snapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          // Extract userId from document reference path
          // Path format: users/{userId}/products/{productId}
          String userId = doc.reference.parent.parent!.id;

          print('Processing product ${doc.id} from user $userId');
          print('Product data keys: ${data.keys.toList()}');

          WomenProduct? product = _mapDocumentToWomenProduct(doc, userId);
          if (product != null) {
            products.add(product);
          }
        } catch (e) {
          print('❌ Error processing product ${doc.id}: $e');
        }
      }

      // Sort products by timestamp (newest first) like React implementation
      products.sort((a, b) {
        final timeA = a.timestamp ?? 0;
        final timeB = b.timestamp ?? 0;
        if (timeA is Timestamp && timeB is Timestamp) {
          return timeB.compareTo(timeA);
        }
        return 0;
      });

      print('✅ Successfully processed ${products.length} products');
      return products;
    }).handleError((error) {
      print('💥 Error in getAllProducts: $error');
      return <WomenProduct>[];
    });
  }

  // Fetch products from a specific user
  static Stream<List<WomenProduct>> getProductsByUser(String userId) {
    print('🔍 Fetching products for user: $userId');

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('products')
        .snapshots()
        .map((snapshot) {
      print('📦 Found ${snapshot.docs.length} products for user $userId');

      List<WomenProduct> products = [];

      for (var doc in snapshot.docs) {
        try {
          WomenProduct? product = _mapDocumentToWomenProduct(doc, userId);
          if (product != null) {
            products.add(product);
          }
        } catch (e) {
          print('❌ Error processing product ${doc.id} for user $userId: $e');
        }
      }

      return products;
    }).handleError((error) {
      print('💥 Error getting products for user $userId: $error');
      return <WomenProduct>[];
    });
  }

  // Fetch products by category across all users
  static Stream<List<WomenProduct>> getProductsByCategory(String category) {
    print('🔍 Fetching products by category: $category');

    return _firestore
        .collectionGroup('products')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      print('📦 Found ${snapshot.docs.length} products for category $category');

      List<WomenProduct> products = [];

      for (var doc in snapshot.docs) {
        try {
          String userId = doc.reference.parent.parent!.id;
          WomenProduct? product = _mapDocumentToWomenProduct(doc, userId);
          if (product != null) {
            products.add(product);
          }
        } catch (e) {
          print('❌ Error processing product ${doc.id}: $e');
        }
      }

      return products;
    });
  }

  // Fetch products by dress type across all users
  static Stream<List<WomenProduct>> getProductsByDressType(String dressType) {
    print('🔍 Fetching products by dress type: $dressType');

    return _firestore
        .collectionGroup('products')
        .where('dressType', isEqualTo: dressType)
        .snapshots()
        .map((snapshot) {
      List<WomenProduct> products = [];

      for (var doc in snapshot.docs) {
        try {
          String userId = doc.reference.parent.parent!.id;
          WomenProduct? product = _mapDocumentToWomenProduct(doc, userId);
          if (product != null) {
            products.add(product);
          }
        } catch (e) {
          print('❌ Error processing product ${doc.id}: $e');
        }
      }

      return products;
    });
  }

  // Fetch products by fabric across all users
  static Stream<List<WomenProduct>> getProductsByFabric(String fabric) {
    print('🔍 Fetching products by fabric: $fabric');

    return _firestore
        .collectionGroup('products')
        .where('fabric', isEqualTo: fabric)
        .snapshots()
        .map((snapshot) {
      List<WomenProduct> products = [];

      for (var doc in snapshot.docs) {
        try {
          String userId = doc.reference.parent.parent!.id;
          WomenProduct? product = _mapDocumentToWomenProduct(doc, userId);
          if (product != null) {
            products.add(product);
          }
        } catch (e) {
          print('❌ Error processing product ${doc.id}: $e');
        }
      }

      return products;
    });
  }

  // Get all unique dress types (for filter options)
  static Future<List<String>> getDressTypes() async {
    try {
      print('📋 Fetching unique dress types...');

      final querySnapshot = await _firestore
          .collectionGroup('products')
          .get();

      Set<String> dressTypes = {};

      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['dressType'] != null && data['dressType'].toString().isNotEmpty) {
          dressTypes.add(data['dressType'].toString());
        }
      }

      print('✅ Found ${dressTypes.length} unique dress types: ${dressTypes.toList()}');
      return dressTypes.toList()..sort();
    } catch (e) {
      print('❌ Error fetching dress types: $e');
      return [];
    }
  }

  // Get all unique fabrics (for filter options)
  static Future<List<String>> getFabrics() async {
    try {
      print('📋 Fetching unique fabrics...');

      final querySnapshot = await _firestore
          .collectionGroup('products')
          .get();

      Set<String> fabrics = {};

      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['fabric'] != null && data['fabric'].toString().isNotEmpty) {
          fabrics.add(data['fabric'].toString());
        }
      }

      print('✅ Found ${fabrics.length} unique fabrics: ${fabrics.toList()}');
      return fabrics.toList()..sort();
    } catch (e) {
      print('❌ Error fetching fabrics: $e');
      return [];
    }
  }

  // Get all unique categories (for filter options)
  static Future<List<String>> getCategories() async {
    try {
      print('📋 Fetching unique categories...');

      final querySnapshot = await _firestore
          .collectionGroup('products')
          .get();

      Set<String> categories = {};

      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['category'] != null && data['category'].toString().isNotEmpty) {
          categories.add(data['category'].toString());
        }
      }

      print('✅ Found ${categories.length} unique categories: ${categories.toList()}');
      return categories.toList()..sort();
    } catch (e) {
      print('❌ Error fetching categories: $e');
      return [];
    }
  }

  // Map Firestore document to WomenProduct
  static WomenProduct? _mapDocumentToWomenProduct(DocumentSnapshot doc, String userId) {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) {
        print('❌ Document ${doc.id} has no data');
        return null;
      }

      // Extract image URLs - try multiple field names
      List<String> imageUrls = [];
      if (data['imageUrls'] is List) {
        imageUrls = List<String>.from(data['imageUrls']);
      } else if (data['imageURLs'] is List) {
        imageUrls = List<String>.from(data['imageURLs']);
      } else if (data['images'] is List) {
        imageUrls = List<String>.from(data['images']);
      }

      // Extract selected colors
      List<String> selectedColors = [];
      if (data['selectedColors'] is List) {
        selectedColors = List<String>.from(data['selectedColors']);
      }

      // Extract selected sizes
      List<String> selectedSizes = [];
      if (data['selectedSizes'] is List) {
        selectedSizes = List<String>.from(data['selectedSizes']);
      }

      // Handle price - can be string or number
      int? price;
      if (data['price'] != null) {
        if (data['price'] is String) {
          price = int.tryParse(data['price']);
        } else if (data['price'] is int) {
          price = data['price'];
        } else if (data['price'] is double) {
          price = (data['price'] as double).toInt();
        }
      }

      // Generate product name (use title if available, fallback to name)
      String productName = data['title']?.toString() ??
          data['name']?.toString() ??
          data['dressType']?.toString() ??
          'Fashion Item';

      // Handle timestamp normalization (like React implementation)
      dynamic timestamp = data['timestamp'];
      if (data['createdAt'] != null && timestamp == null) {
        timestamp = data['createdAt'];
      }

      return WomenProduct(
        id: doc.id,
        name: productName,
        image: imageUrls.isNotEmpty ? imageUrls.first : '',
        category: data['category']?.toString() ?? 'WOMEN',
        description: data['description']?.toString() ?? _generateDescription(productName, data['dressType']?.toString()),
        gender: data['category']?.toString() ?? 'WOMEN',
        subcategory: data['dressType']?.toString() ?? 'fashion',
        imageUrls: imageUrls,
        productId: doc.id,
        productSize: selectedSizes.isNotEmpty ? selectedSizes.first : null,
        totalImages: imageUrls.length,
        userId: userId, // Store the user ID who created this product
        userName: data['userName']?.toString(),
        isActive: data['isActive'] ?? true,
        price: price,
        design: data['craft']?.toString(), // Map 'craft' to 'design'
        dressType: data['dressType']?.toString(),
        material: data['fabric']?.toString(), // Map 'fabric' to 'material'
        selectedColors: selectedColors,
        selectedSizes: selectedSizes,
        createdAt: data['createdAt'],
        timestamp: timestamp,
        units: data['units'],
      );
    } catch (e) {
      print('❌ Error mapping document ${doc.id}: $e');
      return null;
    }
  }

  // Generate description if not provided
  static String _generateDescription(String? productName, String? dressType) {
    if (productName == null) {
      return 'Beautiful fashion item for women';
    }

    String baseDescription = 'Stylish $productName';

    if (dressType != null && dressType.isNotEmpty) {
      baseDescription += ' - $dressType';
    }

    return '$baseDescription. Perfect for modern women who value both comfort and style.';
  }

  // Debug method to test Firebase connection and structure
  static Future<Map<String, dynamic>> debugFirebaseStructure() async {
    try {
      print('🔍 Running Firebase structure debug...');

      Map<String, dynamic> debugInfo = {};

      // Test collectionGroup query
      final allProductsQuery = await _firestore.collectionGroup('products').limit(5).get();
      debugInfo['totalProducts'] = allProductsQuery.size;
      debugInfo['sampleProductIds'] = allProductsQuery.docs.map((doc) => doc.id).toList();

      // Test users collection
      final usersQuery = await _firestore.collection('users').limit(5).get();
      debugInfo['totalUsers'] = usersQuery.size;
      debugInfo['sampleUserIds'] = usersQuery.docs.map((doc) => doc.id).toList();

      // Sample product data
      if (allProductsQuery.docs.isNotEmpty) {
        final sampleDoc = allProductsQuery.docs.first;
        final sampleData = sampleDoc.data() as Map<String, dynamic>;
        debugInfo['sampleProduct'] = {
          'id': sampleDoc.id,
          'userId': sampleDoc.reference.parent.parent?.id,
          'fields': sampleData.keys.toList(),
          'title': sampleData['title'],
          'category': sampleData['category'],
          'dressType': sampleData['dressType'],
          'hasImages': (sampleData['imageUrls'] as List?)?.isNotEmpty ?? false,
        };
      }

      print('✅ Debug completed successfully');
      return debugInfo;
    } catch (e) {
      print('❌ Debug failed: $e');
      return {'error': e.toString()};
    }
  }
}