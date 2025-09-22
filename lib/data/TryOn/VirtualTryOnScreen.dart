import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'VirtualTryOn.dart';


class VirtualTryOnView extends StatelessWidget {
  const VirtualTryOnView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final VirtualTryOnController controller = Get.put(VirtualTryOnController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Virtual Try-On',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black),
            onPressed: () => controller.reset(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header
            Text(
              'See How It Looks On You!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Obx(() => Text(
              'Upload your photo and try on "${controller.productName.value}"',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            )),
            SizedBox(height: 30),

            // Source Images Section
            Row(
              children: [
                // User Photo Section
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Your Photo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 12),
                      Obx(() => GestureDetector(
                        onTap: () => controller.showImagePickerOptions(),
                        child: Container(
                          width: 140,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!, width: 2),
                          ),
                          child: controller.selectedImage.value != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              controller.selectedImage.value!,
                              fit: BoxFit.cover,
                            ),
                          )
                              : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                size: 40,
                                color: Color(0xFF187DBD),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Add Photo',
                                style: TextStyle(
                                  color: Color(0xFF187DBD),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                      SizedBox(height: 8),
                      Obx(() => controller.selectedImage.value != null
                          ? GestureDetector(
                        onTap: () => controller.showImagePickerOptions(),
                        child: Text(
                          'Change Photo',
                          style: TextStyle(
                            color: Color(0xFF187DBD),
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      )
                          : SizedBox.shrink()),
                    ],
                  ),
                ),

                // VS Icon
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      SizedBox(height: 30),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFF187DBD).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.add,
                          color: Color(0xFF187DBD),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                // Garment Photo Section
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Garment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 12),
                      Obx(() => Container(
                        width: 140,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!, width: 2),
                        ),
                        child: controller.garmentImageUrl.value.isNotEmpty
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            controller.garmentImageUrl.value,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.image,
                                  size: 40,
                                  color: Colors.grey[400],
                                ),
                              );
                            },
                          ),
                        )
                            : Container(
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.checkroom,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),

            // Loading or Status Section
            Obx(() {
              if (controller.isLoading.value) {
                return Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color(0xFF187DBD).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF187DBD)),
                      ),
                      SizedBox(height: 16),
                      Text(
                        controller.statusMessage.value,
                        style: TextStyle(
                          color: Color(0xFF187DBD),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              return SizedBox.shrink();
            }),

            // Result Image Section
            Obx(() {
              if (controller.resultImage.value != null) {
                return Container(
                  margin: EdgeInsets.only(bottom: 20),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Try-On Result',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Container(
                        constraints: BoxConstraints(maxHeight: 400),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            controller.resultImage.value!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              // TODO: Implement save functionality
                              Get.snackbar(
                                'Save',
                                'Save functionality will be implemented',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            },
                            icon: Icon(Icons.download, color: Color(0xFF187DBD)),
                            label: Text(
                              'Save',
                              style: TextStyle(color: Color(0xFF187DBD)),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              // TODO: Implement share functionality
                              Get.snackbar(
                                'Share',
                                'Share functionality will be implemented',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            },
                            icon: Icon(Icons.share, color: Color(0xFF187DBD)),
                            label: Text(
                              'Share',
                              style: TextStyle(color: Color(0xFF187DBD)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }
              return SizedBox.shrink();
            }),

            // Error Message Section
            Obx(() {
              if (controller.errorMessage.value.isNotEmpty && !controller.isLoading.value) {
                return Container(
                  margin: EdgeInsets.only(bottom: 20),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          controller.errorMessage.value,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return SizedBox.shrink();
            }),

            // Try-On Button
            Obx(() => Container(
              width: double.infinity,
              height: 56,
              margin: EdgeInsets.only(top: 20),
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.startTryOn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: controller.isLoading.value
                      ? Colors.grey[400]
                      : Color(0xFF187DBD),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: controller.isLoading.value
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Creating Magic...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_fix_high, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Start Virtual Try-On',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )),

            SizedBox(height: 20),

            // Instructions
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFF187DBD), size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Tips for Best Results',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  _buildTip('Use a clear, well-lit photo of yourself'),
                  _buildTip('Stand straight facing the camera'),
                  _buildTip('Wear fitted clothing for better results'),
                  _buildTip('Ensure your full torso is visible'),
                ],
              ),
            ),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: Color(0xFF187DBD), fontSize: 14)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}