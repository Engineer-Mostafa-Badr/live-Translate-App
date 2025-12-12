import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/logger.dart';

class RegisterController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  final RxBool isLoading = false.obs;
  final RxBool showPassword = false.obs;
  final RxBool showConfirmPassword = false.obs;
  final RxBool acceptTerms = false.obs;
  
  void togglePasswordVisibility() {
    showPassword.value = !showPassword.value;
  }
  
  void toggleConfirmPasswordVisibility() {
    showConfirmPassword.value = !showConfirmPassword.value;
  }
  
  void register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'خطأ',
        'الرجاء ملء جميع الحقول',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    if (password != confirmPassword) {
      Get.snackbar(
        'خطأ',
        'كلمة المرور غير متطابقة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    if (!acceptTerms.value) {
      Get.snackbar(
        'خطأ',
        'يجب الموافقة على الشروط والأحكام',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    isLoading.value = true;
    Logger.log('Attempting registration for: $email');
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock successful registration
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);
    
    isLoading.value = false;
    Logger.success('Registration successful');
    
    Get.snackbar(
      'نجح',
      'تم إنشاء الحساب بنجاح',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
    
    Get.offAllNamed(AppRoutes.browser);
  }
  
  void signUpWithGoogle() async {
    Logger.log('Google Sign-Up initiated');
    
    Get.snackbar(
      'قريبًا',
      'سيتم تفعيل التسجيل بواسطة Google قريبًا',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  void goToLogin() {
    Get.back();
  }
  
  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
