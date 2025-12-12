import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/logger.dart';
import '../../../features/overlay/overlay_controller.dart';

class HomeController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isDesktopSite = false.obs;
  final TextEditingController urlController = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    /// مهم جداً: تشغيل الـ listener بعد تحميل الواجهة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      OverlayController.listen(() {
        print("🔵 overlay clicked!");

        Get.snackbar(
          "Overlay",
          "تم الضغط على الفقاعة",
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 1),
        );

        // هنا تضيف: Screenshot + OCR + ترجمة
      });
    });

    _initialize();
  }

  @override
  void onClose() {
    urlController.dispose();
    super.onClose();
  }

  void startOverlayBubble() async {
    try {
      final started = await OverlayController.startOverlay();
      if (!started) {
        Get.snackbar(
          'تنبيه',
          'من فضلك فعّل السماح بالظهور فوق التطبيقات',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "خطأ",
        "Overlay فشل في التشغيل: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _initialize() async {
    Logger.log('Home page initialized');
    isLoading.value = true;

    await Future.delayed(const Duration(milliseconds: 500));

    isLoading.value = false;
    Logger.success('Home page loaded successfully');
  }

  // Browser Actions
  void openBrowser() {
    Logger.log('Opening browser');
    Get.toNamed('/browser');
  }

  void openBrowserWithUrl(String url) {
    Logger.log('Opening browser with URL: $url');
    Get.toNamed('/browser', arguments: {'url': url});
  }

  void newTab() {
    Logger.log('Opening new tab');
    Get.snackbar(
      'تبويب جديد',
      'سيتم فتح تبويب جديد',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void newIncognitoTab() {
    Logger.log('Opening incognito tab');
    Get.snackbar(
      'وضع التخفي',
      'سيتم فتح تبويب في وضع التخفي',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void openBookmarks() {
    Logger.log('Opening bookmarks');
    Get.snackbar(
      'الإشارات المرجعية',
      'قريباً - عرض الإشارات المرجعية',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void openHistory() {
    Logger.log('Opening history');
    Get.snackbar(
      'السجل',
      'قريباً - عرض السجل',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void openDownloads() {
    Logger.log('Opening downloads');
    Get.snackbar(
      'التنزيلات',
      'قريباً - عرض التنزيلات',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void openSettings() {
    Logger.log('Opening settings');
    Get.snackbar(
      'الإعدادات',
      'قريباً - فتح الإعدادات',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void sharePage() {
    Logger.log('Sharing page');
    Get.snackbar(
      'مشاركة',
      'قريباً - مشاركة الصفحة',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void findInPage() {
    Logger.log('Find in page');
    Get.snackbar(
      'البحث في الصفحة',
      'قريباً - البحث في الصفحة',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void voiceSearch() {
    Logger.log('Voice search activated');
    Get.snackbar(
      'البحث الصوتي',
      'قريباً - البحث الصوتي',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void toggleDesktopSite() {
    isDesktopSite.value = !isDesktopSite.value;
    Logger.log('Desktop site: ${isDesktopSite.value}');
    Get.snackbar(
      'وضع سطح المكتب',
      isDesktopSite.value ? 'تم التفعيل' : 'تم التعطيل',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void clearUrl() {
    urlController.clear();
  }

  void loadUrl() {
    if (urlController.text.isNotEmpty) {
      String url = urlController.text;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }
      openBrowserWithUrl(url);
    }
  }

  // Translation Actions
  void openTextTranslation() {
    Logger.log('Opening text translation');
    Get.snackbar(
      'ترجمة نصية',
      'قريباً - الترجمة النصية',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void openVoiceTranslation() {
    Logger.log('Opening voice translation');
    Get.snackbar(
      'ترجمة صوتية',
      'قريباً - الترجمة الصوتية',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void openCameraTranslation() {
    Logger.log('Opening camera translation');
    Get.snackbar(
      'ترجمة مرئية',
      'قريباً - الترجمة المرئية',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}
