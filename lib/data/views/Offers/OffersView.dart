import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Controllers/FavoritesController.dart';
import '../home/homeScreen.dart';
//import 'custom_app_bar.dart'; // Assuming the path to your CustomAppBar file




// View
class Offersview extends GetView<HomeController> {
  const Offersview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First banner
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset('assets/images/offersale.png'),
            ),

            // Women's Ethnic Wear section
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Ethnic Wear',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1, color: Colors.grey),
            SizedBox(
              height: 330, // Adjust based on image sizes
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildProductCard(
                    imagePath: 'assets/images/redlehenga.png',
                    name: 'Royal Red Lehenga',
                    price: 2150,
                    originalPrice: 3650,
                    discount: 40,
                    route: '/lehengas',
                  ),
                  _buildProductCard(
                    imagePath: 'assets/images/bluekurta.png', // As per user instruction, though it might be a mismatch
                    name: 'Cream Orange Lehenga',
                    price: 3250,
                    originalPrice: 4450,
                    discount: 40,
                    route: '/lehengas',
                  ),
                ],
              ),
            ),

            // Dress & Jumpsuits section
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Dress & Jumpsuits',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1, color: Colors.grey),
            SizedBox(
              height: 300,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildProductCard(
                    imagePath: 'assets/images/royalkaftan.png', // Assuming image name based on context
                    name: 'Royal Wear Kaftan',
                    price: 3550,
                    originalPrice: 5750,
                    discount: 50,
                    route: '/dresses',
                  ),
                  _buildProductCard(
                    imagePath: 'assets/images/darkbluekurta.png', // Assuming image name based on context
                    name: 'Dark Blue Kurta',
                    price: 650,
                    originalPrice: 3250,
                    discount: 80,
                    route: '/kurtas',
                  ),
                ],
              ),
            ),

            // Men's banner
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset('assets/images/mensuit.png'),
            ),

            // Men's Ethnic Wear section
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Ethnic Wear',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1, color: Colors.grey),
            SizedBox(
              height: 300,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildProductCard(
                    imagePath: 'assets/images/creamjacket.png',
                    name: 'Cream Nehru Jacket',
                    price: 5250,
                    originalPrice: 7450,
                    discount: 40,
                    route: '/jackets',
                  ),
                  _buildProductCard(
                    imagePath: 'assets/images/royalsherwani.png',
                    name: 'Royal Sherwani',
                    price: 4250,
                    originalPrice: 5250,
                    discount: 40,
                    route: '/sherwanis',
                  ),
                ],
              ),
            ),

            // Kids banner
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset('assets/images/kidsframe.png'),
            ),

            // Kids Wear section
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Kids Wear',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1, color: Colors.grey),
            SizedBox(
              height: 300,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildProductCard(
                    imagePath: 'assets/images/babyset.png',
                    name: 'Infants Body Set',
                    price: 350,
                    originalPrice: 500,
                    discount: 30,
                    route: '/infants',
                  ),
                  _buildProductCard(
                    imagePath: 'assets/images/boyjacket.png',
                    name: 'Boys Jacket',
                    price: 1350,
                    originalPrice: 2000,
                    discount: 30,
                    route: '/boys_jackets',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard({
    required String imagePath,
    required String name,
    required int price,
    required int originalPrice,
    required int discount,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => Get.toNamed(route),
      child: Container(
        width: Get.width / 2 - 20,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset(imagePath, fit: BoxFit.cover, height: 200, width: double.infinity),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$discount% OFF',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(Icons.favorite_border, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Row(
              children: [
                Text('₹$price', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Text(
                  '₹$originalPrice',
                  style: const TextStyle(
                    fontSize: 14,
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            Text(
              'Save ₹${originalPrice - price}',
              style: const TextStyle(fontSize: 14, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}