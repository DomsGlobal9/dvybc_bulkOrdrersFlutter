import 'package:get/get.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Cart/Cart/CartController.dart';
import '../../Favorites/FavoritesController.dart';
import '../../model/Women/WomenModel.dart';

// Updated SingleProductController with loading state
class SingleProductController extends GetxController {
  final Rx<WomenProduct?> currentProduct = Rx<WomenProduct?>(null);
  final RxList<String> selectedSizes = <String>['M'].obs;
  final RxMap<String, int> selectedSizeQuantities = <String, int>{'M': 1}.obs;
  final Rx<Color> selectedColor = Colors.red.obs;
  final RxBool isFavorite = false.obs;
  final RxInt quantity = 1.obs;
  final RxList<WomenProduct> similarProducts = <WomenProduct>[].obs;
  final RxBool isLoadingSimilar = false.obs;
  final RxBool isLoading = true.obs; // Main loading state for shimmer
  final RxString error = ''.obs;

  StreamSubscription<QuerySnapshot>? _similarProductsSubscription;

  FavoritesController get _favoritesController => Get.put(FavoritesController());
  CartController get _cartController => Get.put(CartController());

  final List<String> availableSizes = ['XS', 'S', 'M', 'L', 'XL', '2XL', '3XL', '4XL'];
  final List<Color> availableColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.pink,
  ];

  void initializeProduct(WomenProduct product) async {
    isLoading.value = true;

    currentProduct.value = product;
    selectedSizes.value = ['M'];
    selectedSizeQuantities.value = {'M': 1};

    isFavorite.value = _favoritesController.isWomenProductFavorited(product);

    // Load similar products
    loadSimilarProducts(product);

    // Minimum loading time for smooth UX
    await Future.delayed(Duration(milliseconds: 800));

    isLoading.value = false;
  }

  void loadSimilarProducts(WomenProduct product) {
    isLoadingSimilar.value = true;
    error.value = '';
    similarProducts.clear();

    _similarProductsSubscription?.cancel();

    try {
      print('🔍 Loading similar products for: ${product.name}');
      print('Current product dressType: ${product.dressType}');

      Query query = FirebaseFirestore.instance.collectionGroup('products');

      if (product.dressType != null && product.dressType!.isNotEmpty) {
        query = query.where('dressType', isEqualTo: product.dressType);
      } else {
        query = query.where('category', isEqualTo: product.category);
      }

      _similarProductsSubscription = query
          .limit(15)
          .snapshots()
          .listen(
            (QuerySnapshot snapshot) {
          print('📦 Found ${snapshot.docs.length} potential similar products');

          List<WomenProduct> similarList = [];

          for (QueryDocumentSnapshot doc in snapshot.docs) {
            try {
              if (doc.id == product.id) {
                print('⏭️ Skipping current product: ${doc.id}');
                continue;
              }

              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              String userId = doc.reference.parent.parent!.id;

              WomenProduct? similarProduct = _mapDocumentToWomenProduct(doc, data, userId);
              if (similarProduct != null) {
                if (similarProduct.name.isNotEmpty || (similarProduct.dressType?.isNotEmpty == true)) {
                  similarList.add(similarProduct);
                  print('✅ Added similar product: ${similarProduct.name}');
                }
              }
            } catch (e) {
              print('❌ Error processing similar product ${doc.id}: $e');
            }
          }

          similarList.shuffle();
          similarProducts.value = similarList.take(8).toList();
          isLoadingSimilar.value = false;

          print('✅ Final similar products count: ${similarProducts.length}');

          if (similarProducts.isEmpty) {
            print('🔄 No similar products found, trying broader search...');
            Timer(Duration(seconds: 3), () {
              if (similarProducts.isEmpty) {
                _loadBroaderSimilarProducts(product);
              }
            });
          }
        },
        onError: (e) {
          print('❌ Error loading similar products: $e');
          isLoadingSimilar.value = false;

          Timer(Duration(seconds: 5), () {
            if (similarProducts.isEmpty) {
              _generateFallbackSimilarProducts(product);
            }
          });
        },
      );
    } catch (e) {
      print('❌ Exception in loadSimilarProducts: $e');
      isLoadingSimilar.value = false;

      Timer(Duration(seconds: 5), () {
        if (similarProducts.isEmpty) {
          _generateFallbackSimilarProducts(product);
        }
      });
    }
  }

  void _loadBroaderSimilarProducts(WomenProduct product) {
    print('🔍 Loading broader similar products...');

    Query query = FirebaseFirestore.instance.collectionGroup('products')
        .where('category', isEqualTo: product.category)
        .limit(10);

    query.snapshots().listen((QuerySnapshot snapshot) {
      List<WomenProduct> similarList = [];

      for (QueryDocumentSnapshot doc in snapshot.docs) {
        if (doc.id == product.id) continue;

        try {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          String userId = doc.reference.parent.parent!.id;

          WomenProduct? similarProduct = _mapDocumentToWomenProduct(doc, data, userId);
          if (similarProduct != null) {
            similarList.add(similarProduct);
          }
        } catch (e) {
          print('❌ Error in broader search: $e');
        }
      }

      if (similarList.isNotEmpty) {
        similarList.shuffle();
        similarProducts.value = similarList.take(6).toList();
        isLoadingSimilar.value = false;
        print('🔍 Broader search found: ${similarProducts.length} products');
      } else {
        Timer(Duration(seconds: 3), () {
          if (similarProducts.isEmpty) {
            _generateFallbackSimilarProducts(product);
          }
        });
      }
    }, onError: (e) {
      print('❌ Broader search error: $e');
      Timer(Duration(seconds: 2), () {
        if (similarProducts.isEmpty) {
          _generateFallbackSimilarProducts(product);
        }
      });
    });
  }

  void _generateFallbackSimilarProducts(WomenProduct product) {
    print('📝 Generating fallback similar products...');

    List<WomenProduct> similar = [];
    List<String> similarNames = [];
    List<String> similarTypes = [];

    if (product.dressType != null) {
      switch (product.dressType!.toLowerCase()) {
        case 'kurti':
        case 'kurta':
          similarNames = ['Cotton Kurti', 'Silk Kurti', 'Designer Kurti', 'Printed Kurti', 'Embroidered Kurti'];
          similarTypes = ['kurti', 'kurti', 'kurti', 'kurti', 'kurti'];
          break;
        case 'saree':
          similarNames = ['Silk Saree', 'Cotton Saree', 'Designer Saree', 'Party Saree', 'Traditional Saree'];
          similarTypes = ['saree', 'saree', 'saree', 'saree', 'saree'];
          break;
        case 'dress':
          similarNames = ['Party Dress', 'Casual Dress', 'Formal Dress', 'Summer Dress', 'Evening Dress'];
          similarTypes = ['dress', 'dress', 'dress', 'dress', 'dress'];
          break;
        case 'top':
          similarNames = ['Casual Top', 'Designer Top', 'Cotton Top', 'Silk Top', 'Party Top'];
          similarTypes = ['top', 'top', 'top', 'top', 'top'];
          break;
        default:
          similarNames = ['Fashion Top', 'Designer Wear', 'Casual Wear', 'Party Wear', 'Traditional Wear'];
          similarTypes = ['top', 'dress', 'kurti', 'saree', 'top'];
      }
    } else {
      similarNames = ['Fashion Top', 'Designer Wear', 'Casual Wear', 'Party Wear', 'Traditional Wear'];
      similarTypes = ['top', 'dress', 'kurti', 'saree', 'top'];
    }

    for (int i = 0; i < similarNames.length && i < 5; i++) {
      similar.add(WomenProduct(
        id: 'fallback_${i + 1}',
        name: similarNames[i],
        image: '',
        category: product.category,
        description: 'Beautiful ${similarNames[i].toLowerCase()} with premium quality fabric and elegant design.',
        gender: product.gender,
        subcategory: product.subcategory,
        dressType: similarTypes[i],
        price: (800 + (i * 200)),
        imageUrls: [],
      ));
    }

    similarProducts.value = similar;
    isLoadingSimilar.value = false;
    print('✅ Generated ${similar.length} fallback products');
  }

  WomenProduct? _mapDocumentToWomenProduct(QueryDocumentSnapshot doc, Map<String, dynamic> data, String userId) {
    try {
      List<String> imageUrls = [];
      if (data['imageUrls'] is List) {
        imageUrls = List<String>.from(data['imageUrls']);
      } else if (data['imageURLs'] is List) {
        imageUrls = List<String>.from(data['imageURLs']);
      }

      List<String> selectedColors = [];
      if (data['selectedColors'] is List) {
        selectedColors = List<String>.from(data['selectedColors']);
      }

      List<String> selectedSizes = [];
      if (data['selectedSizes'] is List) {
        selectedSizes = List<String>.from(data['selectedSizes']);
      }

      int? price;
      if (data['price'] != null) {
        if (data['price'] is String) {
          price = int.tryParse(data['price']);
        } else if (data['price'] is int) {
          price = data['price'];
        }
      }

      String productName = data['title']?.toString() ??
          data['name']?.toString() ??
          data['dressType']?.toString() ??
          'Fashion Item';

      return WomenProduct(
        id: doc.id,
        name: productName,
        image: imageUrls.isNotEmpty ? imageUrls.first : '',
        category: data['category']?.toString() ?? 'WOMEN',
        description: data['description']?.toString() ?? 'Beautiful fashion item',
        gender: data['category']?.toString() ?? 'WOMEN',
        subcategory: data['dressType']?.toString() ?? 'fashion',
        imageUrls: imageUrls,
        productId: doc.id,
        productSize: selectedSizes.isNotEmpty ? selectedSizes.first : null,
        totalImages: imageUrls.length,
        userId: userId,
        userName: data['userName']?.toString(),
        isActive: data['isActive'] ?? true,
        price: price,
        design: data['craft']?.toString(),
        dressType: data['dressType']?.toString(),
        material: data['fabric']?.toString(),
        selectedColors: selectedColors,
        selectedSizes: selectedSizes,
        createdAt: data['createdAt'],
        timestamp: data['timestamp'],
        units: data['units'],
      );
    } catch (e) {
      print('❌ Error mapping document ${doc.id}: $e');
      return null;
    }
  }

  void selectColor(Color color) {
    selectedColor.value = color;
  }

  void selectSize(String size) {
    selectedSizes.value = [size];
    selectedSizeQuantities.value = {size: 1};
  }

  bool isSizeSelected(String size) {
    return selectedSizes.contains(size);
  }

  void toggleFavorite() {
    if (currentProduct.value != null) {
      _favoritesController.toggleWomenProductFavorite(
        currentProduct.value!,
        getRandomPrice(),
      );
      isFavorite.value = _favoritesController.isWomenProductFavorited(currentProduct.value!);
    }
  }

  void incrementQuantity() {
    quantity.value++;
  }

  void decrementQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  void addToCart() {
    if (currentProduct.value != null) {
      _showAddToCartModal();
    }
  }

  void _showAddToCartModal() {
    String currentSize = selectedSizes.isNotEmpty ? selectedSizes.first : 'M';

    Get.bottomSheet(
      AddToCartModal(
        currentSelectedSize: currentSize,
        currentSelections: Map<String, int>.from(selectedSizeQuantities),
        onAddToCart: (Map<String, int> selectedSizesWithQuantities) {
          selectedSizes.value = selectedSizesWithQuantities.keys.toList();
          selectedSizeQuantities.value = selectedSizesWithQuantities;

          int totalQuantity = selectedSizesWithQuantities.values.fold(0, (sum, qty) => sum + qty);
          quantity.value = totalQuantity;

          for (String size in selectedSizesWithQuantities.keys) {
            int quantity = selectedSizesWithQuantities[size]!;

            for (int i = 0; i < quantity; i++) {
              _cartController.addWomenProductToCart(
                currentProduct.value!,
                getRandomPrice(),
                size,
                selectedColor.value,
              );
            }
          }

          String summaryMessage = '';
          List<String> sizeSummaries = [];

          selectedSizesWithQuantities.forEach((size, quantity) {
            sizeSummaries.add('$size: $quantity units');
          });

          summaryMessage = sizeSummaries.join(', ');

          Get.snackbar(
            'Added to Cart',
            '${currentProduct.value!.name} ($summaryMessage) has been added to your cart',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Color(0xFF10B981),
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void buyNow() {
    if (!currentProduct.value!.name.toLowerCase().contains('saree') && selectedSizes.isEmpty) {
      return;
    }

    if (currentProduct.value != null && selectedSizes.isNotEmpty) {
      _cartController.addWomenProductToCart(
        currentProduct.value!,
        getRandomPrice(),
        selectedSizes.first,
        selectedColor.value,
      );
    }

    Future.delayed(Duration(seconds: 1), () {
      Get.toNamed('/cart');
    });
  }

  void retrySimilarProducts() {
    if (currentProduct.value != null) {
      error.value = '';
      loadSimilarProducts(currentProduct.value!);
    }
  }

  String getRandomPrice() {
    List<int> prices = [299, 399, 499, 599, 699, 799, 899, 999, 1199, 1299, 1499, 1699, 1899, 2099, 2299];
    return prices[currentProduct.value!.id.hashCode.abs() % prices.length].toString();
  }

  String getRandomOriginalPrice() {
    int currentPrice = int.parse(getRandomPrice());
    int originalPrice = (currentPrice * 1.4).round();
    return originalPrice.toString();
  }

  String getDiscount() {
    int currentPrice = int.parse(getRandomPrice());
    int originalPrice = int.parse(getRandomOriginalPrice());
    int discount = (((originalPrice - currentPrice) / originalPrice) * 100).round();
    return discount.toString();
  }

  @override
  void onClose() {
    _similarProductsSubscription?.cancel();
    super.onClose();
  }
}

// Add to Cart Modal Widget
class AddToCartModal extends StatelessWidget {
  final Function(Map<String, int> selectedSizesWithQuantities) onAddToCart;
  final String currentSelectedSize;
  final Map<String, int> currentSelections;

  const AddToCartModal({
    Key? key,
    required this.onAddToCart,
    this.currentSelectedSize = 'M',
    this.currentSelections = const {},
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RxList<String> selectedSizes = <String>[].obs;
    final RxMap<String, int> sizeQuantities = <String, int>{}.obs;
    final Map<String, TextEditingController> controllers = {};

    final List<Map<String, dynamic>> sizeData = [
      {'size': 'XS', 'available': 12},
      {'size': 'S', 'available': 1},
      {'size': 'M', 'available': 1},
      {'size': 'L', 'available': 1},
      {'size': 'XL', 'available': 1},
      {'size': '2XL', 'available': 1},
      {'size': '3XL', 'available': 1},
      {'size': '4XL', 'available': 1},
    ];

    for (var sizeInfo in sizeData) {
      String size = sizeInfo['size'];
      int currentQty = currentSelections[size] ?? 0;
      controllers[size] = TextEditingController(text: currentQty.toString());
      sizeQuantities[size] = currentQty;

      if (currentQty > 0) {
        selectedSizes.add(size);
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Size & Quantity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.close,
                      color: Colors.grey[600],
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Obx(() => Column(
                  children: sizeData.map((sizeInfo) {
                    String size = sizeInfo['size'];
                    int available = sizeInfo['available'];
                    bool isSelected = selectedSizes.contains(size);

                    return Container(
                      margin: EdgeInsets.only(bottom: 8),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? Color(0xFF98C0D9) : Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? Color(0xFF094D77) : Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (isSelected) {
                                selectedSizes.remove(size);
                                controllers[size]?.text = '0';
                                sizeQuantities[size] = 0;
                              } else {
                                selectedSizes.add(size);
                                controllers[size]?.text = '1';
                                sizeQuantities[size] = 1;
                              }
                            },
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: isSelected ? Color(0xFF094D77) : Colors.transparent,
                                border: Border.all(
                                  color: isSelected ? Color(0xFF094D77) : Colors.grey[400]!,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: isSelected
                                  ? Icon(Icons.check, color: Colors.white, size: 14)
                                  : null,
                            ),
                          ),
                          SizedBox(width: 12),
                          Container(
                            width: 40,
                            child: Text(
                              size,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Color(0xFF094D77) : Colors.black87,
                              ),
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('E.x', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                SizedBox(height: 2),
                                Text('Available', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                              ],
                            ),
                          ),
                          Container(
                            width: 30,
                            child: Text(
                              available.toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? Color(0xFF094D77) : Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(width: 20),
                          Container(
                            width: 60,
                            height: 35,
                            child: TextField(
                              controller: controllers[size],
                              keyboardType: TextInputType.number,
                              enabled: isSelected,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? Color(0xFF094D77) : Colors.grey[400],
                              ),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: BorderSide(
                                    color: isSelected ? Color(0xFF094D77) : Colors.grey[300]!,
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: BorderSide(
                                    color: isSelected ? Color(0xFF094D77) : Colors.grey[300]!,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: BorderSide(color: Color(0xFF094D77), width: 2),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                                ),
                                filled: true,
                                fillColor: isSelected ? Color(0xFF98C0D9).withOpacity(0.3) : Colors.grey[100],
                                hintText: '0',
                                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                              ),
                              onChanged: (value) {
                                int quantity = int.tryParse(value) ?? 0;
                                sizeQuantities[size] = quantity;

                                if (quantity > 0 && !selectedSizes.contains(size)) {
                                  selectedSizes.add(size);
                                } else if (quantity == 0 && selectedSizes.contains(size)) {
                                  selectedSizes.remove(size);
                                }
                              },
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('Units', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                    );
                  }).toList(),
                )),
                SizedBox(height: 32),
                Container(
                  width: 203,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Map<String, int> selectedSizesWithQuantities = {};
                      for (String size in selectedSizes) {
                        int quantity = sizeQuantities[size] ?? 0;
                        if (quantity > 0) {
                          selectedSizesWithQuantities[size] = quantity;
                        }
                      }

                      if (selectedSizesWithQuantities.isNotEmpty) {
                        onAddToCart(selectedSizesWithQuantities);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF094D77),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      elevation: 0,
                    ),
                    child: Text('Save change', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}