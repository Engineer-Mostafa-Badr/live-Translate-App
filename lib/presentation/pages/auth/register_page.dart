import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'register_controller.dart';

class RegisterPage extends GetView<RegisterController> {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(RegisterController());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء حساب جديد'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              // Name Field
              TextField(
                controller: controller.nameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم الكامل',
                  prefixIcon: Icon(Icons.person_outlined),
                ),
              ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2, end: 0),
              
              const SizedBox(height: 16),
              
              // Email Field
              TextField(
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2, end: 0),
              
              const SizedBox(height: 16),
              
              // Password Field
              Obx(() => TextField(
                    controller: controller.passwordController,
                    obscureText: !controller.showPassword.value,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.showPassword.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                    ),
                  )).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2, end: 0),
              
              const SizedBox(height: 16),
              
              // Confirm Password Field
              Obx(() => TextField(
                    controller: controller.confirmPasswordController,
                    obscureText: !controller.showConfirmPassword.value,
                    decoration: InputDecoration(
                      labelText: 'تأكيد كلمة المرور',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.showConfirmPassword.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: controller.toggleConfirmPasswordVisibility,
                      ),
                    ),
                  )).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2, end: 0),
              
              const SizedBox(height: 24),
              
              // Terms and Conditions
              Obx(() => Row(
                    children: [
                      Checkbox(
                        value: controller.acceptTerms.value,
                        onChanged: (value) =>
                            controller.acceptTerms.value = value ?? false,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              controller.acceptTerms.value =
                                  !controller.acceptTerms.value,
                          child: Text(
                            'أوافق على الشروط والأحكام',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ],
                  )).animate().fadeIn(delay: 500.ms),
              
              const SizedBox(height: 24),
              
              // Register Button
              Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.register,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('إنشاء حساب'),
                  )).animate().fadeIn(delay: 600.ms),
              
              const SizedBox(height: 24),
              
              // Divider
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'أو',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ).animate().fadeIn(delay: 700.ms),
              
              const SizedBox(height: 24),
              
              // Google Sign Up
              OutlinedButton.icon(
                onPressed: controller.signUpWithGoogle,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
                icon: const Icon(Icons.g_mobiledata, size: 32),
                label: const Text('التسجيل بواسطة Google'),
              ).animate().fadeIn(delay: 800.ms),
              
              const SizedBox(height: 24),
              
              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'لديك حساب بالفعل؟ ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: controller.goToLogin,
                    child: const Text('تسجيل الدخول'),
                  ),
                ],
              ).animate().fadeIn(delay: 900.ms),
            ],
          ),
        ),
      ),
    );
  }
}
