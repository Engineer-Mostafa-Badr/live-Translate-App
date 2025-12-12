import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/logger.dart';

class SettingsController extends GetxController {
  final RxString sourceLanguage = 'العربية'.obs;
  final RxString targetLanguage = 'الإنجليزية'.obs;
  final RxBool offlineTranslation = false.obs;
  final RxBool paddleOCRMode = false.obs;
  final RxBool autoTranslate = true.obs;
  final RxBool alwaysShowTranslationFAB = true.obs;
  final RxBool isPremium = false.obs;
  final RxInt daysRemaining = 30.obs;
  final RxBool darkMode = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }
  
  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    sourceLanguage.value = prefs.getString('source_language') ?? 'العربية';
    targetLanguage.value = prefs.getString('target_language') ?? 'الإنجليزية';
    offlineTranslation.value = prefs.getBool('offline_translation') ?? false;
    paddleOCRMode.value = prefs.getBool('paddle_ocr_mode') ?? false;
    autoTranslate.value = prefs.getBool('auto_translate') ?? true;
    alwaysShowTranslationFAB.value = prefs.getBool('always_show_fab') ?? true;
    isPremium.value = prefs.getBool('is_premium') ?? false;
    darkMode.value = prefs.getBool('dark_mode') ?? false;
    
    Logger.log('Settings loaded');
  }
  
  void selectSourceLanguage() {
    Get.bottomSheet(
      SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: Get.height * 0.6,
          ),
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'اختر اللغة الأصلية',
                style: Get.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: _buildLanguageList((lang) async {
                    sourceLanguage.value = lang;
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('source_language', lang);
                    Get.back();
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
  
  void selectTargetLanguage() {
    Get.bottomSheet(
      SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: Get.height * 0.6,
          ),
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'اختر اللغة الهدف',
                style: Get.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: _buildLanguageList((lang) async {
                    targetLanguage.value = lang;
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('target_language', lang);
                    Get.back();
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
  
  List<Widget> _buildLanguageList(Function(String) onSelect) {
    final languages = [
      'العربية',
      'الإنجليزية',
      'الفرنسية',
      'الإسبانية',
      'الألمانية',
      'الصينية',
      'اليابانية',
      'الكورية',
    ];
    
    return languages.map((lang) {
      return ListTile(
        title: Text(lang),
        onTap: () => onSelect(lang),
      );
    }).toList();
  }
  
  void toggleOfflineTranslation(bool value) async {
    if (!isPremium.value) {
      _showPremiumRequired();
      return;
    }
    
    offlineTranslation.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('offline_translation', value);
    Logger.log('Offline translation: $value');
  }
  
  void togglePaddleOCR(bool value) async {
    if (!isPremium.value) {
      _showPremiumRequired();
      return;
    }
    
    paddleOCRMode.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('paddle_ocr_mode', value);
    Logger.log('PaddleOCR mode: $value');
  }
  
  void toggleAutoTranslate(bool value) async {
    autoTranslate.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_translate', value);
    Logger.log('Auto translate: $value');
  }
  
  void toggleAlwaysShowFAB(bool value) async {
    alwaysShowTranslationFAB.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('always_show_fab', value);
    Logger.log('Always show translation FAB: $value');
  }
  
  void downloadLanguagePack() {
    Get.dialog(
      AlertDialog(
        title: const Text('تنزيل حزمة اللغة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('اختر اللغة للتنزيل:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('العربية'),
              subtitle: const Text('120 MB'),
              trailing: const Icon(Icons.download),
              onTap: () {
                Get.back();
                _startLanguageDownload('العربية');
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('الإنجليزية'),
              subtitle: const Text('115 MB'),
              trailing: const Icon(Icons.download),
              onTap: () {
                Get.back();
                _startLanguageDownload('الإنجليزية');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }
  
  void _startLanguageDownload(String language) {
    Get.snackbar(
      'جاري التنزيل',
      'جاري تنزيل حزمة اللغة $language...',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      showProgressIndicator: true,
    );
    
    // Simulate download
    Future.delayed(const Duration(seconds: 3), () {
      Get.snackbar(
        'تم التنزيل',
        'تم تنزيل حزمة اللغة $language بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    });
  }
  
  void toggleDarkMode(bool value) async {
    darkMode.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
    Logger.log('Dark mode: $value');
  }
  
  void manageSubscription() {
    Get.toNamed(AppRoutes.subscription);
  }
  
  void openNotificationSettings() {
    Get.snackbar(
      'قريبًا',
      'إعدادات الإشعارات قيد التطوير',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  void showAbout() {
    Get.dialog(
      AlertDialog(
        title: const Text('حول التطبيق'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Live Translate'),
            SizedBox(height: 8),
            Text('الإصدار: 1.0.0'),
            SizedBox(height: 8),
            Text('تطبيق ترجمة فورية وذكية'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('حسنًا'),
          ),
        ],
      ),
    );
  }
  
  void logout() {
    Get.dialog(
      AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('is_logged_in', false);
              Logger.log('User logged out');
              Get.offAllNamed(AppRoutes.login);
            },
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
  
  void openOfflineManager() {
    Get.toNamed('/offline-manager');
  }
  
  void _showPremiumRequired() {
    Get.dialog(
      AlertDialog(
        title: const Text('مطلوب اشتراك متميز'),
        content: const Text(
          'هذه الميزة متاحة للمشتركين المتميزين فقط. هل تريد الترقية الآن؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('لاحقًا'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed(AppRoutes.subscription);
            },
            child: const Text('ترقية الآن'),
          ),
        ],
      ),
    );
  }
}
