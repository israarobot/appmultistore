import 'package:carthage_store/controllers/auth-controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AddProductController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final formKey = GlobalKey<FormState>();
  var isLoading = false.obs;

  // Text controllers
  final nameController = TextEditingController();
  final brandController = TextEditingController();
  final codeController = TextEditingController();
  final stockController = TextEditingController();
  final salePriceController = TextEditingController();
  final discountController = TextEditingController();
  final descriptionController = TextEditingController();
  final videoUrlController = TextEditingController();
  var imageUrlControllers = <TextEditingController>[TextEditingController()].obs;

  // Dropdown options
  final categories = ['Electronics', 'Clothing', 'Parfum', 'Make-up', 'Jewellery', 'skincare'];
  final units = ['Piece', 'Kg', 'Liter', 'Meter'];
  var selectedCategory = Rxn<String>();
  var selectedUnit = Rxn<String>();

  // Observable list for products
  var products = <Map<String, dynamic>>[].obs;

  // Fallback image URL
  static const String fallbackImageUrl = 'https://via.placeholder.com/150';

  @override
  void onClose() {
    nameController.dispose();
    brandController.dispose();
    codeController.dispose();
    stockController.dispose();
    salePriceController.dispose();
    discountController.dispose();
    descriptionController.dispose();
    videoUrlController.dispose();
    for (var controller in imageUrlControllers) {
      controller.dispose();
    }
    super.onClose();
  }

  // Add a new image URL field
  void addImageUrlField() {
    imageUrlControllers.add(TextEditingController());
  }

  // Remove an image URL field
  void removeImageUrlField(int index) {
    if (imageUrlControllers.length > 1) {
      imageUrlControllers[index].dispose();
      imageUrlControllers.removeAt(index);
    }
  }

  // Convert Google Drive or YouTube URLs
  String convertUrl(String? url) {
    if (url == null || url.trim().isEmpty) {
      print('Empty or null URL provided, using fallback');
      return fallbackImageUrl;
    }

    // Check for YouTube URLs
    final RegExp youtubeRegex = RegExp(r'^(https?://)?(www\.)?(youtube\.com|youtu\.be)/.*');
    if (youtubeRegex.hasMatch(url)) {
      final RegExp youtubeWatchRegex = RegExp(r'youtube\.com/watch\?v=([a-zA-Z0-9_-]+)');
      final RegExp youtubeShortRegex = RegExp(r'youtu\.be/([a-zA-Z0-9_-]+)');
      String? videoId;
      if (youtubeWatchRegex.hasMatch(url)) {
        videoId = youtubeWatchRegex.firstMatch(url)?.group(1);
      } else if (youtubeShortRegex.hasMatch(url)) {
        videoId = youtubeShortRegex.firstMatch(url)?.group(1);
      }
      if (videoId != null) {
        final convertedUrl = 'https://www.youtube.com/embed/$videoId';
        print('Converted YouTube URL: $url -> $convertedUrl');
        return convertedUrl;
      }
    }

    // Check for Google Drive URLs
    final RegExp driveFileRegex = RegExp(r'https://drive.google.com/file/d/([a-zA-Z0-9_-]+)');
    final RegExp driveOpenRegex = RegExp(r'https://drive.google.com/open\?id=([a-zA-Z0-9_-]+)');
    final RegExp driveViewRegex = RegExp(r'https://drive.google.com/file/d/([a-zA-Z0-9_-]+)/view');

    String? fileId;
    if (driveFileRegex.hasMatch(url)) {
      fileId = driveFileRegex.firstMatch(url)?.group(1);
    } else if (driveOpenRegex.hasMatch(url)) {
      fileId = driveOpenRegex.firstMatch(url)?.group(1);
    } else if (driveViewRegex.hasMatch(url)) {
      fileId = driveViewRegex.firstMatch(url)?.group(1);
    }

    if (fileId != null) {
      final convertedUrl = 'https://drive.google.com/uc?export=media&id=$fileId';
      print('Converted Google Drive URL: $url -> $convertedUrl');
      return convertedUrl;
    }

    print('Non-Google Drive or non-YouTube URL: $url');
    return url;
  }

  // Validate image URL
  Future<bool> isValidImageUrl(String url) async {
    if (url.isEmpty || url == fallbackImageUrl) return true;
    try {
      final response = await http.head(Uri.parse(url)).timeout(const Duration(seconds: 10));
      final contentType = response.headers['content-type']?.toLowerCase();
      final supportedFormats = ['image/png', 'image/jpeg', 'image/gif', 'image/bmp'];
      bool isValid = contentType != null && supportedFormats.contains(contentType.split(';')[0]);
      if (!isValid) {
        print('Invalid image format for URL $url: Content-Type=$contentType, Status=${response.statusCode}');
      }
      return isValid && response.statusCode == 200;
    } catch (e) {
      print('Error validating image URL $url: $e');
      return false;
    }
  }

  // Validate video URL
  Future<bool> isValidVideoUrl(String url) async {
    if (url.isEmpty) return true; // Video URL is optional
    final RegExp youtubeRegex = RegExp(r'^(https?://)?(www\.)?(youtube\.com|youtu\.be)/.*');
    if (youtubeRegex.hasMatch(url)) {
      print('YouTube URL detected: $url, assuming valid');
      return true;
    }
    try {
      final convertedUrl = convertUrl(url);
      final response = await http.head(Uri.parse(convertedUrl)).timeout(const Duration(seconds: 10));
      final contentType = response.headers['content-type']?.toLowerCase();
      final supportedFormats = ['video/mp4', 'video/webm', 'video/ogg'];
      bool isValid = contentType != null && supportedFormats.contains(contentType.split(';')[0]);
      if (!isValid) {
        print('Invalid video format for URL $convertedUrl: Content-Type=$contentType, Status=${response.statusCode}');
      }
      return isValid && response.statusCode == 200;
    } catch (e) {
      print('Error validating video URL $url: $e');
      return false;
    }
  }

  // Test a single image URL for debugging
  Future<void> testImageUrl(String url) async {
    final convertedUrl = convertUrl(url);
    bool isValid = await isValidImageUrl(convertedUrl);
    Get.snackbar(
      isValid ? 'Success' : 'Error',
      isValid ? 'Image URL is valid: $convertedUrl' : 'Invalid image URL: $convertedUrl',
      backgroundColor: isValid ? Colors.green : Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> saveProduct({String? productId}) async {
    if (!formKey.currentState!.validate()) {
      print('Form validation failed');
      return;
    }

    isLoading.value = true;

    try {
      List<String> imageUrls = [];
      for (var controller in imageUrlControllers) {
        String imageUrl = convertUrl(controller.text.trim());
        bool isValid = await isValidImageUrl(imageUrl);
        if (!isValid) {
          isLoading.value = false;
          Get.snackbar(
            'Error',
            'Invalid image URL: $imageUrl',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
          );
          return;
        }
        imageUrls.add(imageUrl);
      }

      String videoUrl = videoUrlController.text.trim();
      if (videoUrl.isNotEmpty) {
        bool isValid = await isValidVideoUrl(videoUrl);
        if (!isValid) {
          isLoading.value = false;
          Get.snackbar(
            'Error',
            'Invalid video URL: $videoUrl. Please ensure it points to a valid video file or YouTube video.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
          );
          return;
        }
        videoUrl = convertUrl(videoUrl);
      }

      String? sellerFullName = 'Unknown Seller';
      final user = authController.user;
      if (user != null) {
        try {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
          if (userDoc.exists) {
            final userData = userDoc.data() as Map<String, dynamic>?;
            sellerFullName = userData?['fullName']?.toString() ?? 'Unknown Seller';
          } else {
            print('User document does not exist for UID: ${user.uid}');
          }
        } catch (e) {
          print('Error fetching user data: $e');
          sellerFullName = 'Unknown Seller';
        }
      } else {
        print('No authenticated user found');
        isLoading.value = false;
        Get.snackbar(
          'Error',
          'No authenticated user found. Please log in.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      final productData = {
        'name': nameController.text.trim(),
        'category': selectedCategory.value,
        'brand': brandController.text.trim(),
        'code': codeController.text.trim(),
        'stock': int.tryParse(stockController.text) ?? 0,
        'unit': selectedUnit.value,
        'sale_price': double.tryParse(salePriceController.text) ?? 0.0,
        'discount': double.tryParse(discountController.text) ?? 0.0,
        'description': descriptionController.text.trim(),
        'image_urls': imageUrls,
        'video_url': videoUrl.isEmpty ? null : videoUrl,
        'created_at': productId == null ? Timestamp.now() : FieldValue.serverTimestamp(),
        'user_id': authController.user?.uid ?? 'unknown',
        'name_seller': sellerFullName,
      };

      if (productId != null) {
        await FirebaseFirestore.instance.collection('products').doc(productId).update(productData);
      } else {
        await FirebaseFirestore.instance.collection('products').add(productData);
      }

      Get.snackbar(
        'Success',
        productId == null ? 'Product saved successfully' : 'Product updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      resetForm();
      Get.offNamed('/dashboard-seller');
    } catch (e) {
      print('Error saving product: $e');
      Get.snackbar(
        'Error',
        'Failed to save product: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getAllProducts() async {
    isLoading.value = true;

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('user_id', isEqualTo: authController.user?.uid ?? 'unknown')
          .get();

      products.clear();

      products.addAll(await Future.wait(querySnapshot.docs.map((doc) async {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        if (data['image_urls'] != null && data['image_urls'] is List) {
          List<String> validatedUrls = [];
          for (String url in data['image_urls']) {
            bool isValid = await isValidImageUrl(url);
            validatedUrls.add(isValid ? url : fallbackImageUrl);
          }
          data['image_urls'] = validatedUrls;
        } else {
          data['image_urls'] = [fallbackImageUrl];
        }
        if (data['video_url'] != null && data['video_url'].isNotEmpty) {
          bool isValid = await isValidVideoUrl(data['video_url']);
          if (!isValid) {
            data['video_url'] = null;
          } else {
            data['video_url'] = convertUrl(data['video_url']);
          }
        }
        print('Fetched product: ${data['name']}, Image URLs: ${data['image_urls']}, Video URL: ${data['video_url']}');
        return data;
      })));

      Get.snackbar(
        'Success',
        'Products fetched successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('Error fetching products: $e');
      Get.snackbar(
        'Error',
        'Failed to fetch products: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProduct(String productId) async {
    isLoading.value = true;

    try {
      await FirebaseFirestore.instance.collection('products').doc(productId).delete();

      products.removeWhere((product) => product['id'] == productId);

      Get.snackbar(
        'Success',
        'Product deleted successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('Error deleting product: $e');
      Get.snackbar(
        'Error',
        'Failed to delete product: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void resetForm() {
    formKey.currentState?.reset();
    nameController.clear();
    brandController.clear();
    codeController.clear();
    stockController.clear();
    salePriceController.clear();
    discountController.clear();
    descriptionController.clear();
    videoUrlController.clear();
    for (var controller in imageUrlControllers) {
      controller.clear();
    }
    imageUrlControllers.clear();
    imageUrlControllers.add(TextEditingController());
    selectedCategory.value = null;
    selectedUnit.value = null;
  }

  String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? validateNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    if (double.tryParse(value) == null || double.parse(value) < 0) {
      return 'Enter a valid number';
    }
    return null;
  }

  String? validateOptionalNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (double.tryParse(value) == null || double.parse(value) < 0) {
      return 'Enter a valid number';
    }
    return null;
  }

  String? validateRequiredUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    final urlPattern = RegExp(r'^https?://[^\s/$.?#].[^\s]*$');
    if (!urlPattern.hasMatch(value)) {
      return 'Enter a valid URL';
    }
    return null;
  }

  String? validateOptionalUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final urlPattern = RegExp(r'^https?://[^\s/$.?#].[^\s]*$');
    final youtubeRegex = RegExp(r'^(https?://)?(www\.)?(youtube\.com|youtu\.be)/.*');
    if (!urlPattern.hasMatch(value) && !youtubeRegex.hasMatch(value)) {
      return 'Enter a valid URL';
    }
    return null;
  }
}