// import 'package:get/get.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../model/Women/WomenModel.dart'; // Make sure this path is correct
//
// class OffersController extends GetxController {
//   // Loading states for each dynamic section
//   final RxBool isLoadingEthnic = true.obs;
//   final RxBool isLoadingDresses = true.obs;
//
//   // Lists to hold the fetched products
//   final RxList<WomenProduct> ethnicWearProducts = <WomenProduct>[].obs;
//   final RxList<WomenProduct> dressAndJumpsuitProducts = <WomenProduct>[].obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     // Fetch data when the controller is initialized
//     _fetchEthnicWearProducts();
//     _fetchDressAndJumpsuitProducts();
//   }
//
//   // Fetches 2 random products for the Ethnic Wear section
//   void _fetchEthnicWearProducts() async {
//     isLoadingEthnic.value = true;
//     try {
//       final snapshot = await FirebaseFirestore.instance
//           .collectionGroup('products')
//           .where('dressType', whereIn: ['saree', 'lehenga', 'anarkali'])
//           .limit(10)
//           .get();
//
//       List<WomenProduct> products = [];
//       for (var doc in snapshot.docs) {
//         try {
//           String userId = doc.reference.parent.parent!.id;
//           products.add(WomenProduct.fromFirestore(doc.data(), doc.id, userId));
//         } catch (e) { /* silent fail */ }
//       }
//
//       products.shuffle();
//       ethnicWearProducts.value = products.take(2).toList();
//
//     } catch (e) {
//       print("Error fetching ethnic wear: $e");
//     } finally {
//       isLoadingEthnic.value = false;
//     }
//   }
//
//   // Fetches 2 random products for the Dress & Jumpsuits section
//   void _fetchDressAndJumpsuitProducts() async {
//     isLoadingDresses.value = true;
//     try {
//       final snapshot = await FirebaseFirestore.instance
//           .collectionGroup('products')
//           .where('dressType', whereIn: ['dress', 'jumpsuit', 'kaftan'])
//           .limit(10)
//           .get();
//
//       List<WomenProduct> products = [];
//       for (var doc in snapshot.docs) {
//         try {
//           String userId = doc.reference.parent.parent!.id;
//           products.add(WomenProduct.fromFirestore(doc.data(), doc.id, userId));
//         } catch (e) { /* silent fail */ }
//       }
//
//       products.shuffle();
//       dressAndJumpsuitProducts.value = products.take(2).toList();
//
//     } catch (e) {
//       print("Error fetching dresses: $e");
//     } finally {
//       isLoadingDresses.value = false;
//     }
//   }
// }