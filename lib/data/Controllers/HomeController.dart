// Controller
import '../views/home/homeScreen.dart';
import 'FavoritesController.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  // No dynamic state needed for this UI, but can add if required in future
  void onFavoritePressed(Product product) {
    final favController = Get.find<FavoritesController>();
    favController.toggleProductFavorite(product);
    //bestSellerProducts.refresh();
  }


}