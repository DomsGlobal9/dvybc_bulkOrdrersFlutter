import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../views/home/homeScreen.dart';
import '../model/Women/WomenModel.dart';

// Create a unified interface for favorite products
abstract class FavoriteItem {
  String get title;
  String get price;
  String get imagePath;
  bool get isFavorited;
  set isFavorited(bool value);
  String get id;
}

// Create adapter for regular Product (from home screen)
class ProductAdapter implements FavoriteItem {
  final Product _product;
  bool _isFavorited;

  ProductAdapter(this._product, [this._isFavorited = false]);

  @override
  String get title => _product.title;

  @override
  String get price => _product.price;

  @override
  String get imagePath => _product.imagePath;

  @override
  bool get isFavorited => _isFavorited;

  @override
  set isFavorited(bool value) => _isFavorited = value;

  @override
  String get id => _product.title; // Use title as unique ID

  Product get product => _product;
}

// Create adapter for WomenProduct
class WomenProductAdapter implements FavoriteItem {
  final WomenProduct _womenProduct;
  final String _price;
  bool _isFavorited;

  WomenProductAdapter(this._womenProduct, this._price, [this._isFavorited = false]);

  @override
  String get title => _womenProduct.name;

  @override
  String get price => '₹$_price';

  @override
  String get imagePath => _womenProduct.image;

  @override
  bool get isFavorited => _isFavorited;

  @override
  set isFavorited(bool value) => _isFavorited = value;

  @override
  String get id => _womenProduct.id;

  WomenProduct get womenProduct => _womenProduct;
}

class FavoritesController extends GetxController {
  // Observable list to store favorite products (unified interface)
  var favoriteProducts = <FavoriteItem>[].obs;

  // Add product to favorites
  void addToFavorites(FavoriteItem product) {
    if (!favoriteProducts.any((p) => p.id == product.id)) {
      product.isFavorited = true;
      favoriteProducts.add(product);
      Get.snackbar(
        'Added to Wishlist',
        '${product.title} has been added to your wishlist',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Color(0xFF1976D2),
        colorText: Colors.white,
        duration: Duration(seconds: 2),
        margin: EdgeInsets.all(16),
        borderRadius: 8,
      );
    }
  }

  // Remove product from favorites
  void removeFromFavorites(FavoriteItem product) {
    product.isFavorited = false;
    favoriteProducts.removeWhere((p) => p.id == product.id);
    Get.snackbar(
      'Removed from Wishlist',
      '${product.title} has been removed from your wishlist',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red[400],
      colorText: Colors.white,
      duration: Duration(seconds: 2),
      margin: EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  // Toggle favorite status
  void toggleFavorite(FavoriteItem product) {
    if (isFavorited(product)) {
      removeFromFavorites(product);
    } else {
      addToFavorites(product);
    }
  }

  // Check if product is favorited
  bool isFavorited(FavoriteItem product) {
    return favoriteProducts.any((p) => p.id == product.id);
  }

  // Clear all favorites
  void clearAllFavorites() {
    for (var product in favoriteProducts) {
      product.isFavorited = false;
    }
    favoriteProducts.clear();
    Get.snackbar(
      'Cleared Wishlist',
      'All items removed from your wishlist',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange[400],
      colorText: Colors.white,
      duration: Duration(seconds: 2),
      margin: EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  // Helper methods for easy integration

  // Add Product (from home screen) - FIXED
  void addProductToFavorites(Product product) {
    final adapter = ProductAdapter(product);
    addToFavorites(adapter);
  }

  // Add WomenProduct (from single product view)
  void addWomenProductToFavorites(WomenProduct womenProduct, String price) {
    final adapter = WomenProductAdapter(womenProduct, price);
    addToFavorites(adapter);
  }

  // Toggle Product favorite - FIXED
  void toggleProductFavorite(Product product) {
    // Check if already exists
    final existingIndex = favoriteProducts.indexWhere((p) => p.id == product.title);

    if (existingIndex >= 0) {
      // Already exists, remove it
      removeFromFavorites(favoriteProducts[existingIndex]);
    } else {
      // Doesn't exist, add it
      final adapter = ProductAdapter(product);
      addToFavorites(adapter);
    }
  }

  // Toggle WomenProduct favorite
  void toggleWomenProductFavorite(WomenProduct womenProduct, String price) {
    // Check if already exists
    final existingIndex = favoriteProducts.indexWhere((p) => p.id == womenProduct.id);

    if (existingIndex >= 0) {
      // Already exists, remove it
      removeFromFavorites(favoriteProducts[existingIndex]);
    } else {
      // Doesn't exist, add it
      final adapter = WomenProductAdapter(womenProduct, price);
      addToFavorites(adapter);
    }
  }

  // Check if WomenProduct is favorited
  bool isWomenProductFavorited(WomenProduct womenProduct) {
    return favoriteProducts.any((p) => p.id == womenProduct.id);
  }

  // Check if Product is favorited
  bool isProductFavorited(Product product) {
    return favoriteProducts.any((p) => p.id == product.title);
  }

  // Get favorites count
  int get favoritesCount => favoriteProducts.length;
}