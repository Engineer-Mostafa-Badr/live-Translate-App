import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/logger.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;
  
  final List<Map<String, dynamic>> pages = [
    {
      'title': 'ترجمة فورية وذكية',
      'description': 'احصل على ترجمة فورية لأي صفحة ويب بنقرة واحدة',
      'icon': Icons.translate,
      'color': const Color(0xFF6C63FF),
    },
    {
      'title': 'متصفح مدمج',
      'description': 'تصفح الإنترنت مع ترجمة مباشرة دون مغادرة التطبيق',
      'icon': Icons.web,
      'color': const Color(0xFF03DAC6),
    },
    {
      'title': 'دعم متعدد اللغات',
      'description': 'ترجم من وإلى أكثر من 100 لغة حول العالم',
      'icon': Icons.language,
      'color': const Color(0xFFFF6B6B),
    },
    {
      'title': 'وضع متميز',
      'description': 'استمتع بالترجمة دون اتصال ومميزات حصرية',
      'icon': Icons.star,
      'color': const Color(0xFFFFA726),
    },
  ];
  
  void onPageChanged(int index) {
    currentPage.value = index;
  }
  
  void nextPage() {
    if (currentPage.value < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  void skip() async {
    await _completeOnboarding();
    Get.offAllNamed(AppRoutes.authGate);
  }
  
  void startFree() async {
    Logger.log('User chose to start free');
    await _completeOnboarding();
    Get.offAllNamed(AppRoutes.authGate);
  }
  
  void subscribe() async {
    Logger.log('User chose to subscribe');
    await _completeOnboarding();
    Get.offAllNamed(AppRoutes.subscription);
  }
  
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    Logger.success('Onboarding completed');
  }
  
  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
