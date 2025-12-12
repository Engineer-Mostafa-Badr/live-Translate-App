import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:live_translate_app/core/services/offline_translation_service.dart';
import 'package:live_translate_app/core/services/paddle_ocr_service.dart';
import 'package:live_translate_app/core/services/usage_tracking_service.dart';
import 'package:live_translate_app/core/services/model_download_service.dart';
import 'package:live_translate_app/core/services/cache_service.dart';
import 'package:live_translate_app/core/services/supabase_subscription_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/overlay/overlay_widget.dart';
import 'firebase_options.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/utils/logger.dart';
import 'core/services/storage_service.dart';
import 'core/services/translation_service.dart';
import 'core/services/theme_service.dart';
import 'core/services/localization_service.dart';
import 'core/services/ocr_service.dart';
import 'core/localization/app_translations.dart';
import 'features/auth/auth_bindings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://ucofmfartlxssovtrmjz.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVjb2ZtZmFydGx4c3NvdnRybWp6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE4NTM5NTEsImV4cCI6MjA3NzQyOTk1MX0.YTGnDKG45bJH3C6LZHL-U-JCufSi5RA_BOYZrK2Yipw',
  );

  // Initialize Stripe
  Stripe.publishableKey =
      'pk_test_51RQUNBBF9Xg6PicJmDXKLhtpYFD42FR1cF9hY5mmPjr30G3Hhf4ntpcYbpRPhxTuOjeIGqSJeB8Z22TVhKstVixF00Tv4vRPhk';
  await Stripe.instance.applySettings();

  // Initialize services
  await _initServices();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  Logger.log('App starting...', tag: 'MAIN');

  runApp(const MyApp());
}

/// Initialize all app services
Future<void> _initServices() async {
  Logger.log('Initializing services...', tag: 'MAIN');

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Logger.success('Firebase initialized', tag: 'MAIN');

  // Initialize Auth Bindings
  AuthBindings().dependencies();
  Logger.success('Auth bindings initialized', tag: 'MAIN');

  // Storage Service (must be first)
  await Get.putAsync(() => StorageService().init());

  // Core services
  Get.put(TranslationService());
  Get.put(OCRService());
  Get.put(ThemeService());
  Get.put(LocalizationService());

  // OCR and Translation services
  Get.put(PaddleOCRService());
  await Get.find<PaddleOCRService>().init();
  Get.put(OfflineTranslationService());
  await Get.find<OfflineTranslationService>().init();

  // New services
  Get.put(UsageTrackingService());
  await Get.find<UsageTrackingService>().onInit();
  Get.put(ModelDownloadService());
  Get.put(CacheService());
  await Get.find<CacheService>().onInit();

  // Subscription service
  await Get.putAsync(() => SupabaseSubscriptionService().onInit());
  Logger.success('SupabaseSubscriptionService initialized', tag: 'MAIN');

  Logger.success('All services initialized', tag: 'MAIN');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone 11 Pro size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        final themeService = Get.find<ThemeService>();
        final localizationService = Get.find<LocalizationService>();

        return Obx(
          () => GetMaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,

            // Theme - Dynamic
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeService.themeMode.value,

            // Localization - Dynamic
            locale: localizationService.locale.value,
            fallbackLocale: LocalizationService.fallbackLocale,
            translations: AppTranslations(),

            // Routes
            initialRoute: AppRoutes.splash,
            getPages: AppRoutes.routes,

            // Default transitions
            defaultTransition: Transition.fadeIn,
            transitionDuration: const Duration(milliseconds: 300),

            // Builder for additional configurations
            builder: (context, widget) {
              return MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(1.0)),
                child: widget!,
              );
            },
          ),
        );
      },
    );
  }
}

@pragma("vm:entry-point")
void overlayMain() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: OverlayWidget()),
  );
}
