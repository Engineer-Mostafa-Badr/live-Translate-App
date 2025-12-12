import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/logger.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _checkUserStatus();
  }
  
  void _checkUserStatus() async {
    Logger.log('Splash screen initialized');
    
    // Wait for 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    
    final prefs = await SharedPreferences.getInstance();
    
    // Check if onboarding is completed
    final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
    
    if (!onboardingCompleted) {
      // First time user - show onboarding
      Logger.log('First time user - navigating to onboarding');
      Get.offAllNamed(AppRoutes.onboarding);
      return;
    }
    
    // Navigate to auth gate which will check Firebase auth state
    Logger.log('Navigating to auth gate');
    Get.offAllNamed(AppRoutes.authGate);
  }
}
