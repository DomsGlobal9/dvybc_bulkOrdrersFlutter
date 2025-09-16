class WomenProduct {
  final String id;
  final String name;
  final String image;
  final String category;
  final String description;
  final String gender;
  final String subcategory;

  // Additional Firebase fields - Updated according to your Firebase structure
  final List<String>? imageUrls;
  final String? productId;
  final String? productSize;
  final int? totalImages;
  final String? userId;
  final String? userName;
  final bool? isActive;
  final int? price;
  final String? design;
  final String? dressType;
  final String? material;
  final List<String>? selectedColors;
  final List<String>? selectedSizes;
  final dynamic createdAt;
  final dynamic timestamp;
  final int? units;

  WomenProduct({
    required this.id,
    required this.name,
    required this.image,
    required this.category,
    required this.description,
    required this.gender,
    required this.subcategory,
    this.imageUrls,
    this.productId,
    this.productSize,
    this.totalImages,
    this.userId,
    this.userName,
    this.price,
    this.isActive,
    this.design,
    this.dressType,
    this.material,
    this.selectedColors,
    this.selectedSizes,
    this.createdAt,
    this.timestamp,
    this.units,
  });

  // Computed property for availability based on isActive
  bool get isAvailable => isActive ?? true;

  // Get product name from available fields
  String get displayName {
    if (design != null && design!.isNotEmpty) {
      return design!;
    }
    if (dressType != null && dressType!.isNotEmpty) {
      return dressType!;
    }
    if (category.isNotEmpty) {
      return category;
    }
    return 'Fashion Item';
  }

  // Computed MRP (mocked as 2x price for display)
  int get mrp => (price ?? 0) * 2;

  // Computed discount percentage (fixed 50% for now)
  int get discountPercent => 50;

  // Factory constructor for creating from Firebase document
  factory WomenProduct.fromFirestore(Map<String, dynamic> data, String documentId) {
    // Extract image URLs - Firebase has 'imageURLs' (note the capital letters)
    List<String> imageUrls = [];
    if (data['imageURLs'] is List) {
      List<dynamic> urls = data['imageURLs'];
      imageUrls = urls.map((url) => url.toString()).toList();
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

    // Generate product name from available fields
    String productName = _generateProductName(data);

    // Handle price - Firebase stores as string "5000"
    int? productPrice;
    if (data['price'] != null) {
      if (data['price'] is String) {
        productPrice = int.tryParse(data['price']);
      } else if (data['price'] is int) {
        productPrice = data['price'];
      }
    }

    return WomenProduct(
      id: documentId,
      name: productName,
      image: imageUrls.isNotEmpty ? imageUrls.first : '',
      category: data['category'] ?? 'Women',
      description: _generateDescription(productName, data['category'], data['material']),
      gender: data['category'] ?? 'Women',
      subcategory: data['dressType'] ?? 'fashion',
      imageUrls: imageUrls,
      productId: documentId,
      productSize: selectedSizes.isNotEmpty ? selectedSizes.first : null,
      totalImages: imageUrls.length,
      userId: data['userId'],
      userName: data['userName'],
      isActive: data['isActive'] ?? true,
      price: productPrice,
      design: data['design'],
      dressType: data['dressType'],
      material: data['material'],
      selectedColors: selectedColors,
      selectedSizes: selectedSizes,
      createdAt: data['createdAt'],
      timestamp: data['timestamp'],
      units: data['units'],
    );
  }

  // Generate product name from available fields
  static String _generateProductName(Map<String, dynamic> data) {
    String name = '';

    // Try to create a meaningful name from available fields
    if (data['design'] != null && data['design'].toString().isNotEmpty) {
      name += data['design'].toString();
    }

    if (data['dressType'] != null && data['dressType'].toString().isNotEmpty) {
      if (name.isNotEmpty) name += ' ';
      name += data['dressType'].toString();
    }

    if (data['material'] != null && data['material'].toString().isNotEmpty) {
      if (name.isNotEmpty) name += ' ';
      name += data['material'].toString();
    }

    // If no name could be generated, create a descriptive name
    if (name.isEmpty) {
      String category = data['category']?.toString() ?? 'Fashion';
      String material = data['material']?.toString() ?? '';
      String dressType = data['dressType']?.toString() ?? '';

      if (material.isNotEmpty && dressType.isNotEmpty) {
        name = '$material $dressType';
      } else if (dressType.isNotEmpty) {
        name = dressType;
      } else if (material.isNotEmpty) {
        name = '$material $category Item';
      } else {
        name = '$category Fashion Item';
      }
    }

    return name;
  }

  // Convert to JSON for local storage or API calls
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'category': category,
      'description': description,
      'gender': gender,
      'subcategory': subcategory,
      'imageUrls': imageUrls,
      'productId': productId,
      'productSize': productSize,
      'totalImages': totalImages,
      'userId': userId,
      'userName': userName,
      'isActive': isActive,
      'price': price,
      'design': design,
      'dressType': dressType,
      'material': material,
      'selectedColors': selectedColors,
      'selectedSizes': selectedSizes,
      'createdAt': createdAt,
      'timestamp': timestamp,
      'units': units,
    };
  }

  // Create a copy with updated fields
  WomenProduct copyWith({
    String? id,
    String? name,
    String? image,
    String? category,
    String? description,
    String? gender,
    String? subcategory,
    List<String>? imageUrls,
    String? productId,
    String? productSize,
    int? totalImages,
    String? userId,
    String? userName,
    bool? isActive,
    int? price,
    String? design,
    String? dressType,
    String? material,
    List<String>? selectedColors,
    List<String>? selectedSizes,
    dynamic createdAt,
    dynamic timestamp,
    int? units,
  }) {
    return WomenProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      category: category ?? this.category,
      description: description ?? this.description,
      gender: gender ?? this.gender,
      subcategory: subcategory ?? this.subcategory,
      imageUrls: imageUrls ?? this.imageUrls,
      productId: productId ?? this.productId,
      productSize: productSize ?? this.productSize,
      totalImages: totalImages ?? this.totalImages,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      isActive: isActive ?? this.isActive,
      price: price ?? this.price,
      design: design ?? this.design,
      dressType: dressType ?? this.dressType,
      material: material ?? this.material,
      selectedColors: selectedColors ?? this.selectedColors,
      selectedSizes: selectedSizes ?? this.selectedSizes,
      createdAt: createdAt ?? this.createdAt,
      timestamp: timestamp ?? this.timestamp,
      units: units ?? this.units,
    );
  }

  // Generate description based on available product data
  static String _generateDescription(String? productName, String? category, String? material) {
    if (productName == null) {
      return 'Beautiful fashion item for women';
    }

    String description = 'Stylish $productName';

    if (material != null && material.isNotEmpty) {
      description += ' made from premium $material';
    }

    if (category != null && category.toLowerCase() == 'women') {
      description += '. Perfect for modern women who value both comfort and style.';
    } else {
      description += '. A perfect addition to your wardrobe.';
    }

    return description;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WomenProduct && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'WomenProduct(id: $id, name: $name, category: $category, gender: $gender, price: $price, images: ${imageUrls?.length ?? 0})';
  }
}