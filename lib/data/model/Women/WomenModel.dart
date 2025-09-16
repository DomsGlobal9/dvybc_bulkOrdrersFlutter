class WomenProduct {
  final String id;
  final String name;
  final String image;
  final String category;
  final String description;
  final String gender;
  final String subcategory;

  // Firebase fields based on your React model
  final List<String>? imageUrls;
  final String? productId;
  final String? productSize;
  final int? totalImages;
  final String? userId; // ID of the user who created this product
  final String? userName;
  final bool? isActive;
  final int? price;
  final String? design; // Maps to 'craft' in Firebase
  final String? dressType;
  final String? material; // Maps to 'fabric' in Firebase
  final List<String>? selectedColors;
  final List<String>? selectedSizes;
  final dynamic createdAt;
  final dynamic timestamp;
  final dynamic units; // Can be Map or other structure

  // Additional fields from your React model
  final String? title; // Alternative name field
  final String? craft; // Original craft field
  final String? fabric; // Original fabric field

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
    this.title,
    this.craft,
    this.fabric,
  });

  // Computed property for availability
  bool get isAvailable => isActive ?? true;

  // Get display name (prioritize title, fallback to name)
  String get displayName {
    if (title != null && title!.isNotEmpty) {
      return title!;
    }
    if (name.isNotEmpty) {
      return name;
    }
    if (design != null && design!.isNotEmpty) {
      return design!;
    }
    if (dressType != null && dressType!.isNotEmpty) {
      return dressType!;
    }
    return 'Fashion Item';
  }

  // Get material display (fabric or material)
  String get materialDisplay {
    if (fabric != null && fabric!.isNotEmpty) {
      return fabric!;
    }
    if (material != null && material!.isNotEmpty) {
      return material!;
    }
    return '';
  }

  // Get craft display (craft or design)
  String get craftDisplay {
    if (craft != null && craft!.isNotEmpty) {
      return craft!;
    }
    if (design != null && design!.isNotEmpty) {
      return design!;
    }
    return '';
  }

  // Computed MRP (mock calculation)
  int get mrp => (price ?? 1000) + 500;

  // Computed discount percentage
  int get discountPercent => price != null ? 15 : 0;

  // Factory constructor for creating from Firebase document (nested structure)
  factory WomenProduct.fromFirestore(Map<String, dynamic> data, String documentId, String userId) {
    // Extract image URLs with multiple fallbacks
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

    // Handle price conversion
    int? productPrice;
    if (data['price'] != null) {
      if (data['price'] is String) {
        productPrice = int.tryParse(data['price']);
      } else if (data['price'] is int) {
        productPrice = data['price'];
      } else if (data['price'] is double) {
        productPrice = (data['price'] as double).toInt();
      }
    }

    // Generate product name (prioritize title, fallback to name, then dressType)
    String productName = data['title']?.toString() ??
        data['name']?.toString() ??
        data['dressType']?.toString() ??
        'Fashion Item';

    return WomenProduct(
      id: documentId,
      name: productName,
      image: imageUrls.isNotEmpty ? imageUrls.first : '',
      category: data['category']?.toString() ?? 'WOMEN',
      description: data['description']?.toString() ?? _generateDescription(productName, data['dressType']?.toString(), data['fabric']?.toString()),
      gender: data['category']?.toString() ?? 'WOMEN',
      subcategory: data['dressType']?.toString() ?? 'fashion',
      imageUrls: imageUrls,
      productId: documentId,
      productSize: selectedSizes.isNotEmpty ? selectedSizes.first : null,
      totalImages: imageUrls.length,
      userId: userId, // Store the creating user's ID
      userName: data['userName']?.toString(),
      isActive: data['isActive'] ?? true,
      price: productPrice,
      design: data['craft']?.toString(), // Map craft to design
      dressType: data['dressType']?.toString(),
      material: data['fabric']?.toString(), // Map fabric to material
      selectedColors: selectedColors,
      selectedSizes: selectedSizes,
      createdAt: data['createdAt'],
      timestamp: data['timestamp'],
      units: data['units'],
      title: data['title']?.toString(),
      craft: data['craft']?.toString(),
      fabric: data['fabric']?.toString(),
    );
  }

  // Convert to JSON
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
      'title': title,
      'craft': craft,
      'fabric': fabric,
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
    dynamic units,
    String? title,
    String? craft,
    String? fabric,
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
      title: title ?? this.title,
      craft: craft ?? this.craft,
      fabric: fabric ?? this.fabric,
    );
  }

  // Generate description based on product data
  static String _generateDescription(String? productName, String? dressType, String? fabric) {
    if (productName == null) {
      return 'Beautiful fashion item for women';
    }

    String description = 'Stylish $productName';

    if (fabric != null && fabric.isNotEmpty) {
      description += ' made from premium $fabric';
    }

    if (dressType != null && dressType.isNotEmpty) {
      description += ' in $dressType style';
    }

    description += '. Perfect for modern women who value both comfort and style.';

    return description;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WomenProduct && other.id == id && other.userId == userId;
  }

  @override
  int get hashCode => id.hashCode ^ userId.hashCode;

  @override
  String toString() {
    return 'WomenProduct(id: $id, name: $name, userId: $userId, category: $category, price: $price, images: ${imageUrls?.length ?? 0})';
  }
}

// Static data model similar to your React implementation
class ProductDataModel {
  static List<String> getDressTypes() {
    return [
      "Traditional Lehenga",
      "Designer Saree",
      "Cotton Kurti",
      "Silk Dress",
      "Party Wear",
      "Casual Wear",
      "Wedding Wear",
      "Formal Wear"
    ];
  }

  static List<String> getMaterialTypes() {
    return [
      "Cotton",
      "Silk",
      "Silk Cotton",
      "Georgette",
      "Chiffon",
      "Net",
      "Velvet",
      "Crepe",
      "Khadi",
      "Tissue",
      "Pure Linen",
      "Kota",
      "Viscose",
      "Mulmul",
      "Organza",
    ];
  }

  static List<String> getDesignTypes() {
    return [
      "Embroidered",
      "Ajrakh",
      "Block Printed",
      "Batik",
      "Sanganeri",
      "Woven",
      "Printed",
      "Plain",
      "Sequined",
      "Beaded",
      "Mirror Work",
      "Dabu",
      "Shibori",
      "Mukasish",
      "Brocade",
      "Cutout",
      "Ikat",
      "Chikankariul"
    ];
  }

  static List<Map<String, dynamic>> getColors() {
    return [
      {"name": "Red", "value": "#ef4444", "code": "red"},
      {"name": "Pink", "value": "#ec4899", "code": "pink"},
      {"name": "Blue", "value": "#3b82f6", "code": "blue"},
      {"name": "Green", "value": "#10b981", "code": "green"},
      {"name": "Orange", "value": "#f97316", "code": "orange"},
      {"name": "Purple", "value": "#8b5cf6", "code": "purple"},
      {"name": "Black", "value": "#1f2937", "code": "black"},
    ];
  }

  static List<String> getSizes() {
    return ["XS", "S", "M", "L", "XL", "XXL"];
  }

  static Map<String, dynamic> getFormData() {
    return {
      "title": "",
      "description": "",
      "productType": "",
      "category": "",
      "dressType": "",
      "fabric": "",
      "craft": "",
      "price": "",
      "selectedSizes": <String>[],
      "selectedColors": <String>[],
      "units": <String, dynamic>{},
      "imageUrls": <String>[],
    };
  }
}