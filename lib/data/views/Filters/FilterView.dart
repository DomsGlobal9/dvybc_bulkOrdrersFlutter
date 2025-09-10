// lib/views/FilterView.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controllers/FilterController.dart';

class FilterView extends StatelessWidget {
  final String category;

  const FilterView({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FilterController controller = Get.put(FilterController());

    // Set category when view is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setCategory(category);
    });

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.tune, color: Colors.black87, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Obx(() => TextButton(
                  onPressed: controller.activeFilterCount > 0
                      ? () => controller.clearAllFilters()
                      : null,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size(0, 0),
                  ),
                  child: Text(
                    'Clear All',
                    style: TextStyle(
                      color: controller.activeFilterCount > 0
                          ? const Color(0xFF007AFF)
                          : Colors.grey[400],
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                )),
              ],
            ),
          ),

          // Horizontal Filter Content
          Expanded(
            child: Row(
              children: [
                // Left Side - Filter Categories
                Container(
                  width: 120,
                  color: Colors.grey[50],
                  child: Column(
                    children: [
                      _buildFilterTab('Colour', controller),
                      _buildFilterTab('Price', controller),
                      _buildFilterTab('Rating', controller),
                      _buildFilterTab('Style', controller),
                      _buildFilterTab('Fabric', controller),
                      _buildFilterTab('Delivery Time', controller),
                    ],
                  ),
                ),

                // Vertical Divider
                Container(
                  width: 1,
                  color: Colors.grey[200],
                ),

                // Right Side - Filter Options
                Expanded(
                  child: Obx(() => _buildFilterContent(controller)),
                ),
              ],
            ),
          ),

          // Bottom Action Buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'CLOSE',
                      style: TextStyle(
                        color: Color(0xFF007AFF),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(() => TextButton(
                    onPressed: controller.isApplying.value
                        ? null
                        : () => controller.applyFilters(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: controller.isApplying.value
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007AFF)),
                      ),
                    )
                        : const Text(
                      'APPLY',
                      style: TextStyle(
                        color: Color(0xFF007AFF),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String title, FilterController controller) {
    return GetBuilder<FilterController>(
      id: 'selected_filter',
      builder: (controller) {
        bool isSelected = controller.selectedFilterCategory.value == title.toLowerCase();
        bool hasActiveFilter = _hasActiveFilterForSection(title, controller);

        return GestureDetector(
          onTap: () => controller.setSelectedFilterCategory(title.toLowerCase()),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            color: isSelected ? Colors.white : Colors.transparent,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? Colors.black87 : Colors.grey[600],
                    ),
                  ),
                ),
                if (hasActiveFilter)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF007AFF),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterContent(FilterController controller) {
    String selectedCategory = controller.selectedFilterCategory.value;

    switch (selectedCategory) {
      case 'colour':
        return _buildColorContent(controller);
      case 'price':
        return _buildPriceContent(controller);
      case 'rating':
        return _buildRatingContent(controller);
      case 'style':
        return _buildStyleContent(controller);
      case 'fabric':
        return _buildFabricContent(controller);
      case 'delivery time':
        return _buildDeliveryTimeContent(controller);
      default:
        return _buildColorContent(controller); // Default to color
    }
  }

  bool _hasActiveFilterForSection(String section, FilterController controller) {
    switch (section.toLowerCase()) {
      case 'colour':
        return controller.filters.value.selectedColors.isNotEmpty;
      case 'price':
        return controller.filters.value.minPrice > 0 || controller.filters.value.maxPrice < 10000;
      case 'rating':
        return controller.filters.value.selectedRatings.isNotEmpty;
      case 'style':
        return controller.filters.value.selectedStyles.isNotEmpty;
      case 'fabric':
        return controller.filters.value.selectedFabrics.isNotEmpty;
      case 'delivery time':
        return controller.filters.value.selectedDeliveryTimes.isNotEmpty;
      default:
        return false;
    }
  }

  Widget _buildColorContent(FilterController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Colors',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: controller.currentColors.length,
              itemBuilder: (context, index) {
                String color = controller.currentColors[index];
                final isSelected = controller.filters.value.selectedColors.contains(color);
                final colorValue = controller.colorMap[color] ?? Colors.grey;

                return GestureDetector(
                  onTap: () => controller.toggleColor(color),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorValue,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: isSelected
                        ? Icon(
                      Icons.check,
                      color: colorValue == Colors.white || colorValue == Colors.yellow
                          ? Colors.black
                          : Colors.white,
                      size: 20,
                    )
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceContent(FilterController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Price Range',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('₹${controller.filters.value.minPrice.toInt()}',
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18)),
              Text('₹${controller.filters.value.maxPrice.toInt()}',
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 20),
          RangeSlider(
            values: RangeValues(
              controller.filters.value.minPrice,
              controller.filters.value.maxPrice,
            ),
            min: 0,
            max: 10000,
            divisions: 100,
            activeColor: const Color(0xFF007AFF),
            inactiveColor: Colors.grey[300],
            onChanged: (RangeValues values) {
              controller.updatePriceRange(values.start, values.end);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRatingContent(FilterController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Minimum Rating',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Column(
            children: [5, 4, 3, 2, 1].map((rating) {
              final isSelected = controller.filters.value.selectedRatings.contains(rating);

              return GestureDetector(
                onTap: () => controller.toggleRating(rating),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? const Color(0xFF007AFF) : Colors.grey[400]!,
                            width: 2,
                          ),
                          color: isSelected ? const Color(0xFF007AFF) : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 14)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 18,
                          );
                        }),
                      ),
                      const SizedBox(width: 8),
                      const Text('& up', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleContent(FilterController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Style Type',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: controller.currentStyles.map((style) {
              final isSelected = controller.filters.value.selectedStyles.contains(style);

              return GestureDetector(
                onTap: () => controller.toggleStyle(style),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF007AFF).withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF007AFF) : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    style,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF007AFF) : Colors.black87,
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFabricContent(FilterController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fabric Type',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: controller.currentFabrics.map((fabric) {
              final isSelected = controller.filters.value.selectedFabrics.contains(fabric);

              return GestureDetector(
                onTap: () => controller.toggleFabric(fabric),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF007AFF).withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF007AFF) : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    fabric,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF007AFF) : Colors.black87,
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryTimeContent(FilterController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Options',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Column(
            children: controller.availableDeliveryTimes.map((deliveryTime) {
              final isSelected = controller.filters.value.selectedDeliveryTimes.contains(deliveryTime);

              return GestureDetector(
                onTap: () => controller.toggleDeliveryTime(deliveryTime),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? const Color(0xFF007AFF) : Colors.grey[400]!,
                            width: 2,
                          ),
                          color: isSelected ? const Color(0xFF007AFF) : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 14)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          deliveryTime,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}