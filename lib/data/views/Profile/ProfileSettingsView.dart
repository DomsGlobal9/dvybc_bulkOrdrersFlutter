import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../Widgets/CustomDVYBAppBarWithBack.dart';

class ProfileSettingsController extends GetxController {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final RxBool isEditMode = false.obs;
  final RxString profileImagePath = ''.obs;
  final RxString profileImageUrl = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isImageUploading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    isLoading.value = true;
    try {
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        print('No user logged in');
        return;
      }

      // First try the collection you're reading from
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('B2BBulkOrders_users')
          .doc(uid)
          .get();

      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>?;
        _populateFields(data);
      } else {
        // Try alternative collection name in case of mismatch
        doc = await FirebaseFirestore.instance
            .collection('Bulk')
            .doc(uid)
            .get();

        if (doc.exists) {
          var data = doc.data() as Map<String, dynamic>?;
          _populateFields(data);
        } else {
          print('No user document found in any collection');
          // Initialize with current user email if available
          User? currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null) {
            emailController.text = currentUser.email ?? '';
            if (currentUser.displayName != null && currentUser.displayName!.isNotEmpty) {
              List<String> parts = currentUser.displayName!.split(' ');
              firstNameController.text = parts.isNotEmpty ? parts.first : '';
              lastNameController.text = parts.length > 1 ? parts.skip(1).join(' ') : '';
            }
          }
        }
      }
    } catch (e) {
      print('Fetch error: $e');
      _showErrorSnackbar('Failed to load profile data');
    } finally {
      isLoading.value = false;
    }
  }

  void _populateFields(Map<String, dynamic>? data) {
    if (data == null) return;

    String fullName = data['name'] ?? '';
    List<String> parts = fullName.split(' ');
    firstNameController.text = parts.isNotEmpty ? parts.first : '';
    lastNameController.text = parts.length > 1 ? parts.skip(1).join(' ') : '';
    genderController.text = data['gender'] ?? '';
    dobController.text = data['dob'] ?? '';
    phoneController.text = data['phone'] ?? '';
    emailController.text = data['email'] ?? '';
    profileImageUrl.value = data['profileImageUrl'] ?? '';
  }

  void toggleEditMode() {
    isEditMode.toggle();
    if (!isEditMode.value) {
      // If canceling edit, reload original data
      fetchUserData();
    }
  }

  Future<void> pickProfileImage() async {
    try {
      // Show enhanced bottom sheet for image picker options
      Get.bottomSheet(
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E8E8),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                'Select Profile Picture',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E2E2E),
                  fontFamily: 'Outfit',
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              const Text(
                'Choose how you\'d like to update your profile picture',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF999999),
                  fontFamily: 'Outfit',
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Camera option
              _buildImagePickerOption(
                icon: Icons.camera_alt_outlined,
                iconColor: const Color(0xFF1B5E96),
                iconBgColor: const Color(0xFFF7FCFF),
                title: 'Camera',
                subtitle: 'Take a new photo',
                onTap: () async {
                  Get.back();
                  await _pickImageFromSource(ImageSource.camera);
                },
              ),

              // Gallery option
              _buildImagePickerOption(
                icon: Icons.photo_library_outlined,
                iconColor: const Color(0xFF1B5E96),
                iconBgColor: const Color(0xFFF7FCFF),
                title: 'Gallery',
                subtitle: 'Choose from your photos',
                onTap: () async {
                  Get.back();
                  await _pickImageFromSource(ImageSource.gallery);
                },
              ),

              // Remove photo option (if image exists)
              if (profileImageUrl.value.isNotEmpty || profileImagePath.value.isNotEmpty)
                _buildImagePickerOption(
                  icon: Icons.delete_outline,
                  iconColor: const Color(0xFFE53E3E),
                  iconBgColor: const Color(0xFFFFEBEE),
                  title: 'Remove Photo',
                  subtitle: 'Delete current photo',
                  onTap: () {
                    Get.back();
                    _showRemoveImageDialog();
                  },
                ),

              const SizedBox(height: 24),

              // Cancel button
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: TextButton(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFFE8E8E8)),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF666666),
                      fontFamily: 'Outfit',
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
      );
    } catch (e) {
      print('Image picker error: $e');
      _showErrorSnackbar('Failed to open image picker');
    }
  }

  Widget _buildImagePickerOption({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isImageUploading.value ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF0F0F0)),
            ),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 16),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E2E2E),
                          fontFamily: 'Outfit',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF999999),
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xFF999999),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      isImageUploading.value = true;

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1080,
        maxHeight: 1080,
        preferredCameraDevice: CameraDevice.front, // For selfies
      );

      if (image != null) {
        profileImagePath.value = image.path;
        _showSuccessSnackbar('Profile picture selected successfully!');
      }
    } catch (e) {
      print('Image selection error: $e');
      _showErrorSnackbar('Failed to select image. Please try again.');
    } finally {
      isImageUploading.value = false;
    }
  }

  void _showRemoveImageDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Remove Profile Picture',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E2E2E),
            fontFamily: 'Outfit',
          ),
        ),
        content: const Text(
          'Are you sure you want to remove your profile picture?',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF666666),
            fontFamily: 'Outfit',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF666666),
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _removeProfileImage();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53E3E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              'Remove',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _removeProfileImage() {
    profileImagePath.value = '';
    profileImageUrl.value = '';
    _showSuccessSnackbar('Profile picture removed successfully');
  }

  Future<void> saveChanges() async {
    isLoading.value = true;
    try {
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        _showErrorSnackbar('No user logged in');
        return;
      }

      String fullName = '${firstNameController.text.trim()} ${lastNameController.text.trim()}'.trim();

      Map<String, dynamic> updateData = {
        'name': fullName,
        'gender': genderController.text.trim(),
        'dob': dobController.text.trim(),
        'phone': phoneController.text.trim(),
        'email': emailController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Update in both collections to ensure consistency
      await FirebaseFirestore.instance
          .collection('B2BBulkOrders_users')
          .doc(uid)
          .set(updateData, SetOptions(merge: true));

      await FirebaseFirestore.instance
          .collection('Bulk')
          .doc(uid)
          .set(updateData, SetOptions(merge: true));

      // Handle profile image upload
      if (profileImagePath.value.isNotEmpty) {
        try {
          isImageUploading.value = true;

          // Create unique filename with timestamp
          String fileName = 'profile_${uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          Reference ref = FirebaseStorage.instance.ref('profile_images/$fileName');

          // Upload with metadata
          SettableMetadata metadata = SettableMetadata(
            contentType: 'image/jpeg',
            customMetadata: {
              'userId': uid,
              'uploadTime': DateTime.now().toIso8601String(),
            },
          );

          UploadTask uploadTask = ref.putFile(File(profileImagePath.value), metadata);

          // Show upload progress (optional)
          uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
            double progress = snapshot.bytesTransferred / snapshot.totalBytes;
            print('Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
          });

          TaskSnapshot snapshot = await uploadTask;
          String url = await snapshot.ref.getDownloadURL();

          // Update image URL in both collections
          await FirebaseFirestore.instance
              .collection('B2BBulkOrders_users')
              .doc(uid)
              .update({'profileImageUrl': url});

          await FirebaseFirestore.instance
              .collection('Bulk')
              .doc(uid)
              .update({'profileImageUrl': url});

          profileImageUrl.value = url;
          profileImagePath.value = '';

        } catch (e) {
          print('Image upload error: $e');
          _showErrorSnackbar('Profile saved but image upload failed. Please try again.');
        } finally {
          isImageUploading.value = false;
        }
      }

      isEditMode.value = false;
      _showSuccessSnackbar('Profile updated successfully!');

    } catch (e) {
      print('Save error: $e');
      _showErrorSnackbar('Failed to save changes. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: Colors.white,
      borderRadius: 8,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFE53E3E),
      colorText: Colors.white,
      borderRadius: 8,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }

  void addDeliveryAddress() {
    Get.snackbar(
      'Info',
      'Delivery address feature coming soon!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1B5E96),
      colorText: Colors.white,
      borderRadius: 8,
      margin: const EdgeInsets.all(16),
    );
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

class ProfileSettingsView extends StatelessWidget {
  final ProfileSettingsController controller = Get.put(ProfileSettingsController());

  ProfileSettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomDVYBAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF1B5E96),
            ),
          );
        }

        return SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Profile Setting',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E2E2E),
                          fontFamily: 'Outfit',
                        ),
                      ),
                      GestureDetector(
                        onTap: controller.toggleEditMode,
                        child: Row(
                          children: [
                            Text(
                              controller.isEditMode.value ? 'Cancel' : 'Edit',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF2E2E2E),
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Outfit',
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.edit,
                              size: 16,
                              color: Color(0xFF2E2E2E),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Enhanced Profile Image
                  GestureDetector(
                    onTap: controller.isEditMode.value ? controller.pickProfileImage : null,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _buildProfileImage(),
                    ),
                  ),

                  const SizedBox(height: 40),
                  _buildFormField(
                    label: 'First Name',
                    controller: controller.firstNameController,
                    placeholder: 'Enter Your First Name',
                  ),
                  const SizedBox(height: 24),
                  _buildFormField(
                    label: 'Last Name',
                    controller: controller.lastNameController,
                    placeholder: 'Enter Your Last Name',
                  ),
                  const SizedBox(height: 24),
                  _buildFormField(
                    label: 'Gender',
                    controller: controller.genderController,
                    placeholder: 'Select Your Gender',
                    isDropdown: true,
                  ),
                  const SizedBox(height: 24),
                  _buildFormField(
                    label: 'Date of Birth',
                    controller: controller.dobController,
                    placeholder: 'Enter Your Date Of Birth',
                    isDatePicker: true,
                  ),
                  const SizedBox(height: 24),
                  _buildFormField(
                    label: 'Phone Number',
                    controller: controller.phoneController,
                    placeholder: '+91 90000000000',
                  ),
                  const SizedBox(height: 24),
                  _buildFormField(
                    label: 'E-Mail',
                    controller: controller.emailController,
                    placeholder: 'Ex. Dvyb123@gmail.com',
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: controller.addDeliveryAddress,
                    child: const Row(
                      children: [
                        Icon(
                          Icons.add,
                          color: Color(0xFF1B5E96),
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Add Delivery Address',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1B5E96),
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  controller.isEditMode.value
                      ? Container(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: (controller.isLoading.value || controller.isImageUploading.value)
                          ? null
                          : controller.saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E96),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: (controller.isLoading.value || controller.isImageUploading.value)
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ),
                  )
                      : const SizedBox.shrink(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProfileImage() {
    return Obx(() {
      Widget imageWidget;

      if (controller.profileImagePath.value.isNotEmpty) {
        // Show selected local image
        imageWidget = ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            File(controller.profileImagePath.value),
            fit: BoxFit.cover,
            width: 120,
            height: 120,
          ),
        );
      } else if (controller.profileImageUrl.value.isNotEmpty) {
        // Show network image
        imageWidget = ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            controller.profileImageUrl.value,
            fit: BoxFit.cover,
            width: 120,
            height: 120,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFFE8E8E8),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF1B5E96),
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
          ),
        );
      } else {
        // Show placeholder
        imageWidget = _buildPlaceholderImage();
      }

      return Stack(
        children: [
          imageWidget,

          // Edit button overlay (only in edit mode)
          if (controller.isEditMode.value)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B5E96),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: controller.isImageUploading.value
                    ? const Padding(
                  padding: EdgeInsets.all(6),
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Center(
                  child: Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFE8E8E8),
      ),
      child: const Center(
        child: Icon(
          Icons.person,
          size: 40,
          color: Color(0xFF999999),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String placeholder,
    bool isDropdown = false,
    bool isDatePicker = false,
  }) {
    return Obx(() {
      bool isEnabled = this.controller.isEditMode.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2E2E2E),
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 48),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFE8E8E8),
                width: 1,
              ),
            ),
            child: isDropdown && isEnabled
                ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.text.isEmpty ? null : controller.text,
                  hint: Text(
                    placeholder,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF999999),
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  isExpanded: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF999999),
                  ),
                  items: ['Male', 'Female', 'Other'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2E2E2E),
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      controller.text = newValue;
                    }
                  },
                ),
              ),
            )
                : isDatePicker && isEnabled
                ? GestureDetector(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: Get.context!,
                  initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Color(0xFF1B5E96),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  controller.text =
                  "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        controller.text.isEmpty ? placeholder : controller.text,
                        style: TextStyle(
                          fontSize: 14,
                          color: controller.text.isEmpty
                              ? const Color(0xFF999999)
                              : const Color(0xFF2E2E2E),
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: Color(0xFF999999),
                    ),
                  ],
                ),
              ),
            )
                : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: TextFormField(
                controller: controller,
                enabled: isEnabled,
                style: TextStyle(
                  fontSize: 14,
                  color: isEnabled ? const Color(0xFF2E2E2E) : const Color(0xFF666666),
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Outfit',
                ),
                decoration: InputDecoration(
                  hintText: isEnabled ? placeholder : null,
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF999999),
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Outfit',
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}