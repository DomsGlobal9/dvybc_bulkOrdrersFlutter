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
                  Icon(Icons.tune, color: Colors.grey[800], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[900],
                      letterSpacing: -0.2,
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
                            ? const Color(0xFF2196F3)
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
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border(
                        right: BorderSide(color: Colors.grey[200]!, width: 1),
                      ),
                    ),
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
                          color: Color(0xFF2196F3),
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
                            Colors.grey[400]!,
                          ),
                        ),
                      )
                          : const Text(
                        'APPLY',
                        style: TextStyle(
                          color: Color(0xFF2196F3),
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
                border: isSelected
                    ? Border(
                  right: BorderSide(color: Color(0xFF2196F3), width: 2),
                )
                    : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                        color: isSelected ? Colors.grey[900] : Colors.grey[600],
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
                  if (hasActiveFilter)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2196F3),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
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
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colorValue,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? Colors.grey[800]!
                          : Colors.grey[300]!,
                      width: isSelected ? 2.5 : 1.5,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ] : null,
                  ),
                  child: isSelected
                      ? Icon(
                    Icons.check,
                    color: _getContrastColor(colorValue),
                    size: 16,
                  )
                      : null,
                ),
              );
            },
          )),
        ],
      ),
    );
  }

  Color _getContrastColor(Color color) {
    // Calculate luminance and return appropriate contrast color
    double luminance = (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  Widget _buildPriceContent(FilterController controller) {
    return SingleChildScrollView(
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
                  color: Colors.grey[800],
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
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          SliderTheme(
            data: SliderTheme.of(Get.context!).copyWith(
              activeTrackColor: const Color(0xFF2196F3),
              inactiveTrackColor: Colors.grey[300],
              thumbColor: const Color(0xFF2196F3),
              overlayColor: const Color(0xFF2196F3).withOpacity(0.2),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Obx(() => Column(
        children: [5, 4, 3, 2, 1].map((rating) {
          final isSelected = controller.filters.value.selectedRatings.contains(rating);

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => controller.toggleRating(rating),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                child: Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF2196F3)
                              : Colors.grey[400]!,
                          width: isSelected ? 2 : 1.5,
                        ),
                        color: isSelected
                            ? const Color(0xFF2196F3)
                            : Colors.transparent,
                      ),
                      child: isSelected
                          ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12,
                      )
                          : null,
                    ),
                    const SizedBox(width: 16),
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
                        color: Colors.grey[500],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      )),
    );
  }

  Widget _buildStyleContent(FilterController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Obx(() => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: controller.currentStyles.map((style) {
          final isSelected = controller.filters.value.selectedStyles.contains(style);

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => controller.toggleStyle(style),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2196F3).withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2196F3)
                        : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: Text(
                  style,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF2196F3)
                        : Colors.grey[700],
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Obx(() => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: controller.currentFabrics.map((fabric) {
          final isSelected = controller.filters.value.selectedFabrics.contains(fabric);

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => controller.toggleFabric(fabric),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2196F3).withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2196F3)
                        : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: Text(
                  fabric,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF2196F3)
                        : Colors.grey[700],
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Obx(() => Column(
        children: controller.availableDeliveryTimes.map((deliveryTime) {
          final isSelected = controller.filters.value.selectedDeliveryTimes.contains(deliveryTime);

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => controller.toggleDeliveryTime(deliveryTime),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                child: Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF2196F3)
                              : Colors.grey[400]!,
                          width: isSelected ? 2 : 1.5,
                        ),
                        color: isSelected
                            ? const Color(0xFF2196F3)
                            : Colors.transparent,
                      ),
                      child: isSelected
                          ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12,
                      )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        deliveryTime,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      )),
    );
  }
}