// lib/viewModel/FilterController.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/FilterModel.dart';

class FilterController extends GetxController {
  final Rx<FilterModel> filters = FilterModel().obs;
  final RxBool isApplying = false.obs;
  final RxMap<String, bool> expandedSections = <String, bool>{}.obs;
  final RxString selectedFilterCategory = 'colour'.obs;

  // Filter options based on category
  Map<String, List<String>> get availableColors => {
    'Women': ['Red', 'Blue', 'Green', 'Pink', 'Purple', 'Yellow', 'Orange', 'Black', 'White', 'Gray'],
    'Men': ['Blue', 'Black', 'Gray', 'White', 'Navy', 'Brown', 'Green', 'Maroon'],
    'Kids': ['Red', 'Blue', 'Pink', 'Yellow', 'Green', 'Purple', 'Orange', 'White'],
  };

  Map<String, List<String>> get availableStyles => {
    'Women': ['Casual', 'Formal', 'Party', 'Traditional', 'Western', 'Indo-Western'],
    'Men': ['Casual', 'Formal', 'Traditional', 'Sports', 'Party', 'Ethnic'],
    'Kids': ['Casual', 'Party', 'School', 'Traditional', 'Playwear', 'Formal'],
  };

  Map<String, List<String>> get availableFabrics => {
    'Women': ['Cotton', 'Silk', 'Chiffon', 'Georgette', 'Crepe', 'Linen', 'Polyester', 'Rayon'],
    'Men': ['Cotton', 'Linen', 'Silk', 'Wool', 'Denim', 'Polyester', 'Khadi'],
    'Kids': ['Cotton', 'Soft Cotton', 'Organic Cotton', 'Polyester', 'Blend', 'Fleece'],
  };

  List<String> get availableDeliveryTimes => [
    'Same Day Delivery',
    'Next Day Delivery',
    '2-Day Delivery',
    'Express Delivery (1-3 Days)',
    '3-5 Business Days',
    '5-7 Business Days',
    '7-10 Business Days'
  ];

  List<Color> get colorOptions => {
    'Red': Colors.red,
    'Blue': Colors.blue,
    'Green': Colors.green,
    'Pink': Colors.pink,
    'Purple': Colors.purple,
    'Yellow': Colors.yellow,
    'Orange': Colors.orange,
    'Black': Colors.black,
    'White': Colors.white,
    'Gray': Colors.grey,
    'Navy': const Color(0xFF000080),
    'Brown': Colors.brown,
    'Maroon': const Color(0xFF800000),
  }.entries.map((e) => e.value).toList();

  Map<String, Color> get colorMap => {
    'Red': Colors.red,
    'Blue': Colors.blue,
    'Green': Colors.green,
    'Pink': Colors.pink,
    'Purple': Colors.purple,
    'Yellow': Colors.yellow,
    'Orange': Colors.orange,
    'Black': Colors.black,
    'White': Colors.white,
    'Gray': Colors.grey,
    'Navy': const Color(0xFF000080),
    'Brown': Colors.brown,
    'Maroon': const Color(0xFF800000),
  };

  @override
  void onInit() {
    super.onInit();
    // Initialize with default values
    filters.value = FilterModel();
    selectedFilterCategory.value = 'colour'; // Initialize selected category
    // Initialize expanded sections
    expandedSections.value = {
      'colour': false,
      'price': false,
      'rating': false,
      'style': false,
      'fabric': false,
      'delivery time': false,
    };
  }

  void toggleSection(String section) {
    expandedSections[section] = !(expandedSections[section] ?? false);
    update([section]);
  }

  void setSelectedFilterCategory(String category) {
    selectedFilterCategory.value = category;
    update(['selected_filter']);
  }

  void setCategory(String category) {
    filters.value = filters.value.copyWith(category: category);
    // Clear selections that might not be available for new category
    clearAllFilters();
  }

  void toggleColor(String color) {
    List<String> currentColors = List.from(filters.value.selectedColors);
    if (currentColors.contains(color)) {
      currentColors.remove(color);
    } else {
      currentColors.add(color);
    }
    filters.value = filters.value.copyWith(selectedColors: currentColors);
  }

  void updatePriceRange(double min, double max) {
    filters.value = filters.value.copyWith(minPrice: min, maxPrice: max);
  }

  void toggleRating(int rating) {
    List<int> currentRatings = List.from(filters.value.selectedRatings);
    if (currentRatings.contains(rating)) {
      currentRatings.remove(rating);
    } else {
      currentRatings.add(rating);
    }
    filters.value = filters.value.copyWith(selectedRatings: currentRatings);
  }

  void toggleStyle(String style) {
    List<String> currentStyles = List.from(filters.value.selectedStyles);
    if (currentStyles.contains(style)) {
      currentStyles.remove(style);
    } else {
      currentStyles.add(style);
    }
    filters.value = filters.value.copyWith(selectedStyles: currentStyles);
  }

  void toggleFabric(String fabric) {
    List<String> currentFabrics = List.from(filters.value.selectedFabrics);
    if (currentFabrics.contains(fabric)) {
      currentFabrics.remove(fabric);
    } else {
      currentFabrics.add(fabric);
    }
    filters.value = filters.value.copyWith(selectedFabrics: currentFabrics);
  }

  void toggleDeliveryTime(String deliveryTime) {
    List<String> currentDeliveryTimes = List.from(filters.value.selectedDeliveryTimes);
    if (currentDeliveryTimes.contains(deliveryTime)) {
      currentDeliveryTimes.remove(deliveryTime);
    } else {
      currentDeliveryTimes.add(deliveryTime);
    }
    filters.value = filters.value.copyWith(selectedDeliveryTimes: currentDeliveryTimes);
  }

  void clearAllFilters() {
    filters.value.clear();
    filters.refresh();
  }

  Future<void> applyFilters() async {
    isApplying.value = true;

    try {
      // Add any validation or processing logic here
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call

      // Close the filter modal and return the filters
      Get.back(result: filters.value);

      // Show success message
      Get.showSnackbar(
        GetSnackBar(
          titleText: const Text(
            'Filters Applied',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          messageText: const Text(
            'Your filters have been applied successfully',
            style: TextStyle(color: Colors.white),
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF10B981),
          borderRadius: 8,
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      Get.showSnackbar(
        GetSnackBar(
          titleText: const Text(
            'Error',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          messageText: const Text(
            'Failed to apply filters',
            style: TextStyle(color: Colors.white),
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
          borderRadius: 8,
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      isApplying.value = false;
    }
  }

  int get activeFilterCount {
    int count = 0;
    if (filters.value.selectedColors.isNotEmpty) count++;
    if (filters.value.selectedRatings.isNotEmpty) count++;
    if (filters.value.selectedStyles.isNotEmpty) count++;
    if (filters.value.selectedFabrics.isNotEmpty) count++;
    if (filters.value.selectedDeliveryTimes.isNotEmpty) count++;
    if (filters.value.minPrice > 0 || filters.value.maxPrice < 10000) count++;
    return count;
  }

  // Get current category options
  List<String> get currentColors => availableColors[filters.value.category] ?? [];
  List<String> get currentStyles => availableStyles[filters.value.category] ?? [];
  List<String> get currentFabrics => availableFabrics[filters.value.category] ?? [];
}