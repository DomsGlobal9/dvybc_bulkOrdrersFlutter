import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../model/Women/WomenModel.dart';
import '../../viewModel/Women/WomenViewModel.dart';
import '../home/homeScreen.dart';

// Base widget for all category views
class BaseCategoryView extends StatelessWidget {
  final String title;
  final String subtitle;
  final dynamic controller;

  const BaseCategoryView({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                SizedBox(height: 16),
                Text(controller.error.value),
                ElevatedButton(
                  onPressed: () => controller.retryLoading(),
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (controller.WomenProducts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text('No $title Found'),
                Text('Please login and add products'),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(subtitle, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                  ],
                ),
              ),
              // Grid
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: controller.WomenProducts.length,
                  itemBuilder: (context, index) => _buildProductCard(controller.WomenProducts[index]),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProductCard(WomenProduct product) {
    return GestureDetector(
      onTap: () {
        Get.toNamed('/product-detail', arguments: {
          'productName': product.name,
          'category': product.category,
          'productId': product.id,
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.all(8),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _buildImage(product),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Color(0xFF3B82F6).withOpacity(0.9), borderRadius: BorderRadius.circular(12)),
                        child: Text('View More', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 4),
                  Text(product.description, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Explore Styles', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF3B82F6))),
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(color: Color(0xFF3B82F6), borderRadius: BorderRadius.circular(6)),
                        child: Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(WomenProduct product) {
    // Firebase images first, then fallback to assets
    if (product.imageUrls!.isNotEmpty) {
      return Image.network(
        product.imageUrls!.first,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(color: Colors.grey[200], child: Center(child: CircularProgressIndicator()));
        },
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(product.name),
      );
    } else if (product.image.isNotEmpty) {
      return Image.asset(
        product.image,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(product.name),
      );
    } else {
      return _buildPlaceholder(product.name);
    }
  }

  Widget _buildPlaceholder(String name) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, size: 40, color: Colors.grey[400]),
            SizedBox(height: 8),
            Text(name, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 2),
          ],
        ),
      ),
    );
  }
}

// All category views using the base
class EthnicWearView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseCategoryView(
      title: '',
      subtitle: 'Traditional & Contemporary Indian Wear',
      controller: Get.put(EthnicWearController()),
    );
  }
}

class TopWearView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseCategoryView(
      title: 'Top Wear',
      subtitle: 'Stylish Tops, Shirts & More',
      controller: Get.put(TopWearController()),
    );
  }
}

class BottomWearView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseCategoryView(
      title: 'Bottom Wear',
      subtitle: 'Jeans, Trousers, Skirts & More',
      controller: Get.put(BottomWearController()),
    );
  }
}

class JumpsuitsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseCategoryView(
      title: 'Jumpsuits',
      subtitle: 'One-Piece Wonder Collection',
      controller: Get.put(JumpsuitsController()),
    );
  }
}

class MaternityView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseCategoryView(
      title: 'Maternity',
      subtitle: 'Comfortable Maternity & Nursing Wear',
      controller: Get.put(MaternityController()),
    );
  }
}

class SleepWearView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseCategoryView(
      title: 'Sleep Wear',
      subtitle: 'Comfortable Night & Lounge Wear',
      controller: Get.put(SleepWearController()),
    );
  }
}

class WinterWearView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseCategoryView(
      title: 'Winter Wear',
      subtitle: 'Warm & Cozy Winter Collection',
      controller: Get.put(WinterWearController()),
    );
  }
}

class ActiveWearView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseCategoryView(
      title: 'Active Wear',
      subtitle: 'Fitness & Sports Collection',
      controller: Get.put(ActiveWearController()),
    );
  }
}

class InnerWearView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseCategoryView(
      title: 'Inner Wear',
      subtitle: 'Intimate & Essential Collection',
      controller: Get.put(InnerWearController()),
    );
  }
}