import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

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

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    isLoading.value = true;
    try {
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('B2BBulkOrders_users').doc(uid).get();
      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>?;
        String fullName = data?['name'] ?? '';
        List<String> parts = fullName.split(' ');
        firstNameController.text = parts.isNotEmpty ? parts.first : '';
        lastNameController.text = parts.length > 1 ? parts.skip(1).join(' ') : '';
        genderController.text = data?['gender'] ?? '';
        dobController.text = data?['dob'] ?? '';
        phoneController.text = data?['phone'] ?? '';
        emailController.text = data?['email'] ?? '';
        profileImageUrl.value = data?['profileImageUrl'] ?? '';
      }
    } catch (e) {
      print('Fetch error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleEditMode() {
    isEditMode.toggle();
    if (!isEditMode.value) {
      fetchUserData();
    }
  }

  Future<void> pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      profileImagePath.value = image.path;
    }
  }

  Future<void> saveChanges() async {
    isLoading.value = true;
    try {
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      String fullName = '${firstNameController.text.trim()} ${lastNameController.text.trim()}'.trim();

      await FirebaseFirestore.instance.collection('Bulk').doc(uid).update({
        'name': fullName,
        'gender': genderController.text.trim(),
        'dob': dobController.text.trim(),
        'phone': phoneController.text.trim(),
        'email': emailController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (profileImagePath.value.isNotEmpty) {
        Reference ref = FirebaseStorage.instance.ref('profile_images/$uid');
        UploadTask uploadTask = ref.putFile(File(profileImagePath.value));
        TaskSnapshot snapshot = await uploadTask;
        String url = await snapshot.ref.getDownloadURL();
        await FirebaseFirestore.instance.collection('Bulk').doc(uid).update({'profileImageUrl': url});
        profileImageUrl.value = url;
        profileImagePath.value = '';
      }
    } catch (e) {
      print('Save error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void addDeliveryAddress() {
    // No pop-up, just a placeholder
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'DVYB',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profile Setting',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Obx(() => GestureDetector(
                    onTap: controller.toggleEditMode,
                    child: Row(
                      children: [
                        Text(
                          controller.isEditMode.value ? 'Cancel' : 'Edit',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.edit,
                          size: 18,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  )),
                ],
              ),
              SizedBox(height: 30),
              Obx(() => GestureDetector(
                onTap: controller.isEditMode.value ? controller.pickProfileImage : null,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey[300],
                  ),
                  child: controller.isLoading.value
                      ? Center(child: CircularProgressIndicator())
                      : controller.profileImageUrl.value.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      controller.profileImageUrl.value,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(Icons.error, color: Colors.red),
                    ),
                  )
                      : controller.profileImagePath.value.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      File(controller.profileImagePath.value),
                      fit: BoxFit.cover,
                    ),
                  )
                      : Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.orange[300],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )),
              SizedBox(height: 40),
              _buildFormField(
                label: 'First Name',
                controller: controller.firstNameController,
                placeholder: 'Enter Your First Name',
              ),
              SizedBox(height: 25),
              _buildFormField(
                label: 'Last Name',
                controller: controller.lastNameController,
                placeholder: 'Enter Your Second Name',
              ),
              SizedBox(height: 25),
              _buildFormField(
                label: 'Gender',
                controller: controller.genderController,
                placeholder: 'You\'re Gender',
                isDropdown: true,
              ),
              SizedBox(height: 25),
              _buildFormField(
                label: 'Date of Birth',
                controller: controller.dobController,
                placeholder: 'Enter You\'re Date Of Birth',
                isDatePicker: true,
              ),
              SizedBox(height: 25),
              _buildFormField(
                label: 'Phone Number',
                controller: controller.phoneController,
                placeholder: '+91 90000000000',
              ),
              SizedBox(height: 25),
              _buildFormField(
                label: 'E-Mail',
                controller: controller.emailController,
                placeholder: 'Ex. Dvyb123@gmail.com',
              ),
              SizedBox(height: 30),
              GestureDetector(
                onTap: controller.addDeliveryAddress,
                child: Row(
                  children: [
                    Icon(
                      Icons.add,
                      color: Color(0xFF0066CC),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Add Delivery Address',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF0066CC),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              Obx(() => controller.isEditMode.value
                  ? Container(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1E3A5F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
                  : SizedBox.shrink()),
              SizedBox(height: 30),
            ],
          ),
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
      bool isEnabled = controller.isEditMode.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: isDropdown && isEnabled
                ? DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.text.isEmpty ? null : controller.text,
                hint: Text(
                  placeholder,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
                isExpanded: true,
                items: ['Male', 'Female', 'Other'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    controller.text = newValue;
                  }
                },
              ),
            )
                : isDatePicker && isEnabled
                ? GestureDetector(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: Get.context!,
                  initialDate: DateTime.now().subtract(Duration(days: 365 * 20)),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  controller.text =
                  "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
                }
              },
              child: AbsorbPointer(
                child: TextFormField(
                  controller: controller,
                  style: TextStyle(
                    fontSize: 14,
                    color: isEnabled ? Colors.black : Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    hintText: placeholder,
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    border: InputBorder.none,
                    suffixIcon: Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
            )
                : TextFormField(
              controller: controller,
              enabled: isEnabled,
              style: TextStyle(
                fontSize: 14,
                color: isEnabled ? Colors.black : Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                hintText: isEnabled ? placeholder : null,
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      );
    });
  }
}

extension on TextEditingController {
  get isEditMode => null;
}