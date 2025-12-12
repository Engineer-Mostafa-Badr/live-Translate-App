import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'login_screen.dart';

/// Auth Gate
/// Checks authentication state and routes accordingly
/// - If authenticated -> Navigate to home
/// - If not authenticated -> Show login screen
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Obx(() {
      // Show loading indicator while checking auth state
      if (authController.currentUser.value == null && 
          authController.isLoading.value) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // If user is authenticated, navigate to home
      if (authController.isAuthenticated.value) {
        // Use WidgetsBinding to ensure navigation happens after build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.currentRoute != '/home') {
            Get.offAllNamed('/home');
          }
        });
        
        // Show loading while navigating
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // If not authenticated, show login screen
      return const LoginScreen();
    });
  }
}
