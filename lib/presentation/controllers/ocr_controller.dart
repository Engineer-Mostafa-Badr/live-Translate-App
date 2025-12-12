import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/ocr_service.dart';
import '../../domain/entities/ocr_result.dart';

class OCRController extends GetxController {
  final OCRService _ocrService = Get.find<OCRService>();
  final ImagePicker _picker = ImagePicker();

  final RxBool isProcessing = false.obs;
  final Rx<OCRResult?> currentResult = Rx<OCRResult?>(null);
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxString errorMessage = ''.obs;

  Future<void> pickImageFromGallery() async {
    try {
      errorMessage.value = '';
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
        await processImage(File(image.path));
      }
    } catch (e) {
      errorMessage.value = 'Failed to pick image: $e';
      Get.snackbar(
        'Error',
        'Failed to pick image from gallery',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      errorMessage.value = '';
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
        await processImage(File(image.path));
      }
    } catch (e) {
      errorMessage.value = 'Failed to capture image: $e';
      Get.snackbar(
        'Error',
        'Failed to capture image from camera',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> processImage(File imageFile) async {
    try {
      isProcessing.value = true;
      errorMessage.value = '';

      final result = await _ocrService.extractText(imageFile);
      currentResult.value = result;

      if (result.hasText) {
        Get.snackbar(
          'Success',
          'Text extracted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'No Text Found',
          'No text detected in the image',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      errorMessage.value = 'OCR processing failed: $e';
      Get.snackbar(
        'Error',
        'Failed to process image: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  void clearResult() {
    currentResult.value = null;
    selectedImage.value = null;
    errorMessage.value = '';
  }

  @override
  void onClose() {
    currentResult.value = null;
    selectedImage.value = null;
    super.onClose();
  }
}
