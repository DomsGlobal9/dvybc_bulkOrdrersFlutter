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

    return Material(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.92,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            // Drag Handle
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.tune, color: Colors.black87, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  Obx(() => TextButton(
                    onPressed: controller.activeFilterCount > 0
                        ? () => controller.clearAllFilters()
                        : null,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Clear All',
                      style: TextStyle(
                        color: controller.activeFilterCount > 0
                            ? const Color(0xFF007AFF)
                            : Colors.grey[400],
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  )),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Side - Filter Categories
                  Container(
                    width: 100,
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

                  // Right Side - Filter Options
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: Obx(() => _buildFilterContent(controller)),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Action Buttons
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'CLOSE',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Obx(() => TextButton(
                      onPressed: controller.isApplying.value
                          ? null
                          : () => controller.applyFilters(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: controller.isApplying.value
                          ? SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF007AFF),
                          ),
                        ),
                      )
                          : const Text(
                        'APPLY',
                        style: TextStyle(
                          color: Color(0xFF007AFF),
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          letterSpacing: 0.5,
                        ),
                      ),
                    )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String title, FilterController controller) {
    return GetBuilder<FilterController>(
      id: 'selected_filter',
      builder: (controller) {
        bool isSelected = controller.selectedFilterCategory.value == title.toLowerCase();
        bool hasActiveFilter = _hasActiveFilterForSection(title, controller);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => controller.setSelectedFilterCategory(title.toLowerCase()),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
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
        return _buildColorContent(controller);
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
        children: [
          Expanded(
            child: Obx(() => ListView.builder(
              itemCount: controller.currentColors.length,
              itemBuilder: (context, index) {
                String color = controller.currentColors[index];
                final isSelected = controller.filters.value.selectedColors.contains(color);
                final colorValue = controller.colorMap[color] ?? Colors.grey;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => controller.toggleColor(color),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? Border.all(color: Colors.grey[300]!, width: 1)
                              : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: colorValue,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                color,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceContent(FilterController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Obx(() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${controller.filters.value.minPrice.toInt()}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              Text(
                '-',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[400],
                ),
              ),
              Text(
                '₹${controller.filters.value.maxPrice.toInt()}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          SliderTheme(
            data: SliderTheme.of(Get.context!).copyWith(
              activeTrackColor: const Color(0xFF007AFF),
              inactiveTrackColor: Colors.grey[300],
              thumbColor: const Color(0xFF007AFF),
              overlayColor: const Color(0xFF007AFF).withOpacity(0.2),
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: RangeSlider(
              values: RangeValues(
                controller.filters.value.minPrice,
                controller.filters.value.maxPrice,
              ),
              min: 0,
              max: 10000,
              divisions: 100,
              onChanged: (RangeValues values) {
                controller.updatePriceRange(values.start, values.end);
              },
            ),
          ),
        ],
      )),
    );
  }

  Widget _buildRatingContent(FilterController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Obx(() => Column(
        children: [5, 4, 3, 2, 1].map((rating) {
          final isSelected = controller.filters.value.selectedRatings.contains(rating);

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => controller.toggleRating(rating),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? Border.all(color: Colors.grey[300]!, width: 1)
                        : null,
                  ),
                  child: Row(
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < rating ? Icons.star : Icons.star_outline,
                            color: Colors.amber[600],
                            size: 16,
                          );
                        }),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '& up',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      )),
    );
  }

  Widget _buildStyleContent(FilterController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Obx(() => Column(
        children: controller.currentStyles.map((style) {
          final isSelected = controller.filters.value.selectedStyles.contains(style);

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => controller.toggleStyle(style),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? Border.all(color: Colors.grey[300]!, width: 1)
                        : null,
                  ),
                  child: Text(
                    style,
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      )),
    );
  }

  Widget _buildFabricContent(FilterController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Obx(() => Column(
        children: controller.currentFabrics.map((fabric) {
          final isSelected = controller.filters.value.selectedFabrics.contains(fabric);

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => controller.toggleFabric(fabric),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? Border.all(color: Colors.grey[300]!, width: 1)
                        : null,
                  ),
                  child: Text(
                    fabric,
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      )),
    );
  }

  Widget _buildDeliveryTimeContent(FilterController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Obx(() => Column(
        children: controller.availableDeliveryTimes.map((deliveryTime) {
          final isSelected = controller.filters.value.selectedDeliveryTimes.contains(deliveryTime);

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => controller.toggleDeliveryTime(deliveryTime),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? Border.all(color: Colors.grey[300]!, width: 1)
                        : null,
                  ),
                  child: Text(
                    deliveryTime,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      )),
    );
  }
}