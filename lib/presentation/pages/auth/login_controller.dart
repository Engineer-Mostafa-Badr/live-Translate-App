import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/logger.dart';

class LoginController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  final RxBool isLoading = false.obs;
  final RxBool showPassword = false.obs;
  
  void togglePasswordVisibility() {
    showPassword.value = !showPassword.value;
  }
  
  void login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'خطأ',
        'الرجاء إدخال البريد الإلكتروني وكلمة المرور',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    isLoading.value = true;
    Logger.log('Attempting login for: $email');
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock successful login
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('user_email', email);
    
    isLoading.value = false;
    Logger.success('Login successful');
    
    Get.snackbar(
      'نجح',
      'تم تسجيل الدخول بنجاح',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
    
    Get.offAllNamed(AppRoutes.browser);
  }
  
  void signInWithGoogle() async {
    Logger.log('Google Sign-In initiated');
    
    Get.snackbar(
      'قريبًا',
      'سيتم تفعيل تسجيل الدخول بواسطة Google قريبًا',
      snackPosition: SnackPosition.BOTTOM,
    );
    
    // TODO: Implement Google Sign-In
  }
  
  void goToRegister() {
    Get.toNamed(AppRoutes.register);
  }
  
  void goToForgotPassword() {
    Get.toNamed(AppRoutes.forgotPassword);
  }
  
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
