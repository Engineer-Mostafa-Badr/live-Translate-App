import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/logger.dart';
import 'storage_service.dart';

/// Service for managing app localization
class LocalizationService extends GetxService {
  final StorageService _storage = Get.find<StorageService>();
  
  final Rx<Locale> locale = const Locale('ar', 'SA').obs;
  
  // Supported locales
  static const List<Locale> supportedLocales = [
    Locale('ar', 'SA'), // Arabic
    Locale('en', 'US'), // English
  ];
  
  // Fallback locale
  static const Locale fallbackLocale = Locale('en', 'US');
  
  @override
  void onInit() {
    super.onInit();
    _loadLocale();
  }
  
  void _loadLocale() {
    final languageCode = _storage.languageCode;
    locale.value = _getLocaleFromCode(languageCode);
    Logger.log('Locale loaded: ${locale.value}');
  }
  
  Locale _getLocaleFromCode(String code) {
    switch (code) {
      case 'ar':
        return const Locale('ar', 'SA');
      case 'en':
        return const Locale('en', 'US');
      default:
        return const Locale('ar', 'SA');
    }
  }
  
  /// Change app language
  Future<void> changeLocale(String languageCode) async {
    final newLocale = _getLocaleFromCode(languageCode);
    locale.value = newLocale;
    
    await _storage.setLanguageCode(languageCode);
    Get.updateLocale(newLocale);
    
    Logger.log('Locale changed to: $languageCode');
  }
  
  /// Toggle between Arabic and English
  Future<void> toggleLanguage() async {
    final isArabic = locale.value.languageCode == 'ar';
    await changeLocale(isArabic ? 'en' : 'ar');
  }
  
  /// Get current language name
  String get currentLanguageName {
    return locale.value.languageCode == 'ar' ? 'العربية' : 'English';
  }
  
  /// Check if current language is Arabic
  bool get isArabic => locale.value.languageCode == 'ar';
  
  /// Check if current language is English
  bool get isEnglish => locale.value.languageCode == 'en';
  
  /// Get text direction
  TextDirection get textDirection {
    return isArabic ? TextDirection.rtl : TextDirection.ltr;
  }
}
