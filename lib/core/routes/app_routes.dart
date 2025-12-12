import 'package:get/get.dart';
import '../../presentation/pages/splash/splash_page.dart';
import '../../presentation/pages/onboarding/onboarding_page.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/browser/browser_page.dart';
import '../../presentation/pages/settings/settings_page.dart';
import '../../presentation/pages/subscription/subscription_page.dart';
import '../../presentation/pages/subscription/enhanced_subscription_page.dart';
import '../../presentation/pages/subscription/enhanced_subscription_controller.dart';
import '../../presentation/pages/offline_manager/offline_manager_page.dart';
import '../../presentation/pages/ocr/ocr_test_page.dart';
import '../../presentation/pages/ocr/paddle_ocr_page.dart';
import '../../presentation/bindings/ocr_binding.dart';
import '../../presentation/bindings/paddle_ocr_binding.dart';
import '../../features/auth/auth_bindings.dart';
import '../../features/auth/presentation/views/auth_gate.dart';
import '../../features/auth/presentation/views/login_screen.dart';
import '../../features/auth/presentation/views/signup_screen.dart';
import '../../features/auth/presentation/views/profile_screen.dart';

/// App routes configuration
class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String authGate = '/auth-gate';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String browser = '/browser';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String subscription = '/subscription';
  static const String enhancedSubscription = '/enhanced-subscription';
  static const String offlineManager = '/offline-manager';
  static const String ocrTest = '/ocr-test';
  static const String paddleOCR = '/paddle-ocr';
  
  static List<GetPage> routes = [
    GetPage(
      name: splash,
      page: () => const SplashPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: onboarding,
      page: () => const OnboardingPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: authGate,
      page: () => const AuthGate(),
      binding: AuthBindings(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: login,
      page: () => const LoginScreen(),
      binding: AuthBindings(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: signup,
      page: () => const SignUpScreen(),
      binding: AuthBindings(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: home,
      page: () => const HomePage(),
      binding: AuthBindings(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: browser,
      page: () => const BrowserPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: settings,
      page: () => const SettingsPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: profile,
      page: () => const ProfileScreen(),
      binding: AuthBindings(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: subscription,
      page: () => const SubscriptionPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: enhancedSubscription,
      page: () => const EnhancedSubscriptionPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<EnhancedSubscriptionController>(
          () => EnhancedSubscriptionController(),
        );
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: offlineManager,
      page: () => const OfflineManagerPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: ocrTest,
      page: () => const OCRTestPage(),
      binding: OCRBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: paddleOCR,
      page: () => const PaddleOCRPage(),
      binding: PaddleOCRBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}
