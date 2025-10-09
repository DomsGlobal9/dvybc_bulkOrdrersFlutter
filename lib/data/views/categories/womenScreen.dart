// import 'package:flutter/material.dart';
//
// import 'package:get/get.dart';
//
// import 'package:shimmer/shimmer.dart';
//
// import '../../../model/Women/WomenModel.dart';
//
// import '../../../viewModel/Women/ProductDetailViewModel.dart';
//
// import '../../home/CustomAppBar.dart';
//
//
//
// class ProductDetailView extends StatelessWidget {
//
//   const ProductDetailView({Key? key}) : super(key: key);
//
//
//
//   @override
//
//   Widget build(BuildContext context) {
//
//     final ProductDetailController controller = Get.put(ProductDetailController());
//
//     final String productName = Get.arguments['productName'] ?? '';
//
//     final String category = Get.arguments['category'] ?? '';
//
//
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//
//       controller.loadProductVariations(productName, category);
//
//     });
//
//
//
//     return Scaffold(
//
//       backgroundColor: Colors.white,
//
//       appBar: CustomAppBar(),
//
//       body: Obx(() {
//
//         if (controller.isLoading.value) {
//
//           return _buildShimmerLoading();
//
//         }
//
//
//
//         return Column(
//
//           children: [
//
//             Container(
//
//               padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//
//               color: Colors.white,
//
//               child: Row(
//
//                 children: [
//
// // Back button
//
//                   IconButton(
//
//                     icon: Icon(Icons.arrow_back, color: Colors.black),
//
//                     onPressed: () => Get.back(),
//
//                     padding: EdgeInsets.zero,
//
//                     constraints: BoxConstraints(),
//
//                   ),
//
//                   SizedBox(width: 12),
//
// // Product name
//
//                   Expanded(
//
//                     child: Text(
//
//                       productName,
//
//                       style: TextStyle(
//
//                         fontSize: 20,
//
//                         fontWeight: FontWeight.w600,
//
//                         color: Colors.black,
//
//                         fontFamily: 'Outfit',
//
//                       ),
//
//                     ),
//
//                   ),
//
// // Filter button
//
//                   GestureDetector(
//
//                     onTap: () => controller.openFilterModal(),
//
//                     child: Container(
//
//                       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//
//                       decoration: BoxDecoration(
//
//                         border: Border.all(
//
//                           color: Color(0xFF447B9E),
//
//                           width: 0.6,
//
//                         ),
//
//                         borderRadius: BorderRadius.circular(4),
//
//                       ),
//
//                       child: Row(
//
//                         mainAxisSize: MainAxisSize.min,
//
//                         children: [
//
//                           Icon(
//
//                             Icons.tune,
//
//                             color: Color(0xFF447B9E),
//
//                             size: 18,
//
//                           ),
//
//                           SizedBox(width: 6),
//
//                           Text(
//
//                             'Filter',
//
//                             style: TextStyle(
//
//                               color: Color(0xFF447B9E),
//
//                               fontSize: 14,
//
//                               fontWeight: FontWeight.w500,
//
//                               fontFamily: 'Outfit',
//
//                             ),
//
//                           ),
//
//                         ],
//
//                       ),
//
//                     ),
//
//                   ),
//
//                 ],
//
//               ),
//
//             ),
//
//
//
// // Product Grid
//
//             Expanded(
//
//               child: controller.filteredProducts.isEmpty
//
//                   ? SizedBox()
//
//                   : GridView.builder(
//
//                 padding: EdgeInsets.all(16),
//
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//
//                   crossAxisCount: 2,
//
//                   childAspectRatio: 0.7,
//
//                   mainAxisSpacing: 16,
//
//                   crossAxisSpacing: 16,
//
//                 ),
//
//                 itemCount: controller.filteredProducts.length,
//
//                 itemBuilder: (context, index) {
//
//                   return _buildProductCard(controller.filteredProducts[index]);
//
//                 },
//
//               ),
//
//             ),
//
//           ],
//
//         );
//
//       }),
//
//     );
//
//   }
//
//
//
//   Widget _buildShimmerLoading() {
//
//     return Column(
//
//       children: [
//
//         Container(
//
//           padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//
//           color: Colors.white,
//
//           child: Row(
//
//             children: [
//
//               Shimmer.fromColors(
//
//                 baseColor: Colors.grey[300]!,
//
//                 highlightColor: Colors.grey[100]!,
//
//                 child: Container(
//
//                   width: 40,
//
//                   height: 40,
//
//                   decoration: BoxDecoration(
//
//                     color: Colors.white,
//
//                     borderRadius: BorderRadius.circular(8),
//
//                   ),
//
//                 ),
//
//               ),
//
//               SizedBox(width: 12),
//
//               Expanded(
//
//                 child: Shimmer.fromColors(
//
//                   baseColor: Colors.grey[300]!,
//
//                   highlightColor: Colors.grey[100]!,
//
//                   child: Container(
//
//                     height: 24,
//
//                     decoration: BoxDecoration(
//
//                       color: Colors.white,
//
//                       borderRadius: BorderRadius.circular(4),
//
//                     ),
//
//                   ),
//
//                 ),
//
//               ),
//
//               SizedBox(width: 12),
//
//               Shimmer.fromColors(
//
//                 baseColor: Colors.grey[300]!,
//
//                 highlightColor: Colors.grey[100]!,
//
//                 child: Container(
//
//                   width: 80,
//
//                   height: 36,
//
//                   decoration: BoxDecoration(
//
//                     color: Colors.white,
//
//                     borderRadius: BorderRadius.circular(4),
//
//                   ),
//
//                 ),
//
//               ),
//
//             ],
//
//           ),
//
//         ),
//
//         Expanded(
//
//           child: GridView.builder(
//
//             padding: EdgeInsets.all(16),
//
//             shrinkWrap: true,
//
//             physics: NeverScrollableScrollPhysics(),
//
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//
//               crossAxisCount: 2,
//
//               childAspectRatio: 0.7,
//
//               mainAxisSpacing: 16,
//
//               crossAxisSpacing: 16,
//
//             ),
//
//             itemCount: 6,
//
//             itemBuilder: (context, index) {
//
//               return _buildShimmerProductCard();
//
//             },
//
//           ),
//
//         ),
//
//       ],
//
//     );
//
//   }
//
//
//
//   Widget _buildShimmerProductCard() {
//
//     return Shimmer.fromColors(
//
//       baseColor: Colors.grey[300]!,
//
//       highlightColor: Colors.grey[100]!,
//
//       child: Container(
//
//         decoration: BoxDecoration(
//
//           color: Colors.white,
//
//           borderRadius: BorderRadius.circular(8),
//
//         ),
//
//         child: Column(
//
//           crossAxisAlignment: CrossAxisAlignment.start,
//
//           children: [
//
//             Expanded(
//
//               child: Container(
//
//                 decoration: BoxDecoration(
//
//                   color: Colors.white,
//
//                   borderRadius: BorderRadius.circular(8),
//
//                 ),
//
//               ),
//
//             ),
//
//             Padding(
//
//               padding: EdgeInsets.all(8),
//
//               child: Column(
//
//                 crossAxisAlignment: CrossAxisAlignment.start,
//
//                 children: [
//
//                   Container(
//
//                     width: double.infinity,
//
//                     height: 14,
//
//                     decoration: BoxDecoration(
//
//                       color: Colors.white,
//
//                       borderRadius: BorderRadius.circular(4),
//
//                     ),
//
//                   ),
//
//                   SizedBox(height: 8),
//
//                   Container(
//
//                     width: 60,
//
//                     height: 12,
//
//                     decoration: BoxDecoration(
//
//                       color: Colors.white,
//
//                       borderRadius: BorderRadius.circular(4),
//
//                     ),
//
//                   ),
//
//                 ],
//
//               ),
//
//             ),
//
//           ],
//
//         ),
//
//       ),
//
//     );
//
//   }
//
//
//
//   Widget _buildEmptyState() {
//
//     return Container(
//
//       padding: EdgeInsets.all(40),
//
//       child: Column(
//
//         mainAxisAlignment: MainAxisAlignment.center,
//
//         children: [
//
//           Icon(
//
//             Icons.search_off,
//
//             size: 80,
//
//             color: Colors.grey[300],
//
//           ),
//
//           SizedBox(height: 16),
//
//           Text(
//
//             'No products found',
//
//             style: TextStyle(
//
//               fontSize: 18,
//
//               fontWeight: FontWeight.w600,
//
//               color: Colors.grey[600],
//
//               fontFamily: 'Outfit',
//
//             ),
//
//           ),
//
//           SizedBox(height: 8),
//
//           Text(
//
//             'Try adjusting your filters or search terms',
//
//             style: TextStyle(
//
//               fontSize: 14,
//
//               color: Colors.grey[500],
//
//               fontFamily: 'Outfit',
//
//             ),
//
//             textAlign: TextAlign.center,
//
//           ),
//
//           SizedBox(height: 20),
//
//           ElevatedButton(
//
//             onPressed: () => Get.find<ProductDetailController>().clearAllFilters(),
//
//             style: ElevatedButton.styleFrom(
//
//               backgroundColor: Color(0xFF447B9E),
//
//               padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//
//               shape: RoundedRectangleBorder(
//
//                 borderRadius: BorderRadius.circular(25),
//
//               ),
//
//             ),
//
//             child: Text(
//
//               'Clear Filters',
//
//               style: TextStyle(
//
//                 color: Colors.white,
//
//                 fontWeight: FontWeight.w600,
//
//                 fontFamily: 'Outfit',
//
//               ),
//
//             ),
//
//           ),
//
//         ],
//
//       ),
//
//     );
//
//   }
//
//
//
//   Widget _buildProductCard(WomenProduct product) {
//
//     return GestureDetector(
//
//       onTap: () {
//
//         Get.toNamed('/product-single', arguments: {
//
//           'product': product,
//
//         });
//
//       },
//
//       child: Container(
//
//         decoration: BoxDecoration(
//
//           color: Colors.white,
//
//           borderRadius: BorderRadius.circular(8),
//
//           boxShadow: [
//
//             BoxShadow(
//
//               color: Colors.grey.withOpacity(0.1),
//
//               spreadRadius: 1,
//
//               blurRadius: 4,
//
//               offset: Offset(0, 2),
//
//             ),
//
//           ],
//
//         ),
//
//         child: Column(
//
//           crossAxisAlignment: CrossAxisAlignment.start,
//
//           children: [
//
//             Expanded(
//
//               child: Stack(
//
//                 children: [
//
//                   ClipRRect(
//
//                     borderRadius: BorderRadius.only(
//
//                       topLeft: Radius.circular(8),
//
//                       topRight: Radius.circular(8),
//
//                     ),
//
//                     child: product.image.isNotEmpty
//
//                         ? Image.network(
//
//                       product.image,
//
//                       fit: BoxFit.cover,
//
//                       width: double.infinity,
//
//                       height: double.infinity,
//
//                       errorBuilder: (context, error, stackTrace) {
//
//                         return Container(
//
//                           color: Colors.grey[200],
//
//                           child: Center(
//
//                             child: Icon(Icons.broken_image, size: 40, color: Colors.grey[400]),
//
//                           ),
//
//                         );
//
//                       },
//
//                     )
//
//                         : Container(
//
//                       color: Colors.grey[200],
//
//                       child: Center(
//
//                         child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey[400]),
//
//                       ),
//
//                     ),
//
//                   ),
//
// // Favorite button at top right
//
//                   Positioned(
//
//                     top: 8,
//
//                     right: 8,
//
//                     child: Container(
//
//                       padding: EdgeInsets.all(6),
//
//                       decoration: BoxDecoration(
//
//                         color: Colors.white,
//
//                         shape: BoxShape.circle,
//
//                       ),
//
//                       child: Icon(
//
//                         Icons.favorite_border,
//
//                         size: 18,
//
//                         color: Colors.grey[700],
//
//                       ),
//
//                     ),
//
//                   ),
//
// // Try on badge at bottom left
//
//                   Positioned(
//
//                     bottom: 0,
//
//                     left: 0,
//
//                     child: Container(
//
//                       width: 53,
//
//                       height: 18,
//
//                       decoration: BoxDecoration(
//
//                         color: Color(0xFFFFFAFA).withOpacity(0.8),
//
//                         borderRadius: BorderRadius.only(
//
//                           topRight: Radius.circular(4),
//
//                           bottomLeft: Radius.circular(4),
//
//                         ),
//
//                       ),
//
//                       child: Center(
//
//                         child: Text(
//
//                           'Try on',
//
//                           style: TextStyle(
//
//                             fontSize: 10,
//
//                             fontWeight: FontWeight.w500,
//
//                             color: Colors.black87,
//
//                             fontFamily: 'Outfit',
//
//                           ),
//
//                         ),
//
//                       ),
//
//                     ),
//
//                   ),
//
//                 ],
//
//               ),
//
//             ),
//
//             Padding(
//
//               padding: EdgeInsets.all(12),
//
//               child: Column(
//
//                 crossAxisAlignment: CrossAxisAlignment.start,
//
//                 children: [
//
//                   Text(
//
//                     product.name,
//
//                     style: TextStyle(
//
//                       fontSize: 14,
//
//                       fontWeight: FontWeight.w600,
//
//                       color: Colors.black87,
//
//                       fontFamily: 'Outfit',
//
//                     ),
//
//                     maxLines: 2,
//
//                     overflow: TextOverflow.ellipsis,
//
//                   ),
//
//                   SizedBox(height: 6),
//
//                   Text(
//
//                     '₹${product.price ?? (product.id.hashCode % 5000) + 500}',
//
//                     style: TextStyle(
//
//                       fontSize: 16,
//
//                       fontWeight: FontWeight.bold,
//
//                       color: Color(0xFF447B9E),
//
//                       fontFamily: 'Outfit',
//
//                     ),
//
//                   ),
//
//                 ],
//
//               ),
//
//             ),
//
//           ],
//
//         ),
//
//       ),
//
//     );
//
//   }
//
// }