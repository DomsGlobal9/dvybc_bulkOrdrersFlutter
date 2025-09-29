// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../Favorites/FavoritesController.dart';
// import '../../Favorites/FavoritesView.dart';
// import '../../Cart/CartController.dart';
// import '../../routes/routes.dart';
// import '../tabview/tabviews.dart';
//
// class Product {
//   final String title;
//   final String price;
//   final String imagePath;
//   final bool isAccessory;
//   bool isFavorited;
//
//   Product({
//     required this.title,
//     required this.price,
//     required this.imagePath,
//     this.isAccessory = false,
//     this.isFavorited = false,
//   });
// }
//
// class Category {
//   final String title;
//   final String imagePath;
//
//   Category({
//     required this.title,
//     required this.imagePath,
//   });
// }
//
//
//
// class HomeController extends GetxController with GetSingleTickerProviderStateMixin {
//   var categories = <Category>[
//     Category(title: 'WOMEN', imagePath: 'assets/images/womenfl.jpg'),
//     Category(title: 'MEN', imagePath: 'assets/images/jodpuri.jpg'),
//     Category(title: 'KIDS', imagePath: 'assets/images/kids.jpg'),
//     Category(title: 'Accessories', imagePath: 'assets/images/acces.jpg'),
//   ].obs;
//
//   var bestSellerProducts = <Product>[
//     Product(
//       title: 'Aarha Norangi Lehenga',
//       price: '₹2999',
//       imagePath: 'assets/images/womenfl.jpg',
//       isAccessory: true,
//     ),
//     Product(
//       title: 'Banarasi Saree',
//       price: '₹4999',
//       imagePath: 'assets/images/womenfl.jpg',
//       isAccessory: false,
//     ),
//     Product(
//       title: 'Baby Sets',
//       price: '₹1999',
//       imagePath: 'assets/images/kids.jpg',
//       isAccessory: true,
//     ),
//     Product(
//       title: 'Men\'s Formal Tie',
//       price: '₹250',
//       imagePath: 'assets/images/acces.jpg',
//       isAccessory: false,
//     ),
//   ].obs;
//
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//
//   @override
//   void onInit() {
//     super.onInit();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 500),
//     );
//     _fadeAnimation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     );
//     _animationController.forward();
//   }
//
//   @override
//   void onClose() {
//     _animationController.dispose();
//     super.onClose();
//   }
//
//   void onCategoryPressed(String category) {
//     Get.find<TabControllerX>().onTabTapped(2, category: category);
//   }
//
//   void onProductPressed(Product product) {
//     // Navigate to product details
//   }
//
//   void onFavoritePressed(Product product) {
//     final favController = Get.put(FavoritesController());
//     favController.toggleProductFavorite(product);
//   }
//
//   void onAddToCartPressed(Product product) {
//     final cartController = Get.put(CartController());
//     cartController.addProductToCart(product);
//   }
//
//   Animation<double> get fadeAnimation => _fadeAnimation;
// }