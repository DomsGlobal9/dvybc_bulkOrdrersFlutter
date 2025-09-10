import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BoysJacketsView extends StatelessWidget {
  const BoysJacketsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('Boys Jackets'),
      ),
      body: ListView(
        children: [
          _buildItem('Boys Jacket', 1350, 2000, 30),
          _buildItem('Kids Winter Jacket', 1500, 2500, 40),
        ],
      ),
    );
  }

  Widget _buildItem(String name, int price, int originalPrice, int discount) {
    return ListTile(
      leading: const Icon(Icons.child_care, size: 50, color: Colors.grey),
      title: Text(name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('₹$price', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Text(
                '₹$originalPrice',
                style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey),
              ),
            ],
          ),
          Text('Save ₹${originalPrice - price}', style: const TextStyle(color: Colors.green)),
        ],
      ),
      trailing: Container(
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
    );
  }
}