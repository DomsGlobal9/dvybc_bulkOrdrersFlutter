import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileSettingsController extends GetxController {
  var profileImagePath = ''.obs;
  var isLoading = false.obs;
  var isEditMode = false.obs;

  // Form controllers
  final firstNameController = TextEditingController(text: 'Ravi');
  final lastNameController = TextEditingController(text: 'Kumar');
  final genderController = TextEditingController(text: 'Male');
  final dobController = TextEditingController(text: '23-08-1987');
  final phoneController = TextEditingController(text: '+91 9976537252');
  final emailController = TextEditingController(text: 'Ravikumar3345@gmail.com');

  @override
  void onInit() {
    super.onInit();
  }

  void toggleEditMode() {
    isEditMode.value = !isEditMode.value;
  }

  void saveChanges() {
    isEditMode.value = false;
    Get.snackbar(
      'Success',
      'Profile updated successfully!',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> pickProfileImage() async {
    try {
      isLoading.value = true;
      await Future.delayed(Duration(milliseconds: 500));
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image');
    } finally {
      isLoading.value = false;
    }
  }

  void addDeliveryAddress() {
    Get.snackbar('Info', 'Add Delivery Address clicked');
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    genderController.dispose();
    dobController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.onClose();
  }
}