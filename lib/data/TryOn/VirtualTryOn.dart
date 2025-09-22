import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class VirtualTryOnController extends GetxController {
  final String apiKey = "fa-jCmx621bg3ye-0kZFcMHh0PgG3YWC38Pl2zbl";

  // Reactive variables
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxString garmentImageUrl = ''.obs;
  final RxString productName = ''.obs;
  final Rx<Uint8List?> resultImage = Rx<Uint8List?>(null);

  final RxBool isLoading = false.obs;
  final RxString statusMessage = ''.obs;
  final RxString errorMessage = ''.obs;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    // Get the garment image URL and product name from arguments
    final arguments = Get.arguments;
    if (arguments != null) {
      garmentImageUrl.value = arguments['garmentImageUrl'] ?? '';
      productName.value = arguments['productName'] ?? 'Fashion Item';
    }
  }

  // Pick image from gallery
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
        // Clear previous results
        resultImage.value = null;
        errorMessage.value = '';
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  // Pick image from camera
  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
        // Clear previous results
        resultImage.value = null;
        errorMessage.value = '';
      }
    } catch (e) {
      _showError('Failed to take photo: $e');
    }
  }

  // Start virtual try-on process
  Future<void> startTryOn() async {
    if (selectedImage.value == null) {
      _showError('Please select or take a photo first');
      return;
    }

    if (garmentImageUrl.value.isEmpty) {
      _showError('Garment image not available');
      return;
    }

    // Reset state
    resultImage.value = null;
    errorMessage.value = '';
    statusMessage.value = "Preparing images...";
    isLoading.value = true;

    try {
      // Convert images to base64
      String? modelBase64 = await _convertImageToBase64(selectedImage.value!);
      String? garmentBase64 = await _convertUrlImageToBase64(garmentImageUrl.value);

      if (modelBase64 == null || garmentBase64 == null) {
        _showError('Failed to process images');
        return;
      }

      statusMessage.value = "Uploading to FASHN AI...";

      // Submit to API
      await _submitToAPI(modelBase64, garmentBase64);

    } catch (e) {
      _showError('Try-on failed: $e');
    }
  }

  // Convert local image file to base64
  Future<String?> _convertImageToBase64(File imageFile) async {
    try {
      Uint8List imageBytes = await imageFile.readAsBytes();
      String base64String = base64Encode(imageBytes);
      return "data:image/jpeg;base64,$base64String";
    } catch (e) {
      print('Error converting image to base64: $e');
      return null;
    }
  }

  // Convert URL image to base64
  Future<String?> _convertUrlImageToBase64(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        String base64String = base64Encode(response.bodyBytes);
        return "data:image/jpeg;base64,$base64String";
      }
      return null;
    } catch (e) {
      print('Error converting URL image to base64: $e');
      return null;
    }
  }

  // Submit to FASHN API
  Future<void> _submitToAPI(String modelImage, String garmentImage) async {
    try {
      final url = Uri.parse('https://api.fashn.ai/v1/run');

      final request = http.Request('POST', url);
      request.headers.addAll({
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      });

      final requestBody = {
        'model_image': modelImage,
        'garment_image': garmentImage,
        'category': 'tops'
      };

      request.body = jsonEncode(requestBody);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final taskId = jsonResponse['id'];

        if (taskId != null) {
          print('Got task ID: $taskId');
          statusMessage.value = "Processing your try-on...";
          await _pollForResult(taskId);
        } else {
          _showError('Invalid response from API');
        }
      } else {
        _showError('API request failed: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Connection failed: $e');
    }
  }

  // Poll for result
  Future<void> _pollForResult(String taskId) async {
    const maxAttempts = 25;

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        await Future.delayed(Duration(seconds: 3));

        final statusUrl = Uri.parse('https://api.fashn.ai/v1/status/$taskId');
        final response = await http.get(statusUrl, headers: {
          'Authorization': 'Bearer $apiKey',
        });

        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          print('Status attempt $attempt: $jsonResponse');

          // Check for result URL in various formats
          String? imageUrl;

          if (jsonResponse['result_url'] != null) {
            imageUrl = jsonResponse['result_url'];
          } else if (jsonResponse['output'] is String) {
            imageUrl = jsonResponse['output'];
          } else if (jsonResponse['output'] is List && (jsonResponse['output'] as List).isNotEmpty) {
            imageUrl = (jsonResponse['output'] as List)[0].toString();
          }

          if (imageUrl != null) {
            print('Found image URL: $imageUrl');
            await _downloadAndShowImage(imageUrl);
            return;
          }

          // Check status
          if (jsonResponse['status'] != null) {
            String status = jsonResponse['status'].toString().toLowerCase();

            switch (status) {
              case 'completed':
              case 'success':
              case 'finished':
              // Look for image URL again
                if (imageUrl == null) {
                  _showError('Task completed but no image URL found');
                  return;
                }
                break;

              case 'failed':
              case 'error':
                String errorMsg = jsonResponse['message']?.toString() ?? 'Processing failed';
                _showError(errorMsg);
                return;

              case 'processing':
              case 'running':
              case 'pending':
                statusMessage.value = "Still processing... ($attempt/$maxAttempts)";
                break;

              default:
                statusMessage.value = "Status: $status - waiting... ($attempt/$maxAttempts)";
                break;
            }
          } else {
            statusMessage.value = "Checking status... ($attempt/$maxAttempts)";
          }
        }
      } catch (e) {
        print('Error checking status: $e');
      }
    }

    _showError('Processing took too long. Please try again.');
  }

  // Download and show result image
  Future<void> _downloadAndShowImage(String imageUrl) async {
    try {
      statusMessage.value = "Downloading your result...";

      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        resultImage.value = response.bodyBytes;
        isLoading.value = false;
        statusMessage.value = '';

        Get.snackbar(
          'Success!',
          'Your virtual try-on is ready!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );

        print('SUCCESS! Image downloaded and ready to display');
      } else {
        _showError('Failed to download result image');
      }
    } catch (e) {
      _showError('Download failed: $e');
    }
  }

  // Show error and reset loading state
  void _showError(String message) {
    isLoading.value = false;
    statusMessage.value = '';
    errorMessage.value = message;

    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: Duration(seconds: 4),
    );

    print('ERROR: $message');
  }

  // Reset all state
  void reset() {
    selectedImage.value = null;
    resultImage.value = null;
    isLoading.value = false;
    statusMessage.value = '';
    errorMessage.value = '';
  }

  // Show image picker options
  void showImagePickerOptions() {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(top: 12, bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Select Photo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.photo_library, color: Color(0xFF187DBD)),
              title: Text('Choose from Gallery'),
              onTap: () {
                Get.back();
                pickImageFromGallery();
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: Color(0xFF187DBD)),
              title: Text('Take a Photo'),
              onTap: () {
                Get.back();
                pickImageFromCamera();
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}