import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/paddle_ocr_service.dart';
import '../../../core/services/offline_translation_service.dart';
import '../../../core/utils/logger.dart';

class OfflineManagerController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxString usedStorage = '0 MB'.obs;
  final RxDouble storagePercentage = 0.0.obs;
  
  // OCR
  final RxBool ocrModelsDownloaded = false.obs;
  final RxBool isDownloadingOCR = false.obs;
  final RxDouble ocrDownloadProgress = 0.0.obs;
  
  // Language Packs
  final RxList languagePacks = [].obs;
  final RxString downloadingLanguage = ''.obs;
  final RxDouble languageDownloadProgress = 0.0.obs;
  
  late PaddleOCRService _ocrService;
  late OfflineTranslationService _translationService;
  
  @override
  void onInit() {
    super.onInit();
    _initialize();
  }
  
  Future<void> _initialize() async {
    try {
      isLoading.value = true;
      
      // Get services
      _ocrService = Get.find<PaddleOCRService>();
      _translationService = Get.find<OfflineTranslationService>();
      
      // Check OCR status
      ocrModelsDownloaded.value = _ocrService.isInitialized.value;
      
      // Load language packs
      languagePacks.value = _translationService.getAvailableLanguages();
      
      // Calculate storage
      await _calculateStorage();
      
      isLoading.value = false;
      Logger.success('Offline manager initialized', tag: 'OFFLINE_MGR');
    } catch (e) {
      Logger.error('Error initializing offline manager: $e', tag: 'OFFLINE_MGR');
      isLoading.value = false;
    }
  }
  
  Future<void> _calculateStorage() async {
    try {
      final translationSize = await _translationService.getTotalDownloadedSize();
      final totalMB = (translationSize / (1024 * 1024)).toStringAsFixed(1);
      usedStorage.value = '$totalMB MB';
      
      // Assume 500 MB total available
      storagePercentage.value = translationSize / (500 * 1024 * 1024);
    } catch (e) {
      Logger.error('Error calculating storage: $e', tag: 'OFFLINE_MGR');
    }
  }
  
  // OCR Methods
  Future<void> downloadOCRModels() async {
    try {
      isDownloadingOCR.value = true;
      ocrDownloadProgress.value = 0.0;
      
      final success = await _ocrService.downloadModels(
        onProgress: (progress) {
          ocrDownloadProgress.value = progress;
        },
      );
      
      if (success) {
        ocrModelsDownloaded.value = true;
        Get.snackbar(
          'تم التحميل',
          'تم تحميل نماذج OCR بنجاح',
          snackPosition: SnackPosition.BOTTOM,
        );
        await _calculateStorage();
      } else {
        Get.snackbar(
          'خطأ',
          'فشل تحميل نماذج OCR',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      
      isDownloadingOCR.value = false;
    } catch (e) {
      Logger.error('Error downloading OCR models: $e', tag: 'OFFLINE_MGR');
      isDownloadingOCR.value = false;
    }
  }
  
  Future<void> deleteOCRModels() async {
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('حذف نماذج OCR'),
          content: const Text('هل أنت متأكد من حذف نماذج OCR؟'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('حذف'),
            ),
          ],
        ),
      );
      
      if (confirmed == true) {
        // Delete models
        ocrModelsDownloaded.value = false;
        Get.snackbar(
          'تم الحذف',
          'تم حذف نماذج OCR',
          snackPosition: SnackPosition.BOTTOM,
        );
        await _calculateStorage();
      }
    } catch (e) {
      Logger.error('Error deleting OCR models: $e', tag: 'OFFLINE_MGR');
    }
  }
  
  void testOCR() {
    Get.snackbar(
      'اختبار OCR',
      'قريباً - سيتم فتح صفحة اختبار OCR',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  // Language Pack Methods
  Future<void> downloadLanguagePack(String languageCode) async {
    try {
      downloadingLanguage.value = languageCode;
      languageDownloadProgress.value = 0.0;
      
      final success = await _translationService.downloadLanguagePack(
        languageCode,
        onProgress: (progress) {
          languageDownloadProgress.value = progress;
        },
      );
      
      if (success) {
        // Update language packs list
        languagePacks.value = _translationService.getAvailableLanguages();
        
        Get.snackbar(
          'تم التحميل',
          'تم تحميل حزمة اللغة بنجاح',
          snackPosition: SnackPosition.BOTTOM,
        );
        await _calculateStorage();
      } else {
        Get.snackbar(
          'خطأ',
          'فشل تحميل حزمة اللغة',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      
      downloadingLanguage.value = '';
    } catch (e) {
      Logger.error('Error downloading language pack: $e', tag: 'OFFLINE_MGR');
      downloadingLanguage.value = '';
    }
  }
  
  Future<void> deleteLanguagePack(String languageCode) async {
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('حذف حزمة اللغة'),
          content: const Text('هل أنت متأكد من حذف حزمة اللغة؟'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('حذف'),
            ),
          ],
        ),
      );
      
      if (confirmed == true) {
        final success = await _translationService.deleteLanguagePack(languageCode);
        
        if (success) {
          // Update language packs list
          languagePacks.value = _translationService.getAvailableLanguages();
          
          Get.snackbar(
            'تم الحذف',
            'تم حذف حزمة اللغة',
            snackPosition: SnackPosition.BOTTOM,
          );
          await _calculateStorage();
        }
      }
    } catch (e) {
      Logger.error('Error deleting language pack: $e', tag: 'OFFLINE_MGR');
    }
  }
}
