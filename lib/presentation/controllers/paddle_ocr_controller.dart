import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/paddle_ocr_service.dart';

class PaddleOCRController extends GetxController {
  final PaddleOCRService _paddleOCRService = Get.find<PaddleOCRService>();
  final ImagePicker _picker = ImagePicker();

  final RxBool isProcessing = false.obs;
  final RxBool isModelLoaded = false.obs;
  final RxString ocrResult = ''.obs;
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxString errorMessage = ''.obs;
  final RxDouble processingProgress = 0.0.obs;
  final RxList<TextBlock> detectedBlocks = <TextBlock>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeModel();
  }

  Future<void> _initializeModel() async {
    try {
      isProcessing.value = true;
      await _paddleOCRService.init();
      isModelLoaded.value = _paddleOCRService.isInitialized.value;
      Get.snackbar(
        'Success',
        'PaddleOCR model loaded successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = 'Failed to initialize model: $e';
      Get.snackbar(
        'Error',
        'Failed to load OCR model',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isProcessing.value = false;
    }
  }

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
    if (!isModelLoaded.value) {
      Get.snackbar(
        'Error',
        'OCR model not loaded yet',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isProcessing.value = true;
      errorMessage.value = '';
      ocrResult.value = '';
      detectedBlocks.clear();
      processingProgress.value = 0.0;

      // Process image with PaddleOCR
      final result = await _paddleOCRService.recognizeText(imageFile.path);
      
      if (result != null) {
        detectedBlocks.value = result.blocks;
        ocrResult.value = result.text;
      } else {
        detectedBlocks.clear();
        ocrResult.value = '';
      }

      processingProgress.value = 1.0;

      if (ocrResult.value.isNotEmpty) {
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
    ocrResult.value = '';
    selectedImage.value = null;
    errorMessage.value = '';
    detectedBlocks.clear();
    processingProgress.value = 0.0;
  }

  @override
  void onClose() {
    selectedImage.value = null;
    super.onClose();
  }
}
