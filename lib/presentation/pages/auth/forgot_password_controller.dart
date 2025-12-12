import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/logger.dart';

class ForgotPasswordController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final RxBool isLoading = false.obs;
  
  void sendResetLink() async {
    final email = emailController.text.trim();
    
    if (email.isEmpty) {
      Get.snackbar(
        'خطأ',
        'الرجاء إدخال البريد الإلكتروني',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    isLoading.value = true;
    Logger.log('Sending password reset link to: $email');
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    isLoading.value = false;
    Logger.success('Password reset link sent');
    
    Get.snackbar(
      'تم الإرسال',
      'تم إرسال رابط استعادة كلمة المرور إلى بريدك الإلكتروني',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
    
    // Go back after showing success message
    Future.delayed(const Duration(seconds: 2), () {
      Get.back();
    });
  }
  
  void goBack() {
    Get.back();
  }
  
  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
