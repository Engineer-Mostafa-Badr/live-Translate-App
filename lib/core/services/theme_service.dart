import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/logger.dart';
import 'storage_service.dart';

/// Service for managing app theme
class ThemeService extends GetxService {
  final StorageService _storage = Get.find<StorageService>();
  
  final Rx<ThemeMode> themeMode = ThemeMode.light.obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }
  
  void _loadTheme() {
    final isDark = _storage.darkMode;
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
    Logger.log('Theme loaded: ${themeMode.value}');
  }
  
  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    final isDark = themeMode.value == ThemeMode.dark;
    themeMode.value = isDark ? ThemeMode.light : ThemeMode.dark;
    
    await _storage.setDarkMode(!isDark);
    Get.changeThemeMode(themeMode.value);
    
    Logger.log('Theme changed to: ${themeMode.value}');
  }
  
  /// Set specific theme
  Future<void> setTheme(ThemeMode mode) async {
    themeMode.value = mode;
    await _storage.setDarkMode(mode == ThemeMode.dark);
    Get.changeThemeMode(mode);
    
    Logger.log('Theme set to: $mode');
  }
  
  /// Check if dark mode is enabled
  bool get isDarkMode => themeMode.value == ThemeMode.dark;
  
  /// Get current theme mode
  ThemeMode get currentTheme => themeMode.value;
}
