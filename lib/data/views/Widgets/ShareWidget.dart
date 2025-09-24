import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';

import '../../model/Women/WomenModel.dart';

class ShareService {
  // Generate a realistic, shareable product URL.
  static String generateProductShareUrl(WomenProduct product) {
    // Replace "e-shop.example.com" with your actual domain.
    String baseUrl = "https://e-shop.example.com/product";
    String productId = product.id;
    return "$baseUrl/$productId";
  }

  // Generic share using the system share sheet - simplified version
  static void shareGeneric(String text) {
    Share.share(text);
  }

  // Quick share method that generates text and calls generic share
  static void quickShareProduct(WomenProduct product) {
    final String shareUrl = generateProductShareUrl(product);
    final String shareText = "${product.name}\n₹${product.price ?? "2,250"}\nCheck out this amazing product!\n$shareUrl";
    shareGeneric(shareText);
  }

  // Alternative method if you want to pass the product directly
  static void shareProductGeneric(WomenProduct product) {
    final String shareUrl = generateProductShareUrl(product);
    final String shareText = "${product.name}\n₹${product.price ?? "2,250"}\nCheck out this amazing product!\n$shareUrl";
    Share.share(shareText);
  }
}