// lib/model/FilterModel.dart
class FilterModel {
  List<String> selectedColors;
  double minPrice;
  double maxPrice;
  List<int> selectedRatings;
  List<String> selectedStyles;
  List<String> selectedFabrics;
  List<String> selectedDeliveryTimes;
  String category; // Women, Men, Kids

  FilterModel({
    this.selectedColors = const [],
    this.minPrice = 0,
    this.maxPrice = 50000,
    this.selectedRatings = const [],
    this.selectedStyles = const [],
    this.selectedFabrics = const [],
    this.selectedDeliveryTimes = const [],
    this.category = 'Women',
  });

  FilterModel copyWith({
    List<String>? selectedColors,
    double? minPrice,
    double? maxPrice,
    List<int>? selectedRatings,
    List<String>? selectedStyles,
    List<String>? selectedFabrics,
    List<String>? selectedDeliveryTimes,
    String? category,
  }) {
    return FilterModel(
      selectedColors: selectedColors ?? this.selectedColors,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      selectedRatings: selectedRatings ?? this.selectedRatings,
      selectedStyles: selectedStyles ?? this.selectedStyles,
      selectedFabrics: selectedFabrics ?? this.selectedFabrics,
      selectedDeliveryTimes: selectedDeliveryTimes ?? this.selectedDeliveryTimes,
      category: category ?? this.category,
    );
  }

  void clear() {
    selectedColors = [];
    selectedRatings = [];
    selectedStyles = [];
    selectedFabrics = [];
    selectedDeliveryTimes = [];
    minPrice = 0;
    maxPrice = 10000;
  }

  bool get hasActiveFilters {
    return selectedColors.isNotEmpty ||
        selectedRatings.isNotEmpty ||
        selectedStyles.isNotEmpty ||
        selectedFabrics.isNotEmpty ||
        selectedDeliveryTimes.isNotEmpty ||
        minPrice > 0 ||
        maxPrice < 10000;
  }

  Map<String, dynamic> toJson() {
    return {
      'selectedColors': selectedColors,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'selectedRatings': selectedRatings,
      'selectedStyles': selectedStyles,
      'selectedFabrics': selectedFabrics,
      'selectedDeliveryTimes': selectedDeliveryTimes,
      'category': category,
    };
  }

  factory FilterModel.fromJson(Map<String, dynamic> json) {
    return FilterModel(
      selectedColors: List<String>.from(json['selectedColors'] ?? []),
      minPrice: json['minPrice']?.toDouble() ?? 0,
      maxPrice: json['maxPrice']?.toDouble() ?? 10000,
      selectedRatings: List<int>.from(json['selectedRatings'] ?? []),
      selectedStyles: List<String>.from(json['selectedStyles'] ?? []),
      selectedFabrics: List<String>.from(json['selectedFabrics'] ?? []),
      selectedDeliveryTimes: List<String>.from(json['selectedDeliveryTimes'] ?? []),
      category: json['category'] ?? 'Women',
    );
  }
}