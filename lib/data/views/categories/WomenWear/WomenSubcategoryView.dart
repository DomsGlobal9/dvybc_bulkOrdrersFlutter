import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Widgets/CustomDVYBAppBarWithBack.dart';

// Subcategory Data Model
class SubcategoryData {
  final String name;
  final String assetImage;
  final String productType;

  SubcategoryData({
    required this.name,
    required this.assetImage,
    required this.productType,
  });
}

// Static subcategory data for each main category
final Map<String, List<SubcategoryData>> subcategoryData = {
  'Ethnic wear': [
    SubcategoryData(name: 'Sarees', assetImage: 'assets/images/subcategories/ethnic/sarees.png', productType: 'saree'),
    SubcategoryData(name: 'Salwar Suit', assetImage: 'assets/images/subcategories/ethnic/salwar_suits.png', productType: 'salwar suit'),
    SubcategoryData(name: 'Lehengas', assetImage: 'assets/images/subcategories/ethnic/lehengas.png', productType: 'lehenga'),
    SubcategoryData(name: 'Anarkali', assetImage: 'assets/images/subcategories/ethnic/anarkali.png', productType: 'anarkali'),
    SubcategoryData(name: 'Dupattas', assetImage: 'assets/images/subcategories/ethnic/dupattas.png', productType: 'dupatta'),
    SubcategoryData(name: 'Ethnic Jacket', assetImage: 'assets/images/subcategories/ethnic/ethnic_jackets.png', productType: 'ethnic jackets'),
  ],
  'Top wear': [
    SubcategoryData(name: 'T-Shirts', assetImage: 'assets/images/subcategories/topwear/tshirts.png', productType: 'tshirt'),
    SubcategoryData(name: 'Tops & Blouses', assetImage: 'assets/images/subcategories/topwear/tops_blouses.png', productType: 'top'),
    SubcategoryData(name: 'Shirts', assetImage: 'assets/images/subcategories/topwear/shirts.png', productType: 'shirt'),
    SubcategoryData(name: 'Kurtis & kurtas', assetImage: 'assets/images/subcategories/topwear/kurtis_kurtas.png', productType: 'kurta'),
    SubcategoryData(name: 'Tunics', assetImage: 'assets/images/subcategories/topwear/tunics.png', productType: 'tunic'),
    SubcategoryData(name: 'Tank Tops', assetImage: 'assets/images/subcategories/topwear/tank_tops.png', productType: 'tank_top'),
  ],
  'Bottom wear': [
    SubcategoryData(name: 'Jeans', assetImage: 'assets/images/subcategories/bottomwear/jeans.png', productType: 'jeans'),
    SubcategoryData(name: 'Trousers & Pants', assetImage: 'assets/images/subcategories/bottomwear/trousers_pants.png', productType: 'trouser'),
    SubcategoryData(name: 'Skirts', assetImage: 'assets/images/subcategories/bottomwear/skirts.png', productType: 'skirt'),
    SubcategoryData(name: 'Shorts', assetImage: 'assets/images/subcategories/bottomwear/shorts.png', productType: 'shorts'),
    SubcategoryData(name: 'Leggings', assetImage: 'assets/images/subcategories/bottomwear/leggings.png', productType: 'leggings'),
    SubcategoryData(name: 'Palazzos', assetImage: 'assets/images/subcategories/bottomwear/palazzos.png', productType: 'palazzo'),
  ],
  'Jumpsuits': [
    SubcategoryData(name: 'Kaftan', assetImage: 'assets/images/subcategories/jumpsuits/kaftan.png', productType: 'kaftan'),
    SubcategoryData(name: 'Maxi Dresses', assetImage: 'assets/images/subcategories/jumpsuits/maxi_dresses.png', productType: 'maxi_dress'),
    SubcategoryData(name: 'Bodycon', assetImage: 'assets/images/subcategories/jumpsuits/bodycon.png', productType: 'bodycon'),
    SubcategoryData(name: 'A-line Dresses', assetImage: 'assets/images/subcategories/jumpsuits/aline_dresses.png', productType: 'aline_dress'),
    SubcategoryData(name: 'Jumpsuits', assetImage: 'assets/images/subcategories/jumpsuits/jumpsuits.png', productType: 'jumpsuit'),
    SubcategoryData(name: 'Rompers', assetImage: 'assets/images/subcategories/jumpsuits/rompers.png', productType: 'romper'),
  ],
  'Sleep wear': [
    SubcategoryData(name: 'Night Suits', assetImage: 'assets/images/subcategories/sleepwear/night_suits.png', productType: 'night_suit'),
    SubcategoryData(name: 'Nighties', assetImage: 'assets/images/subcategories/sleepwear/nighties.png', productType: 'nightie'),
    SubcategoryData(name: 'Pyjamas', assetImage: 'assets/images/subcategories/sleepwear/pyjamas.png', productType: 'pyjama'),
    SubcategoryData(name: 'Loungewear', assetImage: 'assets/images/subcategories/sleepwear/loungewear.png', productType: 'loungewear'),
    SubcategoryData(name: 'Robes', assetImage: 'assets/images/subcategories/sleepwear/robes.png', productType: 'robe'),
  ],
  'Active wear': [
    SubcategoryData(name: 'Sports Bra', assetImage: 'assets/images/subcategories/activewear/sports_bra.png', productType: 'sports_bra'),
    SubcategoryData(name: 'Track Pants', assetImage: 'assets/images/subcategories/activewear/track_pants.png', productType: 'track_pants'),
    SubcategoryData(name: 'Workout T-Shirt', assetImage: 'assets/images/subcategories/activewear/workout_tshirt.png', productType: 'workout_tshirt'),
    SubcategoryData(name: 'Yoga Pants', assetImage: 'assets/images/subcategories/activewear/yoga_pants.png', productType: 'yoga_pants'),
    SubcategoryData(name: 'Joggers', assetImage: 'assets/images/subcategories/activewear/joggers.png', productType: 'joggers'),
  ],
  'Winter wear': [
    SubcategoryData(name: 'Sweaters', assetImage: 'assets/images/subcategories/winterwear/sweaters.png', productType: 'sweater'),
    SubcategoryData(name: 'Cardigans', assetImage: 'assets/images/subcategories/winterwear/cardigans.png', productType: 'cardigan'),
    SubcategoryData(name: 'Coats', assetImage: 'assets/images/subcategories/winterwear/coats.png', productType: 'coat'),
    SubcategoryData(name: 'Jackets', assetImage: 'assets/images/subcategories/winterwear/jackets.png', productType: 'jacket'),
    SubcategoryData(name: 'Ponchos', assetImage: 'assets/images/subcategories/winterwear/ponchos.png', productType: 'poncho'),
    SubcategoryData(name: 'Shawls', assetImage: 'assets/images/subcategories/winterwear/shawls.png', productType: 'shawl'),
  ],
  'Maternity': [
    SubcategoryData(name: 'Maternity Wear', assetImage: 'assets/images/subcategories/maternity/maternity_wear.png', productType: 'maternity_dress'),
    SubcategoryData(name: 'Feeding Tops', assetImage: 'assets/images/subcategories/maternity/feeding_tops.png', productType: 'feeding_top'),
    SubcategoryData(name: 'Maternity Leggings', assetImage: 'assets/images/subcategories/maternity/maternity_leggings.png', productType: 'maternity_leggings'),
  ],
  'Inner wear': [
    SubcategoryData(name: 'Bras', assetImage: 'assets/images/subcategories/innerwear/bras.png', productType: 'bra'),
    SubcategoryData(name: 'Panties', assetImage: 'assets/images/subcategories/innerwear/panties.png', productType: 'panties'),
    SubcategoryData(name: 'Slips & Camisoles', assetImage: 'assets/images/subcategories/innerwear/slips_camisoles.png', productType: 'slip'),
    SubcategoryData(name: 'Shapewear', assetImage: 'assets/images/subcategories/innerwear/shapewear.png', productType: 'shapewear'),
  ],
};

class WomenSubcategoryView extends StatelessWidget {
  final String mainCategory;
  final VoidCallback? onBackPressed;

  const WomenSubcategoryView({
    Key? key,
    required this.mainCategory,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<SubcategoryData> subcategories = subcategoryData[mainCategory] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomDVYBAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: onBackPressed ?? () => Get.back(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        mainCategory,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose from our curated collection',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Subcategories Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemCount: subcategories.length,
                itemBuilder: (context, index) {
                  return _buildSubcategoryCard(subcategories[index]);
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSubcategoryCard(SubcategoryData subcategory) {
    return GestureDetector(
      onTap: () {
        Get.toNamed('/product-detail', arguments: {
          'productName': subcategory.name,
          'category': subcategory.productType,
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Subcategory Image
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    subcategory.assetImage,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_outlined,
                                  size: 40, color: Colors.grey[400]),
                              const SizedBox(height: 8),
                              Text(
                                subcategory.name,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            // Subcategory Name
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                subcategory.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
