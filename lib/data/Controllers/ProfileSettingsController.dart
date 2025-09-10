// File: controllers/profile_settings_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../model/UserModel.dart';


class ProfileSettingsController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  RxBool isEditMode = false.obs;
  RxBool isLoading = false.obs;
  RxString profileImagePath = ''.obs;

  UserModel? currentUser;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    isLoading.value = true;
    try {
      currentUser = await _firebaseService.getCurrentUserData();
      if (currentUser != null) {
        // Populate form fields with existing data
        firstNameController.text = currentUser!.firstName ?? '';
        lastNameController.text = currentUser!.lastName ?? '';
        genderController.text = currentUser!.gender ?? '';
        dobController.text = currentUser!.dateOfBirth ?? '';
        phoneController.text = currentUser!.phone;
        emailController.text = currentUser!.email;
        profileImagePath.value = currentUser!.profileImageUrl ?? '';
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load user data');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleEditMode() {
    isEditMode.value = !isEditMode.value;
    if (!isEditMode.value) {
      // Reset form fields when cancelling edit
      loadUserData();
    }
  }

  Future<void> saveChanges() async {
    if (currentUser != null) {
      isLoading.value = true;
      try {
        UserModel updatedUser = UserModel(
          uid: currentUser!.uid,
          name: currentUser!.name,
          email: emailController.text,
          phone: phoneController.text,
          firstName: firstNameController.text.isEmpty ? null : firstNameController.text,
          lastName: lastNameController.text.isEmpty ? null : lastNameController.text,
          gender: genderController.text.isEmpty ? null : genderController.text,
          dateOfBirth: dobController.text.isEmpty ? null : dobController.text,
          profileImageUrl: profileImagePath.value.isEmpty ? null : profileImagePath.value,
          createdAt: currentUser!.createdAt,
        );

        bool success = await _firebaseService.updateUserProfile(updatedUser);
        if (success) {
          currentUser = updatedUser;
          isEditMode.value = false;
          Get.snackbar('Success', 'Profile updated successfully');
        } else {
          Get.snackbar('Error', 'Failed to update profile');
        }
      } catch (e) {
        Get.snackbar('Error', 'Failed to save changes');
      } finally {
        isLoading.value = false;
      }
    }
  }

  void pickProfileImage() {
    // Implement image picker logic here
    // You'll need to add image_picker package for this
  }

  void addDeliveryAddress() {
    // Implement add delivery address functionality
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

