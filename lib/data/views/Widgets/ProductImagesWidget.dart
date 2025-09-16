// import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';
//
// class ProductImagesWidget extends StatefulWidget {
//   final List<String> imageUrls;
//   final double height;
//   final double? width;
//
//   const ProductImagesWidget({
//     Key? key,
//     required this.imageUrls,
//     this.height = 400,
//     this.width,
//   }) : super(key: key);
//
//   @override
//   State<ProductImagesWidget> createState() => _ProductImagesWidgetState();
// }
//
// class _ProductImagesWidgetState extends State<ProductImagesWidget> {
//   int selectedImageIndex = 0;
//   PageController pageController = PageController();
//
//   @override
//   void dispose() {
//     pageController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (widget.imageUrls.isEmpty) {
//       return Container(
//         height: widget.height,
//         width: widget.width ?? double.infinity,
//         decoration: BoxDecoration(
//           color: Colors.grey[200],
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: const Center(
//           child: Icon(
//             Icons.image_not_supported,
//             size: 60,
//             color: Colors.grey,
//           ),
//         ),
//       );
//     }
//
//     return Container(
//       height: widget.height,
//       width: widget.width ?? double.infinity,
//       child: Row(
//         children: [
//           // Thumbnail column on the left
//           Container(
//             width: 80,
//             child: Column(
//               children: [
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: widget.imageUrls.length,
//                     itemBuilder: (context, index) {
//                       return GestureDetector(
//                         onTap: () {
//                           setState(() {
//                             selectedImageIndex = index;
//                           });
//                           pageController.animateToPage(
//                             index,
//                             duration: const Duration(milliseconds: 300),
//                             curve: Curves.easeInOut,
//                           );
//                         },
//                         child: Container(
//                           height: 70,
//                           margin: const EdgeInsets.only(bottom: 8, right: 8),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(
//                               color: selectedImageIndex == index
//                                   ? Theme.of(context).primaryColor
//                                   : Colors.grey[300]!,
//                               width: selectedImageIndex == index ? 2 : 1,
//                             ),
//                           ),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(6),
//                             child: CachedNetworkImage(
//                               imageUrl: widget.imageUrls[index],
//                               fit: BoxFit.cover,
//                               placeholder: (context, url) => Container(
//                                 color: Colors.grey[200],
//                                 child: const Center(
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                   ),
//                                 ),
//                               ),
//                               errorWidget: (context, url, error) => Container(
//                                 color: Colors.grey[200],
//                                 child: const Icon(
//                                   Icons.broken_image,
//                                   color: Colors.grey,
//                                   size: 30,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // Main image display
//           Expanded(
//             child: Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(12),
//                 color: Colors.grey[50],
//               ),
//               child: Stack(
//                 children: [
//                   PageView.builder(
//                     controller: pageController,
//                     onPageChanged: (index) {
//                       setState(() {
//                         selectedImageIndex = index;
//                       });
//                     },
//                     itemCount: widget.imageUrls.length,
//                     itemBuilder: (context, index) {
//                       return ClipRRect(
//                         borderRadius: BorderRadius.circular(12),
//                         child: CachedNetworkImage(
//                           imageUrl: widget.imageUrls[index],
//                           fit: BoxFit.cover,
//                           width: double.infinity,
//                           height: double.infinity,
//                           placeholder: (context, url) => Container(
//                             color: Colors.grey[200],
//                             child: const Center(
//                               child: CircularProgressIndicator(),
//                             ),
//                           ),
//                           errorWidget: (context, url, error) => Container(
//                             color: Colors.grey[200],
//                             child: const Center(
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(
//                                     Icons.broken_image,
//                                     size: 60,
//                                     color: Colors.grey,
//                                   ),
//                                   SizedBox(height: 8),
//                                   Text(
//                                     'Image not available',
//                                     style: TextStyle(
//                                       color: Colors.grey,
//                                       fontSize: 14,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//
//                   // Image counter indicator
//                   if (widget.imageUrls.length > 1)
//                     Positioned(
//                       top: 16,
//                       right: 16,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 6,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.black.withOpacity(0.7),
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Text(
//                           '${selectedImageIndex + 1}/${widget.imageUrls.length}',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 12,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ),
//
//                   // Navigation arrows (optional)
//                   if (widget.imageUrls.length > 1) ...[
//                     // Previous button
//                     Positioned(
//                       left: 16,
//                       top: 0,
//                       bottom: 0,
//                       child: Center(
//                         child: GestureDetector(
//                           onTap: () {
//                             if (selectedImageIndex > 0) {
//                               pageController.previousPage(
//                                 duration: const Duration(milliseconds: 300),
//                                 curve: Curves.easeInOut,
//                               );
//                             }
//                           },
//                           child: Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: Colors.black.withOpacity(0.5),
//                               shape: BoxShape.circle,
//                             ),
//                             child: Icon(
//                               Icons.chevron_left,
//                               color: selectedImageIndex > 0
//                                   ? Colors.white
//                                   : Colors.white.withOpacity(0.5),
//                               size: 24,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     // Next button
//                     Positioned(
//                       right: 16,
//                       top: 0,
//                       bottom: 0,
//                       child: Center(
//                         child: GestureDetector(
//                           onTap: () {
//                             if (selectedImageIndex < widget.imageUrls.length - 1) {
//                               pageController.nextPage(
//                                 duration: const Duration(milliseconds: 300),
//                                 curve: Curves.easeInOut,
//                               );
//                             }
//                           },
//                           child: Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: Colors.black.withOpacity(0.5),
//                               shape: BoxShape.circle,
//                             ),
//                             child: Icon(
//                               Icons.chevron_right,
//                               color: selectedImageIndex < widget.imageUrls.length - 1
//                                   ? Colors.white
//                                   : Colors.white.withOpacity(0.5),
//                               size: 24,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // Simple version for product cards
// class ProductCardImage extends StatelessWidget {
//   final List<String> imageUrls;
//   final double height;
//   final double? width;
//
//   const ProductCardImage({
//     Key? key,
//     required this.imageUrls,
//     this.height = 200,
//     this.width,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     if (imageUrls.isEmpty) {
//       return Container(
//         height: height,
//         width: width,
//         decoration: BoxDecoration(
//           color: Colors.grey[200],
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: const Center(
//           child: Icon(
//             Icons.image_not_supported,
//             size: 40,
//             color: Colors.grey,
//           ),
//         ),
//       );
//     }
//
//     return Container(
//       height: height,
//       width: width,
//       child: Stack(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: CachedNetworkImage(
//               imageUrl: imageUrls.first,
//               fit: BoxFit.cover,
//               width: double.infinity,
//               height: double.infinity,
//               placeholder: (context, url) => Container(
//                 color: Colors.grey[200],
//                 child: const Center(
//                   child: CircularProgressIndicator(strokeWidth: 2),
//                 ),
//               ),
//               errorWidget: (context, url, error) => Container(
//                 color: Colors.grey[200],
//                 child: const Center(
//                   child: Icon(
//                     Icons.broken_image,
//                     color: Colors.grey,
//                     size: 30,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//
//           // Image count indicator
//           if (imageUrls.length > 1)
//             Positioned(
//               bottom: 8,
//               right: 8,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 8,
//                   vertical: 4,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.7),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Icon(
//                       Icons.photo_library,
//                       color: Colors.white,
//                       size: 12,
//                     ),
//                     const SizedBox(width: 4),
//                     Text(
//                       '${imageUrls.length}',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 10,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }