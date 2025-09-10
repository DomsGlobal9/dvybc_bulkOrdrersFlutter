class WomenProduct {
  final String id;
  final String name;
  final String image;
  final String category;
  final String description;
  final String gender;
  final String subcategory;

  // Additional Firebase fields
  final List<String>? imageUrls;
  final String? productId;
  final String? productSize;
  final int? totalImages;
  final String? userId;
  final String? userName;
  final bool? isActive;
  final dynamic createdAt;

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
    this.isActive,
    this.createdAt,
  });

  // Computed property for availability based on isActive
  bool get isAvailable => isActive ?? true;

  // Factory constructor for creating from Firebase document
  factory WomenProduct.fromFirestore(Map<String, dynamic> data, String documentId) {
    // Extract image URLs
    List<String> imageUrls = [];
    if (data['imageUrls'] is List) {
      imageUrls = List<String>.from(data['imageUrls']);
    }

    return WomenProduct(
      id: documentId,
      name: data['productName'] ?? 'Unknown Product',
      image: imageUrls.isNotEmpty ? imageUrls.first : 'assets/images/placeholder.png',
      category: data['productType'] ?? 'unknown',
      description: _generateDescription(data['productName'], data['productType']),
      gender: data['gender'] ?? 'Women',
      subcategory: data['productType'] ?? 'ethnic',
      imageUrls: imageUrls,
      productId: data['productId'],
      productSize: data['productSize'],
      totalImages: data['totalImages'] ?? imageUrls.length,
      userId: data['userId'],
      userName: data['userName'],
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'],
    );
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
      'createdAt': createdAt,
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
    dynamic createdAt,
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
      createdAt: createdAt ?? this.createdAt,
    );
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
      case 'dress':
        return 'Beautiful $productName that flatters your figure. Perfect for any occasion.';
      case 'jacket':
        return 'Stylish $productName to keep you warm and fashionable. Great for layering.';
      case 'jumpsuit':
        return 'Trendy $productName that offers comfort and style in one piece. Perfect for modern women.';
      default:
        return 'Beautiful $productName that combines style and comfort. A perfect addition to your wardrobe.';
    }
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
    return 'WomenProduct(id: $id, name: $name, category: $category, gender: $gender, isAvailable: $isAvailable)';
  }
}