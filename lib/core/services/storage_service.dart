import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

/// Service for managing local storage
class StorageService extends GetxService {
  late SharedPreferences _prefs;
  
  // Keys
  static const String keyOnboardingCompleted = 'onboarding_completed';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserName = 'user_name';
  static const String keyUserEmail = 'user_email';
  static const String keyIsPremium = 'is_premium';
  static const String keyDaysRemaining = 'days_remaining';
  static const String keySourceLanguage = 'source_language';
  static const String keyTargetLanguage = 'target_language';
  static const String keyOfflineTranslation = 'offline_translation';
  static const String keyPaddleOCRMode = 'paddle_ocr_mode';
  static const String keyAutoTranslate = 'auto_translate';
  static const String keyDarkMode = 'dark_mode';
  static const String keyLastVisitedUrl = 'last_visited_url';
  static const String keyTranslationEnabled = 'translation_enabled';
  static const String keyScrollPosition = 'scroll_position';
  static const String keyLanguageCode = 'language_code';
  
  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    Logger.success('StorageService initialized');
    return this;
  }
  
  // Generic methods
  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }
  
  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs.getBool(key) ?? defaultValue;
  }
  
  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }
  
  String getString(String key, {String defaultValue = ''}) {
    return _prefs.getString(key) ?? defaultValue;
  }
  
  Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }
  
  int getInt(String key, {int defaultValue = 0}) {
    return _prefs.getInt(key) ?? defaultValue;
  }
  
  Future<bool> setDouble(String key, double value) async {
    return await _prefs.setDouble(key, value);
  }
  
  double getDouble(String key, {double defaultValue = 0.0}) {
    return _prefs.getDouble(key) ?? defaultValue;
  }
  
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }
  
  Future<bool> clear() async {
    return await _prefs.clear();
  }
  
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }
  
  // Specific methods for app data
  
  // Onboarding
  bool get isOnboardingCompleted => getBool(keyOnboardingCompleted);
  Future<void> setOnboardingCompleted(bool value) async {
    await setBool(keyOnboardingCompleted, value);
  }
  
  // Authentication
  bool get isLoggedIn => getBool(keyIsLoggedIn);
  Future<void> setLoggedIn(bool value) async {
    await setBool(keyIsLoggedIn, value);
  }
  
  String get userName => getString(keyUserName);
  Future<void> setUserName(String value) async {
    await setString(keyUserName, value);
  }
  
  String get userEmail => getString(keyUserEmail);
  Future<void> setUserEmail(String value) async {
    await setString(keyUserEmail, value);
  }
  
  // Subscription
  bool get isPremium => getBool(keyIsPremium);
  Future<void> setIsPremium(bool value) async {
    await setBool(keyIsPremium, value);
  }
  
  int get daysRemaining => getInt(keyDaysRemaining, defaultValue: 30);
  Future<void> setDaysRemaining(int value) async {
    await setInt(keyDaysRemaining, value);
  }
  
  // Settings
  String get sourceLanguage => getString(keySourceLanguage, defaultValue: 'العربية');
  Future<void> setSourceLanguage(String value) async {
    await setString(keySourceLanguage, value);
  }
  
  String get targetLanguage => getString(keyTargetLanguage, defaultValue: 'الإنجليزية');
  Future<void> setTargetLanguage(String value) async {
    await setString(keyTargetLanguage, value);
  }
  
  bool get offlineTranslation => getBool(keyOfflineTranslation);
  Future<void> setOfflineTranslation(bool value) async {
    await setBool(keyOfflineTranslation, value);
  }
  
  bool get paddleOCRMode => getBool(keyPaddleOCRMode);
  Future<void> setPaddleOCRMode(bool value) async {
    await setBool(keyPaddleOCRMode, value);
  }
  
  bool get autoTranslate => getBool(keyAutoTranslate, defaultValue: true);
  Future<void> setAutoTranslate(bool value) async {
    await setBool(keyAutoTranslate, value);
  }
  
  bool get darkMode => getBool(keyDarkMode);
  Future<void> setDarkMode(bool value) async {
    await setBool(keyDarkMode, value);
  }
  
  // Browser
  String get lastVisitedUrl => getString(keyLastVisitedUrl);
  Future<void> setLastVisitedUrl(String value) async {
    await setString(keyLastVisitedUrl, value);
  }
  
  bool get translationEnabled => getBool(keyTranslationEnabled);
  Future<void> setTranslationEnabled(bool value) async {
    await setBool(keyTranslationEnabled, value);
  }
  
  double get scrollPosition => getDouble(keyScrollPosition);
  Future<void> setScrollPosition(double value) async {
    await setDouble(keyScrollPosition, value);
  }
  
  // Localization
  String get languageCode => getString(keyLanguageCode, defaultValue: 'ar');
  Future<void> setLanguageCode(String value) async {
    await setString(keyLanguageCode, value);
  }
  
  // Logout
  Future<void> logout() async {
    await setLoggedIn(false);
    await remove(keyUserName);
    await remove(keyUserEmail);
    Logger.log('User logged out - data cleared');
  }
}
