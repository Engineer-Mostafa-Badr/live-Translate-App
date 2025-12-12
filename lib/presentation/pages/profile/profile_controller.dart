import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/logger.dart';

class ProfileController extends GetxController {
  final RxString userName = 'المستخدم'.obs;
  final RxString userEmail = 'user@example.com'.obs;
  final RxBool isPremium = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }
  
  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userName.value = prefs.getString('user_name') ?? 'المستخدم';
    userEmail.value = prefs.getString('user_email') ?? 'user@example.com';
    isPremium.value = prefs.getBool('is_premium') ?? false;
    
    Logger.log('User data loaded: ${userName.value}');
  }
  
  void editProfile() {
    Get.snackbar(
      'قريبًا',
      'تعديل الملف الشخصي قيد التطوير',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  void changePassword() {
    Get.snackbar(
      'قريبًا',
      'تغيير كلمة المرور قيد التطوير',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  void viewHistory() {
    Get.snackbar(
      'قريبًا',
      'سجل الترجمات قيد التطوير',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  void viewFavorites() {
    Get.snackbar(
      'قريبًا',
      'المفضلة قيد التطوير',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  void manageSubscription() {
    Get.toNamed(AppRoutes.subscription);
  }
  
  void upgradeSubscription() {
    Get.toNamed(AppRoutes.subscription);
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
}
